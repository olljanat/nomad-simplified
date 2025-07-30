package traefikplugin

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strings"

	"github.com/hashicorp/nomad/api"
)

// Config holds the plugin configuration.
type Config struct {
	SchemaFile string `json:"schemaFile"`
}

// Schema defines the validation schema with regex-based namespace selectors.
type Schema map[string][]Rule

// Rule defines a validation rule for a job field.
type Rule struct {
	FieldPath    string `json:"fieldPath"`
	AllowedValue string `json:"allowedValue"`
}

// CreateConfig creates and initializes the plugin configuration.
func CreateConfig() *Config {
	return &Config{}
}

// DynamicValidator is the plugin struct.
type DynamicValidator struct {
	next         http.Handler
	name         string
	schema       Schema
	namespaceRxs map[string]*regexp.Regexp
}

// New creates a new instance of the plugin.
func New(ctx context.Context, next http.Handler, config *Config, name string) (http.Handler, error) {
	if config.SchemaFile == "" {
		return nil, fmt.Errorf("schemaFile must be specified")
	}

	// Read and parse the schema file
	schemaData, err := os.ReadFile(config.SchemaFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read schema file %s: %v", config.SchemaFile, err)
	}

	var schema Schema
	if err := json.Unmarshal(schemaData, &schema); err != nil {
		return nil, fmt.Errorf("failed to parse schema file %s: %v", config.SchemaFile, err)
	}

	// Compile regex patterns for namespaces
	namespaceRxs := make(map[string]*regexp.Regexp)
	for nsPattern := range schema {
		rx, err := regexp.Compile(nsPattern)
		if err != nil {
			return nil, fmt.Errorf("invalid regex pattern %s: %v", nsPattern, err)
		}
		namespaceRxs[nsPattern] = rx
	}

	return &DynamicValidator{
		next:         next,
		name:         name,
		schema:       schema,
		namespaceRxs: namespaceRxs,
	}, nil
}

// ServeHTTP handles the HTTP request and validates the job specification.
func (dv *DynamicValidator) ServeHTTP(rw http.ResponseWriter, req *http.Request) {
	// Only validate POST requests to /v1/job/:job_id/plan or /v1/job/:job_id
	if req.Method != http.MethodPost ||
		(!strings.HasPrefix(req.URL.Path, "/v1/job/") || !(strings.HasSuffix(req.URL.Path, "/plan") || strings.Count(req.URL.Path, "/") == 3)) {
		dv.next.ServeHTTP(rw, req)
		return
	}

	// Read the request body
	body, err := io.ReadAll(req.Body)
	if err != nil {
		http.Error(rw, fmt.Sprintf("Failed to read request body: %v", err), http.StatusBadRequest)
		return
	}
	req.Body = io.NopCloser(bytes.NewReader(body)) // Restore body for downstream handlers

	// Parse the JSON body as a Nomad job submission
	var jobSubmission struct {
		Job *api.Job `json:"Job"`
	}
	if err := json.Unmarshal(body, &jobSubmission); err != nil {
		http.Error(rw, fmt.Sprintf("Failed to parse job JSON: %v", err), http.StatusBadRequest)
		return
	}
	if jobSubmission.Job == nil {
		http.Error(rw, "Job field missing in request body", http.StatusBadRequest)
		return
	}
	job := jobSubmission.Job

	// Get the namespace
	namespace := job.Namespace
	if *namespace == "" {
		*namespace = "default" // Nomad default namespace
	}

	// Find matching namespace regex and apply rules
	var matchedRules []Rule
	for nsPattern, rx := range dv.namespaceRxs {
		if rx.MatchString(*namespace) {
			matchedRules = dv.schema[nsPattern]
			break
		}
	}
	if len(matchedRules) == 0 {
		http.Error(rw, fmt.Sprintf("No validation rules found for namespace %s", namespace), http.StatusForbidden)
		return
	}

	// Validate job against matched rules
	for _, rule := range matchedRules {
		if strings.Contains(rule.FieldPath, "[*]") {
			// Handle wildcard paths (e.g., TaskGroups[*].Tasks[*].Config.network_mode)
			err := validateWildcardPath(job, rule.FieldPath, rule.AllowedValue)
			if err != nil {
				http.Error(rw, err.Error(), http.StatusForbidden)
				return
			}
		} else {
			// Handle specific paths
			actualValue, err := getFieldValue(job, rule.FieldPath)
			if err != nil {
				http.Error(rw, fmt.Sprintf("Failed to get field %s: %v", rule.FieldPath, err), http.StatusBadRequest)
				return
			}
			if actualValue != rule.AllowedValue {
				http.Error(rw, fmt.Sprintf("Validation failed for %s: got '%s', expected '%s'", rule.FieldPath, actualValue, rule.AllowedValue), http.StatusForbidden)
				return
			}
		}
	}

	// Validation passed, proceed to the next handler
	dv.next.ServeHTTP(rw, req)
}

// getFieldValue extracts a field value from the job specification based on the field path.
func getFieldValue(job *api.Job, fieldPath string) (string, error) {
	parts := strings.Split(fieldPath, ".")
	current := interface{}(job)

	for i, part := range parts {
		switch v := current.(type) {
		case *api.Job:
			if part == "TaskGroups" && len(v.TaskGroups) > 0 {
				current = v.TaskGroups[0]
			} else {
				return "", fmt.Errorf("invalid path at %s", part)
			}
		case *api.TaskGroup:
			if part == "Tasks" && len(v.Tasks) > 0 {
				current = v.Tasks[0]
			} else {
				return "", fmt.Errorf("invalid path at %s", part)
			}
		case *api.Task:
			if part == "Config" && v.Config != nil {
				current = v.Config
			} else {
				return "", fmt.Errorf("invalid path at %s", part)
			}
		case map[string]interface{}:
			if i == len(parts)-1 {
				if val, ok := v[part].(string); ok {
					return val, nil
				}
				return "", fmt.Errorf("field %s is not a string", part)
			}
			current = v[part]
			if current == nil {
				return "", fmt.Errorf("field %s not found", part)
			}
		default:
			return "", fmt.Errorf("unsupported type at %s", part)
		}
	}

	return "", fmt.Errorf("field path %s not resolved", fieldPath)
}

// validateWildcardPath validates all elements in a wildcard path (e.g., TaskGroups[*].Tasks[*]).
func validateWildcardPath(job *api.Job, fieldPath, allowedValue string) error {
	parts := strings.Split(fieldPath, ".")
	var currentItems []interface{}
	currentItems = append(currentItems, job)

	for i, part := range parts {
		nextItems := []interface{}{}
		isWildcard := part == "[*]"

		for _, item := range currentItems {
			switch v := item.(type) {
			case *api.Job:
				if part == "TaskGroups" {
					for _, tg := range v.TaskGroups {
						nextItems = append(nextItems, tg)
					}
				} else {
					return fmt.Errorf("invalid path at %s", part)
				}
			case *api.TaskGroup:
				if part == "Tasks" {
					for _, task := range v.Tasks {
						nextItems = append(nextItems, task)
					}
				} else {
					return fmt.Errorf("invalid path at %s", part)
				}
			case *api.Task:
				if part == "Config" && v.Config != nil {
					nextItems = append(nextItems, v.Config)
				} else {
					return fmt.Errorf("invalid path at %s", part)
				}
			case map[string]interface{}:
				if i == len(parts)-1 {
					if val, ok := v[part].(string); ok {
						if val != allowedValue {
							return fmt.Errorf("validation failed for %s: got '%s', expected '%s'", fieldPath, val, allowedValue)
						}
					} else {
						return fmt.Errorf("field %s is not a string", part)
					}
				} else {
					return fmt.Errorf("invalid path at %s", part)
				}
			default:
				return fmt.Errorf("unsupported type at %s", part)
			}
		}

		if len(nextItems) == 0 && isWildcard {
			return fmt.Errorf("no items found for wildcard %s", part)
		}
		currentItems = nextItems
	}

	return nil
}

{{ with secret "consul-ca/issue/consulcerts" (printf "common_name=%s" (env "COMMON_NAME")) "ttl=7d" "alt_names=*.nomad-simplified.local" "ip_sans=127.0.0.1" }}
{{ .Data.certificate }}
{{ end }}
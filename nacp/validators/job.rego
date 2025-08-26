package job

import future.keywords.contains
import future.keywords.if

errors contains msg if {
	input.job.Datacenters == null
	msg := "datacenters cannot be null"
}

errors contains msg if {
	some i
	input.job.Datacenters[i] == "*"
	msg := "datacenters cannot be *"
}

errors contains msg if {
	some i, j
	expected_prefix := sprintf("%s_%s", [input.job.Namespace, input.job.Name])
	task_name := input.job.TaskGroups[i].Tasks[j].Name
	not startswith(task_name, expected_prefix)
	msg := sprintf("group[%d].task[%d].name '%s' must start with prefix '%s'", [i, j, task_name, expected_prefix])
}

errors contains msg if {
	some i, j
	input.job.TaskGroups[i].Tasks[j].Driver != "docker"
	msg := sprintf("group[%d].task[%d].driver must be 'docker'", [i, j])
}

errors contains msg if {
	some i, j
	config := input.job.TaskGroups[i].Tasks[j].Config
	not config.dns_search_domains
	msg := sprintf("group[%d].task[%d].config dns_search_domains must be provided", [i, j])
}

errors contains msg if {
	some i, j
	image := input.job.TaskGroups[i].Tasks[j].Config.image
	not contains(image, ":")
	msg := sprintf("group[%d].task[%d].config.image '%s' must contain a tag after ':'", [i, j, image])
}

errors contains msg if {
	some i, j
	image := input.job.TaskGroups[i].Tasks[j].Config.image
	contains(image, ":")
	tag := split(image, ":")[1]
	tag == "latest"
	msg := sprintf("group[%d].task[%d].config.image '%s' cannot use 'latest' as tag", [i, j, image])
}

errors contains msg if {
	input.job.NodePool == "windows"
	some i, j
	config := input.job.TaskGroups[i].Tasks[j].Config
	not config.isolation
	msg := sprintf("group[%d].task[%d].config.isolation must be defined when NodePool is 'windows'", [i, j])
}

errors contains msg if {
	input.job.NodePool == "windows"
	some i, j
	input.job.TaskGroups[i].Tasks[j].Config.isolation != "process"
	msg := sprintf("group[%d].task[%d].config.isolation must be 'process' when NodePool is 'windows'", [i, j])
}

errors contains msg if {
	some i, j
	input.job.TaskGroups[i].Tasks[j].Config.network_mode != "containers"
	msg := sprintf("group[%d].task[%d].config network_mode must be 'containers'", [i, j])
}

errors contains msg if {
	some i, j
	task := input.job.TaskGroups[i].Tasks[j]
	task.Resources.Cores == 0
	task.Resources.CPU == 100
	task.Resources.MemoryMB == 300
	msg := sprintf("group[%d].task[%d] resources block must be configured", [i, j])
}

errors contains msg if {
	some i, j
	input.job.TaskGroups[i].Tasks[j].Services == null
	msg := sprintf("group[%d].task[%d].services cannot be null", [i, j])
}

errors contains msg if {
	some i, j, k
	input.job.TaskGroups[i].Tasks[j].Services[k].AddressMode != "driver"
	msg := sprintf("group[%d].task[%d].service[%d] address_mode must be 'driver'", [i, j, k])
}

errors contains msg if {
	some i, j, k
	input.job.TaskGroups[i].Tasks[j].Services[k].Provider != "nomad"
	msg := sprintf("group[%d].task[%d].service[%d] provider must be 'nomad'", [i, j, k])
}

errors contains msg if {
	some i, j
	input.job.TaskGroups[i].Networks[j].Mode != "none"
	msg := sprintf("group[%d].network[%d].mode must be 'none'", [i, j])
}

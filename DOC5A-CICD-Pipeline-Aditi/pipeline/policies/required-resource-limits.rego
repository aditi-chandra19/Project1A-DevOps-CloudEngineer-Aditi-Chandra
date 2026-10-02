package novapay.admission.required_resource_limits

import rego.v1

deny contains message if {
	input.request.kind.kind == "Pod"
	container := object.get(input.request.object.spec, "containers", [])[_]
	limits := object.get(object.get(container, "resources", {}), "limits", {})
	object.get(limits, "cpu", null) == null
	message := sprintf("container %q must define a CPU limit", [container.name])
}

deny contains message if {
	input.request.kind.kind == "Pod"
	container := object.get(input.request.object.spec, "containers", [])[_]
	limits := object.get(object.get(container, "resources", {}), "limits", {})
	object.get(limits, "memory", null) == null
	message := sprintf("container %q must define a memory limit", [container.name])
}

deny contains message if {
	input.request.kind.kind == "Pod"
	container := object.get(input.request.object.spec, "initContainers", [])[_]
	limits := object.get(object.get(container, "resources", {}), "limits", {})
	object.get(limits, "cpu", null) == null
	message := sprintf("init container %q must define a CPU limit", [container.name])
}

deny contains message if {
	input.request.kind.kind == "Pod"
	container := object.get(input.request.object.spec, "initContainers", [])[_]
	limits := object.get(object.get(container, "resources", {}), "limits", {})
	object.get(limits, "memory", null) == null
	message := sprintf("init container %q must define a memory limit", [container.name])
}

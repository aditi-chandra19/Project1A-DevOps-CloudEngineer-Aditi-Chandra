package novapay.admission.no_privileged_containers

import rego.v1

deny contains message if {
	input.request.kind.kind == "Pod"
	container := object.get(input.request.object.spec, "containers", [])[_]
	object.get(object.get(container, "securityContext", {}), "privileged", false) == true
	message := sprintf("container %q must not run privileged", [container.name])
}

deny contains message if {
	input.request.kind.kind == "Pod"
	container := object.get(input.request.object.spec, "initContainers", [])[_]
	object.get(object.get(container, "securityContext", {}), "privileged", false) == true
	message := sprintf("init container %q must not run privileged", [container.name])
}

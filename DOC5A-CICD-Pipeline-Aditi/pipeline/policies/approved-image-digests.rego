package novapay.admission.approved_image_digests

import rego.v1

approved_registry := "artifactory.novapay.example/novapay/"

valid_digest_image(image) if {
	startswith(image, approved_registry)
	parts := split(image, "@sha256:")
	count(parts) == 2
	regex.match("^[a-f0-9]{64}$", parts[1])
}

deny contains message if {
	input.request.kind.kind == "Pod"
	container := object.get(input.request.object.spec, "containers", [])[_]
	image := object.get(container, "image", "")
	not valid_digest_image(image)
	message := sprintf("container %q must use the approved registry and an immutable sha256 digest", [container.name])
}

deny contains message if {
	input.request.kind.kind == "Pod"
	container := object.get(input.request.object.spec, "initContainers", [])[_]
	image := object.get(container, "image", "")
	not valid_digest_image(image)
	message := sprintf("init container %q must use the approved registry and an immutable sha256 digest", [container.name])
}

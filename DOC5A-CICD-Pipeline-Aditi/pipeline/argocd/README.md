# Argo CD application configuration

`novapay-project.yaml` limits the NovaPay project to the assessment repository, four named namespaces, Deployments, and Services. `novapay-applicationset.yaml` generates one manually synchronized Application for each registered Argo CD cluster labelled `novapay.example/environment` as `dev`, `staging`, `preprod`, or `prod`.

Before an Application can render, its registered Argo CD cluster Secret needs these annotations:

| Annotation | Required value |
| --- | --- |
| `novapay.example/source-revision` | Reviewed Git commit SHA |
| `novapay.example/image-repository` | Approved private image repository without a tag |
| `novapay.example/blue-digest` | Scanned blue image digest in `sha256:<64 lowercase hex>` form |
| `novapay.example/green-digest` | Scanned green image digest in `sha256:<64 lowercase hex>` form |

Register clusters and private-repository credentials through the Argo CD administrator's approved process. Do not store cluster credentials, deploy keys, or tokens in this repository. Pre-create the four destination namespaces and configure environment-specific RBAC. The ApplicationSet has no automated sync policy; an authorized operator reviews and syncs each generated Application.

The project is a configuration template. No Argo CD server, cluster Secret, private image registry, repository credential, or deployed Application is configured here. The CI workflow currently retains image reports and SBOM artifacts; it does not publish an image or add these annotations. Image digests must come from a completed scan and approved registry publication before an Application can render successfully. The OPA registry allowlist is still the assessment placeholder `artifactory.novapay.example`; align it with the approved registry before admission evaluation.

The cluster generator and Go templates follow the [Argo CD ApplicationSet cluster generator documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Cluster/).

# xconfig

xconfig is an environment repository for [x](https://github.com/juanjoss/x).

This repository demostrates a CI/CD GitOps workflow using Github Actions, ArgoCD and Terraform.

## Wokflow

The workflow is based on a [Pull-based GitOps Deployment](https://www.gitops.tech/#pull-based-deployments) model.

![gitops-pull-workflow](https://www.gitops.tech/images/pull.png)

1. The `CI pipeline` configured in `x` is triggered on a push and performs the following steps:

    - Tests using the `go test` tooling.
    
    - Builds and pushes the container image to ghcr using Docker.
    
    - Scans the container image.

    - Signs the image using cosign.

    - Updates the kubernetes manifests files inside `xconfig` using kustomize.

2. The `CD pipeline` configured in `xconfig` is triggered by the changes made by the CI pipeline and it will perform two main jobs:

    - Provision a GKE cluster inside GCP using Terraform.

    - Setup ArgoCD, sync with `xconfig` and deploy `x` inside the cluster.
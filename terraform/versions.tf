terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "4.27.0"
        }

        helm = {
            source  = "hashicorp/helm"
            version = "~> 2.7.1"
        }
    }

    required_version = ">= 0.14"
}
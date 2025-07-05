# Self_learning_HealthCareBigData

This repository contains notebooks and scripts used to experiment with loading Synthea-generated FHIR bundles into a HAPI-FHIR server.

Two Docker configurations are provided:

1. **PostgreSQL-backed** (`docker-compose.yml`) – recommended for large imports.
2. **H2 file-backed** (`docker-compose-h2.yml`) – data persists on disk so the container can be restarted to free memory. This compose file now runs the container as root and includes a health check to avoid permission issues on the volume.

Use the PowerShell script `upload_fhir_files.ps1` to upload bundles. Large bundles are skipped by default and uploads run in parallel.


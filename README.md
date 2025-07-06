# Self_learning_HealthCareBigData

This repository contains notebooks and scripts used to experiment with loading Synthea-generated FHIR bundles into a HAPI-FHIR server.

Two Docker configurations are provided:

1. **PostgreSQL-backed** (`docker-compose.yml`) – recommended for large imports.
2. **H2 file-backed** (`docker-compose-h2.yml`) – data persists on disk so the container can be restarted to free memory.

Use the PowerShell script `upload_fhir_files.ps1` to upload bundles. Large bundles are skipped by default and uploads run in parallel.


## Postman Examples

The `postman/` directory contains an exported environment (`fhir_dev.postman_environment.json`) and a collection demonstrating five basic FHIR CRUD operations. The same requests are mirrored in `2025-06-30_postman.ipynb` using cURL commands.

Additional notes about the calls can be found in `notes/2025-06-30_postman.md`.

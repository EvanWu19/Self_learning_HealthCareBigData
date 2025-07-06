# Self_learning_HealthCareBigData

This repository contains notebooks and scripts used to experiment with loading Synthea-generated FHIR bundles into a HAPI-FHIR server.

Two Docker configurations are provided:

1. **PostgreSQL-backed** (`docker-compose.yml`) – recommended for large imports.
2. **H2 file-backed** (`docker-compose-h2.yml`) – data persists on disk so the container can be restarted to free memory.

Use the PowerShell script `upload_fhir_files.ps1` to upload bundles. Large bundles are skipped by default and uploads run in parallel.

## Prerequisites
- Windows 10/11 with [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [PowerShell 7](https://aka.ms/powershell) or newer
- [Git for Windows](https://gitforwindows.org/) for cloning the repository
- Java 17 in your `PATH` for running Synthea
- VS Code or Jupyter to execute the notebooks

## Start the Docker stack
Open a PowerShell terminal in this folder.

To use PostgreSQL:
```powershell
docker compose down          # stop and remove old containers
docker compose pull          # fetch images
docker compose up -d         # start stack
docker compose logs -f hapi  # wait for "Started Application"
```

For the on-disk H2 option:
```powershell
docker compose -f docker-compose-h2.yml up -d
```
You can stop and restart this container to free memory while keeping the `hapi-data` volume.

## Run the notebooks
Execute the notebooks in order:
1. `01_synthea_setup.ipynb` – build Synthea and generate patient bundles
2. `02_hapi_fhir_server_setup_powershell.ipynb` – start the HAPI‑FHIR server and verify it is running
3. `02_hapi_fhir_synthea_load_powershell.ipynb` – upload bundles using PowerShell
4. `03_synthea_data_load.ipynb` – alternative example that also logs with PowerShell

## Upload FHIR bundles
`upload_fhir_files.ps1` reads JSON bundles from `$BUNDLE_DIR` and posts them to `$FHIR_BASE`.
```powershell
$env:BUNDLE_DIR = 'C:\synthea_out\fhir'        # path to your Synthea export
$env:FHIR_BASE  = 'http://localhost:8080/fhir/'  # KEEP the trailing slash

pwsh -ExecutionPolicy Bypass -File .\upload_fhir_files.ps1 -Throttle 4 |
  Tee-Object -FilePath upload_log.txt
```
`$MaxSizeMB` and `$Throttle` can be passed as parameters. The script modifies `$env:PSModulePath` so it can be run from any location.

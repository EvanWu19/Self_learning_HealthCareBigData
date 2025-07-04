# upload_fhir_files.ps1
#───────────────────────────────────────────────────────────────────────
# Requires PowerShell 7 or newer
# Parse-time checks:
#   • Ensures script is run with pwsh 7+
#   • Adds a –Test N switch (optional)

#requires -Version 7.0

param(
    [int]$Test = 0          # e.g.  pwsh .\upload_fhir_files.ps1 -Test 20
)

#── USER CONFIG ────────────────────────────────────────────────────────
$BUNDLE_DIR = '//Desktop-family/K/synthea_out/fhir'          # adjust as needed
$FHIR_BASE  = 'http://localhost:8080/fhir/'  # KEEP the trailing slash
$Throttle   = 1                             # parallel workers to start

# Make this script’s folder a module location (so runspaces see it)
$env:PSModulePath = "$PSScriptRoot;$env:PSModulePath"

#── TIMER & COUNTERS ───────────────────────────────────────────────────
$startTime = Get-Date
$success   = 0
$failure   = 0

#── GATHER FILES ───────────────────────────────────────────────────────
$files = Get-ChildItem -Path $BUNDLE_DIR -Filter *.json
if ($Test -gt 0) { $files = $files | Select-Object -First $Test }

#── MAIN PARALLEL LOOP ─────────────────────────────────────────────────
$tally = $files | ForEach-Object -Parallel {
    function Send-Bundle {
    param([string]$Path,[string]$Uri)

    $resp = curl.exe -s -o NUL `
            -w "%{http_code}|%{time_total}|%{errormsg}" `
            -H "Content-Type: application/fhir+json" `
            --data-binary "@$Path" $Uri 2>&1

    $parts = $resp -split '\|'
    $code  = [int]$parts[0]
    $time  = ('{0:N1}' -f [double]$parts[1])
    $err   = $parts[2]

        if ($code -ge 200 -and $code -lt 300) {
            Write-Host "OK    $(Split-Path $Path -Leaf) → $code in ${time}s" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAIL  $(Split-Path $Path -Leaf) → $code ($err)"      -ForegroundColor Red
            return $false
        }
    }

    if (Send-Bundle -Path $_.FullName -Uri $using:FHIR_BASE) { 1 } else { 0 }

} -ThrottleLimit $Throttle

#── COUNT RESULTS ──────────────────────────────────────────────────────
$success = ($tally | Where-Object { $_ -eq 1 }).Count
$failure = ($tally | Where-Object { $_ -eq 0 }).Count

#── SUMMARY ────────────────────────────────────────────────────────────
$duration = (Get-Date) - $startTime
Write-Host "`nUpload complete!"
Write-Host "Files processed: $($success + $failure)"
Write-Host "Successful    : $success"
Write-Host "Failed        : $failure"
Write-Host ("Total time    : {0:N1} minutes" -f $duration.TotalMinutes)

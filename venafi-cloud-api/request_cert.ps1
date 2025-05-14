# request_cert.ps1

Import-Module VenafiPS

$ErrorActionPreference = 'Stop'

# Configuration
$APIKey     = $env:VCERT_APIKEY
$Region     = "eu"
$APP        = "tls-demo-venafi-1"
$Template   = "Default"
$CN         = "tls-demo-venafi-ps.vchatela.local"

# Resolve paths
$ScriptDir     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ArtefactsDir  = Join-Path $ScriptDir "artefacts"
$CertFile      = Join-Path $ArtefactsDir "venafips-cert.pem"
$ChainFile     = Join-Path $ArtefactsDir "venafips-chain.pem"

# Ensure artefacts folder exists
New-Item -ItemType Directory -Path $ArtefactsDir -Force | Out-Null

# Check API key
if (-not $APIKey) {
    Write-Error "VCERT_APIKEY environment variable is not set"
    exit 1
}

# Step 1: Connect to Venafi Cloud
Write-Host "[INFO] Connecting to Venafi Cloud..."
New-VenafiSession -VcKey $APIKey -VcRegion $Region

# Step 2: Request certificate (Venafi will generate key)
Write-Host "[INFO] Requesting certificate for CN: $CN..."
$Request = New-VcCertificate -Application $APP -IssuingTemplate $Template -CommonName $CN

# Step 3: Save certificate and chain
Set-Content -Path $CertFile -Value $Request.CertificatePEM
Set-Content -Path $ChainFile -Value $Request.ChainPEM

Write-Host "`n✅ Certificate issued and saved:"
Write-Host "- Cert:  $CertFile"
Write-Host "- Chain: $ChainFile"

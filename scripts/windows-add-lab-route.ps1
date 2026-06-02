# =============================================================================
# windows-add-lab-route.ps1
# Ajoute la route statique persistante vers le réseau lab du homelab
#
# Usage : exécuter en PowerShell ADMINISTRATEUR
#   .\windows-add-lab-route.ps1
#
# La route ajoutée : 10.20.0.0/24 via 192.168.1.50 (pfSense WAN)
# =============================================================================

$LabNetwork  = "10.20.0.0"
$LabMask     = "255.255.255.0"
$Gateway     = "192.168.1.50"  # IP WAN de pfSense

# -----------------------------------------------------------------------------
# Vérifier les droits administrateur
# -----------------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "ERREUR : Ce script doit etre execute en tant qu'Administrateur." -ForegroundColor Red
    Write-Host "Clic droit sur PowerShell → Executer en tant qu'administrateur" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  Route Homelab MATOTO — Lab 10.20.0.0/24"           -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# -----------------------------------------------------------------------------
# Vérifier la connectivité vers pfSense
# -----------------------------------------------------------------------------
Write-Host "[1/3] Verification connectivite vers pfSense ($Gateway)..." -ForegroundColor Yellow
$pingResult = Test-Connection -ComputerName $Gateway -Count 1 -Quiet -ErrorAction SilentlyContinue
if ($pingResult) {
    Write-Host "  → pfSense accessible ($Gateway)" -ForegroundColor Green
} else {
    Write-Host "  AVERTISSEMENT : pfSense ($Gateway) ne repond pas au ping." -ForegroundColor Yellow
    Write-Host "  Verifier que pfSense est demarré et que l'IP WAN est bien $Gateway" -ForegroundColor Yellow
    Write-Host "  La route sera ajoutee quand meme." -ForegroundColor Yellow
}

# -----------------------------------------------------------------------------
# Supprimer la route existante si elle existe (pour idempotence)
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "[2/3] Ajout de la route persistante..." -ForegroundColor Yellow

$existingRoute = Get-NetRoute -DestinationPrefix "$LabNetwork/24" -ErrorAction SilentlyContinue
if ($existingRoute) {
    Write-Host "  → Route existante detectee, suppression..." -ForegroundColor Yellow
    Remove-NetRoute -DestinationPrefix "$LabNetwork/24" -Confirm:$false -ErrorAction SilentlyContinue
}

# Ajouter la route (-p = persistante, survit aux redémarrages)
try {
    route add $LabNetwork mask $LabMask $Gateway -p | Out-Null
    Write-Host "  → Route ajoutee avec succes" -ForegroundColor Green
    Write-Host "    $LabNetwork/$LabMask  via  $Gateway  [persistante]" -ForegroundColor Green
} catch {
    Write-Host "  ERREUR lors de l'ajout de la route : $_" -ForegroundColor Red
    exit 1
}

# -----------------------------------------------------------------------------
# Afficher la route ajoutée
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "[3/3] Verification..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Table de routage (filtre 10.20.x.x) :" -ForegroundColor Cyan
route print $LabNetwork

# -----------------------------------------------------------------------------
# Test de connectivité
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Test de connectivite vers le reseau lab :" -ForegroundColor Yellow

$hosts = @{
    "pfSense LAN"    = "10.20.0.1"
    "srv-02 (Docker)" = "10.20.0.20"
    "nas-01 (TrueNAS)" = "10.20.0.30"
    "dns-01 (Pi-hole)" = "10.20.0.40"
}

foreach ($name in $hosts.Keys) {
    $ip = $hosts[$name]
    $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($ping) {
        Write-Host "  [OK]  $name ($ip)" -ForegroundColor Green
    } else {
        Write-Host "  [--]  $name ($ip) — non accessible (machine demarree ?)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  Route configuree. Acces au lab operationnel."       -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour supprimer la route : route delete $LabNetwork" -ForegroundColor Gray
Write-Host ""

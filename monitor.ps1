# === CONFIGURATION SMTP ===
$emailSettings = @{
    SMTPServer = "smtp.tonserveur.com"
    SMTPPort   = 587
    UseSSL     = $true
    From       = "noreply@tondomaine.com"
    To         = "admin@tondomaine.com"
    Subject    = "[ALERTE] Service NinjaRMM HS"
    Credential = $null  # Exemple : Get-Credential si n�cessaire
}

# === CONFIGURATION G�N�RALE ===
$logDir = "C:\ProgramData\NinjaAgentMonitor\logs"
$logFile = "$logDir\monitor.log"
$errorTrackFile = "$logDir\error_counts.json"
$services = @{
    "NinjaRMMAgent" = "NinjaRMMAgent"
    "NinjaVMAgent"  = "NinjaRMM VM monitoring agent"
}

# === INITIALISATION ===
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory | Out-Null }

# Charger les erreurs pr�c�dentes (et corriger le type)
$errorCounts = @{}
if (Test-Path $errorTrackFile) {
    try {
        $raw = Get-Content $errorTrackFile | ConvertFrom-Json
        foreach ($k in $raw.PSObject.Properties.Name) {
            $errorCounts[$k] = $raw.$k
        }
    } catch {
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [ERREUR] Impossible de charger les erreurs pr�c�dentes : $_"
    }
}

# === ENVOI DE MAIL ===
function Send-AlertMail($svcName, $displayName) {
    $body = @"
Service : $displayName
Nom syst�me : $svcName
Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Ce service a �chou� � d�marrer 3 fois de suite.
Une intervention manuelle est peut-�tre requise.
"@

    try {
        Send-MailMessage -SmtpServer $emailSettings.SMTPServer `
                         -Port $emailSettings.SMTPPort `
                         -UseSsl:$emailSettings.UseSSL `
                         -From $emailSettings.From `
                         -To $emailSettings.To `
                         -Subject $emailSettings.Subject `
                         -Body $body `
                         -Credential $emailSettings.Credential
    } catch {
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [ERREUR] Envoi de mail �chou� : $_"
    }
}

# === SURVEILLANCE DES SERVICES ===
foreach ($svcName in $services.Keys) {
    $displayName = $services[$svcName]
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue

    if ($null -eq $svc) {
        Add-Content -Path $logFile -Value "$timestamp - [ERREUR] Service '$svcName' introuvable."
        continue
    }

    if ($svc.Status -ne 'Running') {
        Add-Content -Path $logFile -Value "$timestamp - [AVERTISSEMENT] $displayName est '$($svc.Status)'. Tentative de red�marrage..."

        try {
            Start-Service -Name $svcName -ErrorAction Stop
            Add-Content -Path $logFile -Value "$timestamp - [INFO] $displayName red�marr� avec succ�s."
            $errorCounts[$svcName] = 0
        }
        catch {
            Add-Content -Path $logFile -Value "$timestamp - [ERREUR] �chec red�marrage $displayName : $_"
            if (-not $errorCounts.ContainsKey($svcName)) { $errorCounts[$svcName] = 0 }
            $errorCounts[$svcName]++

            if ($errorCounts[$svcName] -eq 3) {
                Add-Content -Path $logFile -Value "$timestamp - [CRITIQUE] $displayName a �chou� 3 fois. Envoi d'une alerte mail."
                Send-AlertMail -svcName $svcName -displayName $displayName
            }
        }
    }
    else {
        Add-Content -Path $logFile -Value "$timestamp - [OK] $displayName fonctionne normalement."
        $errorCounts[$svcName] = 0
    }
}

# === SAUVEGARDE DU FICHIER D'�TAT ===
$errorCounts | ConvertTo-Json -Depth 3 | Out-File $errorTrackFile -Force

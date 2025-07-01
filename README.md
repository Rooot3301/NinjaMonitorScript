# NinjaMonitorScript

Ce dépôt contient le script `monitor.ps1` permettant de surveiller et redémarrer automatiquement les services :

- `NinjaRMMAgent`
- `NinjaVMAgent`

Fonctionnalités :
- Redémarrage automatique si plantage
- Logs détaillés dans `C:\ProgramData\NinjaAgentMonitor\logs`
- Notification e-mail après 3 échecs consécutifs
- Déploiement facile via tâche planifiée

## Déploiement

Téléchargez et exécutez le script suivant sur vos postes :

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Rooot3301/NinjaMonitorScript/main/DeployMonitor.ps1" -OutFile "$env:TEMP\DeployMonitor.ps1"
powershell.exe -ExecutionPolicy Bypass -File "$env:TEMP\DeployMonitor.ps1"


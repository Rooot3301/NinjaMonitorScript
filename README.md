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
Invoke-WebRequest -Uri "https://github.com/Rooot3301/NinjaMonitorScript/blob/main/monitor.ps1" -OutFile "C:\ProgramData\NinjaAgentMonitor\monitor.ps1"


# DeployMonitor.ps1

$scriptUrl = "https://raw.githubusercontent.com/Rooot3301/NinjaMonitorScript/main/monitor.ps1"
$localDir = "C:\ProgramData\NinjaAgentMonitor"
$localScript = "$localDir\monitor.ps1"
$taskName = "NinjaAgentMonitor"

New-Item -Path $localDir -ItemType Directory -Force | Out-Null

Invoke-WebRequest -Uri $scriptUrl -OutFile $localScript -UseBasicParsing

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$localScript`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration (New-TimeSpan -Days 365)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force

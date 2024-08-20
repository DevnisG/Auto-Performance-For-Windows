# Solicitar UAC al Usuario (Privilegios de Administrador)  - Esto es necesario ya que el Script debe tener permisos
# para realizar la optimizacion, y poder eliminar archivos con normalidad.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
 
#########
# UI PERSONALIZADA
#########
Write-Host " ========================================================= " -ForegroundColor Black -BackgroundColor Green
Write-Host " =  BIENVENIDO AL ASISTENTE DE OPTIMIZACION DE WINDOWS   = " -ForegroundColor Black -BackgroundColor Green
Write-Host " ========================================================= " -ForegroundColor Black -BackgroundColor Green
Write-Host " =                                                       = "
Write-Host " = - Optimiza el Equipo.                                 = " 
Write-Host " =                                                       = "
Write-Host " = - Elimina Blothware de Microsoft.                     = " 
Write-Host " =                                                       = "
Write-Host " = - Deshabilita Cortana.                                = "
Write-Host " =                                                       = "
Write-Host " = - Deshabilita Bing Box del Buscador.                  = "
Write-Host " =                                                       = "
Write-Host " = - Activa el Firewall de Windows.                      = "
Write-Host " =                                                       = "
Write-Host " = - Activa Windows Defender.                            = "
Write-Host " =                                                       = "
Write-Host " =                             Edit by_ Denis.G (Devnis) = "
Write-Host " =                                                       = "
Write-Host " ========================================================= " -ForegroundColor Black -BackgroundColor Green
Write-Host " =  Presiona una tecla para iniciar la optimizacion...   = " -ForegroundColor Black -BackgroundColor Green
Write-Host " ========================================================= " -ForegroundColor Black -BackgroundColor Green
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

##########
# Opciones de Privacidad
##########
 
# Deshabilitar Telemetria.
Write-Host "Deshabilitando Telemetria..."
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

# Deshabilitar Compartir Wifi.
Write-Host "Deshabilitando Compartir Wi-Fi..."
If (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
    New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0

# Deshabilitar Bing del buscador de Windows.
Write-Host "Deshabilitando Bing del Buscador..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0

# Deshabilitar Seguimiento de Ubicacion.
Write-Host "Deshabilitando Seguimiento de Ubicacion..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0

# Deshabilitar Feedback MS.
Write-Host "Deshabilitando Feedback..."
If (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
    New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0

# Deshabilitar Rastreadores ID.
Write-Host "Deshabilitando Rastreador de ID..."
If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

# Deshabilitar Cortana.
Write-Host "Deshabilitando Cortana..."
If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
    New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization")) {
    New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
    New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0

# Eliminar AutoLogger.
Write-Host "Deteniendo AutoLogger..."
$autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
    Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
}
icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null

# Detener Servicios de Tracking.
Write-Host "Deteniendo Servicio de Rastreo..."
Stop-Service "DiagTrack"
Set-Service "DiagTrack" -StartupType Disabled
 
# Detener Servicios WAP.
Write-Host "Deteniendo servicio WAP..."
Stop-Service "dmwappushservice"
Set-Service "dmwappushservice" -StartupType Disabled

##########
# Optimizaciones de Servicios.
##########
 
# Activar Windows Firewall (Recomendado).
Set-NetFirewallProfile -Profile * -Enabled True
 
# Activar Windows Defender - (Recomendado).
Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware"

##########
# Optimizaciones de UI
##########
 
# Deshabilitar el bloqueo de pantalla.
Write-Host "Deshabilitar el bloqueo de pantalla..."
If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization")) {
  New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" | Out-Null
}
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 1

# Activar la vista de extenciones para los archivos.
Write-Host "Activando Vista de extenciones para archivos..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0

##########
# Desinstalar Apps De Windows Base.
##########

# Desinstlar One Drive.
Write-Host "Desinstlando OneDrive..."
Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
Start-Sleep -s 3
$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
If (!(Test-Path $onedrive)) {
    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
}
Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
Start-Sleep -s 3
Stop-Process -Name explorer -ErrorAction SilentlyContinue
Start-Sleep -s 3
Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
    Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
}
If (!(Test-Path "HKCR:")) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}
Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
 
# Desinstalar Aplicaciones Basura de MS.
Write-Host "Desinstalando aplicaciones basura de Windows..."
Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage
Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage
Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage
Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage
Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage
Get-AppxPackage "Microsoft.Getstarted" | Remove-AppxPackage
Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage
Get-AppxPackage "Microsoft.People" | Remove-AppxPackage
Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage
Get-AppxPackage "microsoft.windowscommunicationsapps" | Remove-AppxPackage
Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage
Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
Get-AppxPackage "Microsoft.ZuneMusic" | Remove-AppxPackage
Get-AppxPackage "Microsoft.ZuneVideo" | Remove-AppxPackage
Get-AppxPackage "Microsoft.AppConnector" | Remove-AppxPackage
Get-AppxPackage "Microsoft.ConnectivityStore" | Remove-AppxPackage
Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage
Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage
Get-AppxPackage "Microsoft.CommsPhone" | Remove-AppxPackage
Get-AppxPackage "9E2F88E3.Twitter" | Remove-AppxPackage
Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
 
# Desinstalar Cortana.
echo Desinstalando Cortana...
& $scriptDir\install_wim_tweak.exe /o /l
& $scriptDir\install_wim_tweak.exe /o /c Microsoft-Windows-Cortana /r
& $scriptDir\install_wim_tweak.exe /h /o /l

# Quitar fondo de pantalla.
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'Wallpaper' -Value ''
RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters
Set-ItemProperty -Path 'HKCU:\Control Panel\Colors' -Name 'Background' -Value '0 0 0'

# Aplicar 0ms al Delay de Inicio.
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}
Set-ItemProperty -Path $registryPath -Name "StartupDelayInMSec" -Value 0 -Force

# Activar Performance > Facha.
$performanceKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
$settingsKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

Set-ItemProperty -Path $performanceKey -Name "VisualFXSetting" -Value 2
Set-ItemProperty -Path $settingsKey -Name "ListviewAlphaSelect" -Value 0
Set-ItemProperty -Path $settingsKey -Name "TaskbarAnimations" -Value 0
Set-ItemProperty -Path $settingsKey -Name "ListviewShadow" -Value 0
Set-ItemProperty -Path $settingsKey -Name "MenuAnimations" -Value 0
Set-ItemProperty -Path $settingsKey -Name "ListviewWatermark" -Value 0
Set-ItemProperty -Path $settingsKey -Name "ComboBoxAnimation" -Value 0
Set-ItemProperty -Path $settingsKey -Name "CursorShadow" -Value 0
Set-ItemProperty -Path $settingsKey -Name "DragFullWindows" -Value 0
Set-ItemProperty -Path $settingsKey -Name "FontSmoothing" -Value 0
Set-ItemProperty -Path $settingsKey -Name "ShowSounds" -Value 0
Set-ItemProperty -Path $settingsKey -Name "SmoothScroll" -Value 0
Set-ItemProperty -Path $settingsKey -Name "ThemeActive" -Value 0
Set-ItemProperty -Path $settingsKey -Name "Wallpaper" -Value 0
Set-ItemProperty -Path $settingsKey -Name "WebView" -Value 0
Set-ItemProperty -Path $settingsKey -Name "WindowAlphaChannel" -Value 0
Set-ItemProperty -Path $settingsKey -Name "WindowAnimations" -Value 0
RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters

##########
# Reinicio.
##########
Write-Host
Write-Host "Presiona cualquier tecla para reiniciar..." -ForegroundColor Black -BackgroundColor White
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Reiniciando..."
Restart-Computer

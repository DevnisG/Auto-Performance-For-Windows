# Solicitar UAC al Usuario (Privilegios de Administrador) - Necesario para revertir las optimizaciones.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

#########
# UI PERSONALIZADA
#########
Write-Host " ========================================================= " -ForegroundColor Black -BackgroundColor Red
Write-Host " =  BIENVENIDO AL ASISTENTE DE REVERSION DE OPTIMIZACION = " -ForegroundColor Black -BackgroundColor Red
Write-Host " ========================================================= " -ForegroundColor Black -BackgroundColor Red
Write-Host " =                                                       = "
Write-Host " = - Revertir optimizacion del equipo.                   = " 
Write-Host " =                                                       = "
Write-Host " = - Restaurar Bloware de Microsoft.                     = " 
Write-Host " =                                                       = "
Write-Host " = - Habilitar Cortana.                                  = "
Write-Host " =                                                       = "
Write-Host " = - Habilitar Bing Box del Buscador.                    = "
Write-Host " =                                                       = "
Write-Host " = - Activar el Firewall de Windows.                     = "
Write-Host " =                                                       = "
Write-Host " = - Activar Windows Defender.                           = "
Write-Host " =                                                       = "
Write-Host " =                             Edit by_ Denis.G (Devnis) = "
Write-Host " =                                                       = "
Write-Host " ========================================================= " -ForegroundColor Black -BackgroundColor Red
Write-Host " =  Presiona una tecla para aplicar la Cura...           = " -ForegroundColor Black -BackgroundColor Red
Write-Host " ========================================================= " -ForegroundColor Black -BackgroundColor Red
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

##########
# Revertir Opciones de Privacidad
##########

# Habilitar Telemetría
Write-Host "Habilitando Telemetría..."
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 1

# Habilitar Compartir Wi-Fi
Write-Host "Habilitando Compartir Wi-Fi..."
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 1

# Habilitar Bing del buscador de Windows
Write-Host "Habilitando Bing del Buscador..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 1

# Habilitar Seguimiento de Ubicación
Write-Host "Habilitando Seguimiento de Ubicación..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 1

# Habilitar Feedback MS
Write-Host "Habilitando Feedback..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 1

# Habilitar Rastreadores ID
Write-Host "Habilitando Rastreador de ID..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 1

# Habilitar Cortana
Write-Host "Habilitando Cortana..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 1

# Restaurar AutoLogger
Write-Host "Restaurando AutoLogger..."
icacls $autoLoggerDir /remove:d SYSTEM | Out-Null

# Habilitar Servicios de Tracking
Write-Host "Habilitando Servicio de Rastreo..."
Set-Service "DiagTrack" -StartupType Automatic
Start-Service "DiagTrack"
 
# Habilitar Servicios WAP 
Write-Host "Habilitando servicio WAP..."
Set-Service "dmwappushservice" -StartupType Automatic
Start-Service "dmwappushservice"

##########
# Revertir Optimizaciones de Servicios
##########

# Activar Windows Firewall (Recomendado).
Set-NetFirewallProfile -Profile * -Enabled True
 
# Activar Windows Defender - (Recomendado).
Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware"

##########
# Revertir Optimizaciones de UI
##########

# Habilitar el bloqueo de pantalla.
Write-Host "Habilitando el bloqueo de pantalla..."
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 0

# Desactivar la vista de extensiones para los archivos.
Write-Host "Desactivando vista de extensiones para archivos..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1

##########
# Reinstalar Apps De Windows Base.
##########

# Reinstalar OneDrive
Write-Host "Reinstalando OneDrive..."
$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
If (!(Test-Path $onedrive)) {
    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
}
Start-Process $onedrive -NoNewWindow -Wait

# Reinstalar Aplicaciones Basura de MS.
Write-Host "Reinstalando aplicaciones de Windows..."
Get-AppxPackage -AllUsers | Foreach {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}

# Reinstalar Cortana.
Write-Host "Reinstalando Cortana..."
Get-AppxPackage -AllUsers Microsoft.549981C3F5F10 | Foreach {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}
# Restaurar el fondo de pantalla predeterminado.
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'Wallpaper' -Value '%SystemRoot%\web\wallpaper\Windows\img0.jpg'
RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters

# Eliminar la clave del Delay de Inicio.
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
if (Test-Path $registryPath) {
    Remove-ItemProperty -Path $registryPath -Name "StartupDelayInMSec" -Force
}

# Restaurar las opciones de rendimiento.
$performanceKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
$settingsKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

Set-ItemProperty -Path $performanceKey -Name "VisualFXSetting" -Value 0
Set-ItemProperty -Path $settingsKey -Name "ListviewAlphaSelect" -Value 1
Set-ItemProperty -Path $settingsKey -Name "TaskbarAnimations" -Value 1
Set-ItemProperty -Path $settingsKey -Name "ListviewShadow" -Value 1
Set-ItemProperty -Path $settingsKey -Name "MenuAnimations" -Value 1
Set-ItemProperty -Path $settingsKey -Name "ListviewWatermark" -Value 1
Set-ItemProperty -Path $settingsKey -Name "ComboBoxAnimation" -Value 1
Set-ItemProperty -Path $settingsKey -Name "CursorShadow" -Value 1
Set-ItemProperty -Path $settingsKey -Name "DragFullWindows" -Value 1
Set-ItemProperty -Path $settingsKey -Name "FontSmoothing" -Value 2
Set-ItemProperty -Path $settingsKey -Name "ShowSounds" -Value 0
Set-ItemProperty -Path $settingsKey -Name "SmoothScroll" -Value 1
Set-ItemProperty -Path $settingsKey -Name "ThemeActive" -Value 1
Set-ItemProperty -Path $settingsKey -Name "Wallpaper" -Value '%SystemRoot%\web\wallpaper\Windows\img0.jpg'
Set-ItemProperty -Path $settingsKey -Name "WebView" -Value 1
Set-ItemProperty -Path $settingsKey -Name "WindowAlphaChannel" -Value 1
Set-ItemProperty -Path $settingsKey -Name "WindowAnimations" -Value 1
RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters

##########
# Reinicio.
##########
Write-Host
Write-Host "Presiona cualquier tecla para reiniciar..." -ForegroundColor Black -BackgroundColor White
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Reiniciando..."
Restart-Computer

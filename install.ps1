# Settings
$region = "europe"
$datacenter = "europe-1"
$version = "20250723-13"
$serverIP = "192.168.8.119"

# Download and extract
$ProgressPreference = 'SilentlyContinue'
$url = "https://github.com/olljanat/nomad-simplified/releases/download/$($version)/nomad-windows.zip"
Invoke-WebRequest $url -UseBasicParsing -OutFile "C:\Windows\Temp\nomad-simplified.zip"
Expand-Archive -Path "C:\Windows\Temp\nomad-simplified.zip" -DestinationPath "C:\" -Force
Remove-Item "C:\Windows\Temp\nomad-simplified.zip" -Force

# Register service
New-Service -Name "nomad" `
  -DisplayName "HashiCorp Nomad" `
  -BinaryPathName "c:\bin\nomad.exe agent -client -config c:\etc\nomad.d -region=$region -dc=$datacenter -node-pool=windows" `
  -StartupType Automatic

# Increase the non-interactive desktop heap size
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems" -Name "SharedSection" -Value "1024,20480,768"

# Update environment variables
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;c:\bin", "Machine")


# TODO: Add configs and certs here!!!

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

# Trust CA certificates
Import-Certificate -FilePath 'c:\opt\tls\nomad-agent-ca.pem' -CertStoreLocation cert:LocalMachine\Root

# Register service
New-Service -Name "nomad" `
  -DisplayName "HashiCorp Nomad" `
  -BinaryPathName "c:\bin\nomad.exe agent -client -config c:\etc\nomad.d -region=$region -dc=$datacenter -node-pool=$version" `
  -StartupType Automatic

# Make Nomad service depend on of Docker service
## Please note that you need reboot server before this is effective.
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\nomad" `
  -Name DependOnService -Type MultiString -Value @("docker")

# Increase the non-interactive desktop heap size
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems" -Name "SharedSection" -Value "1024,20480,768"

# Update environment variables
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;c:\bin", "Machine")
[Environment]::SetEnvironmentVariable("NOMAD_ADDR", "https://127.0.0.1:4646", "Machine")
[Environment]::SetEnvironmentVariable("NOMAD_SKIP_VERIFY", "true", "Machine")

# Start Nomad service and register to server
Start-Service -Name nomad
$env:NOMAD_ADDR="https://127.0.0.1:4646"
$env:NOMAD_SKIP_VERIFY="true"
c:\bin\nomad.exe node config -update-servers $serverIP


Restart-Computer

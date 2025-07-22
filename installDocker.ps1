Write-Host "Install Containers and Hyper-V support"
$ProgressPreference='SilentlyContinue'
Enable-WindowsOptionalFeature -All -Online -FeatureName Containers -NoRestart
Enable-WindowsOptionalFeature -All -Online -FeatureName Hyper-V -NoRestart

Write-Host "Install Docker"
$ProgressPreference='SilentlyContinue'
Enable-WindowsOptionalFeature -All -Online -FeatureName Containers -NoRestart
$dockerURL="https://download.docker.com/win/static/stable/x86_64/docker-28.3.3.zip"
Invoke-WebRequest $dockerURL -UseBasicParsing -OutFile C:\Windows\Temp\docker.zip
Expand-Archive -Path C:\Windows\Temp\docker.zip -DestinationPath "C:\Program Files\"
Start-Process -FilePath "C:\Program Files\Docker\dockerd.exe" -ArgumentList "--register-service" -Wait -NoNewWindow
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\docker -Name DependOnService -Type MultiString -Value @("hns","vmcompute")
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;C:\Program Files\Docker", "Machine")

Write-Host "Install Containerd"
$containerdURL="https://github.com/containerd/containerd/releases/download/v1.7.28/cri-containerd-cni-1.7.28-windows-amd64.tar.gz"
Invoke-WebRequest $containerdURL -UseBasicParsing -OutFile C:\Windows\Temp\containerd.tar.gz
tar -xzf C:\Windows\Temp\containerd.tar.gz -C "C:\Program Files\docker"

Write-Host "Install Buildx"
New-Item -Type Directory -Path "C:\ProgramData\Docker\cli-plugins" -Force
$BuildxURL="https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.windows-amd64.exe"
Invoke-WebRequest $BuildxURL -UseBasicParsing -OutFile "C:\ProgramData\Docker\cli-plugins\docker-buildx.exe"
[Environment]::SetEnvironmentVariable("DOCKER_BUILDKIT", "1", "Machine")

Write-Host "Writing daemon.json"
New-Item -ItemType Directory C:\ProgramData\docker\config
$daemonConfig = @{
"bridge" = "none"
"default-runtime" = "io.containerd.runhcs.v1"
"features" = @{ "containerd-snapshotter" = $true }
"exec-opts" = @( "isolation=hyperv" )
"hosts" = @( "npipe://" )
"registry-mirrors" = @("https://docker-hub-mirror-1.example.com:5000", "https://docker-hub-mirror-2.example.com:5000")
}
$daemonConfigJSON = $daemonConfig | ConvertTo-Json -Depth 99
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines("C:\ProgramData\docker\config\daemon.json", $daemonConfigJSON, $Utf8NoBomEncoding)

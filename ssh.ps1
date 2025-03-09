# Importar funciones de utils
. .\utils.ps1

Function installSsh {
    PrintMessage "info" "Instalando servicio SSH..."
    enableFirewallRules
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    PrintMessage "success" "Servicio SSH instalado y configurado para iniciarse automáticamente."
}

Function SshConfig {
    param (
        [string]$Port = "22",
        [string]$AllowRootLogin = "no",
        [string]$PasswordAuthentication = "yes"
    )

    $configPath = "C:\ProgramData\ssh\sshd_config"
    (Get-Content $configPath) |
        ForEach-Object {
            if ($_ -match "^#?Port") { "Port $Port" }
            elseif ($_ -match "^#?PermitRootLogin") { "PermitRootLogin $AllowRootLogin" }
            elseif ($_ -match "^#?PasswordAuthentication") { "PasswordAuthentication $PasswordAuthentication" }
            else { $_ }
        } | Set-Content $configPath

    Restart-Service sshd
    PrintMessage "info" "Estado del servicio SSH:"
    Get-Service sshd
}

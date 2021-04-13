#Get list of roles and run required discovery scripts


if (Get-windowsFeature -Name File-Services | ForEach-Object Installed){
    ./email-SmbShares.ps1
}

if (Get-WindowsFeature -Name DHCPServer | ForEach-Object Installed){
    ./Email-Dhcp.ps1
}



#forces parameter to name group
Param(
    [Parameter(Mandatory=$true)]
    [string]$group
)

$domain = get-adrootdse
$inactive = @()
$emailFrom = "Alerts@soratech.com"
$emailTo = "Alerts@soratech.com"
$hostName = hostname
$subject = "Group membership for $($group) has changed on $($hostName) for domain $($domain.rootDomainNamingContext)"
$smtpServer = "smtp.outlook.com"
$smtpPort = 587
$smtpCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $emailFrom, $PWord
$body = "<html><p>The following users were disabled on $Today : </p>"

#loads active directory PS module
if(Get-Module -ListAvailable -Name activedirectory){
    Import-Module activedirectory
}
else{
    Install-Module activedirectory
    Import-Module activedirectory
}

#gets group members and cycles through them to find inactive users then removes them from the group
Get-ADGroupMember -Identity $group | ForEach-Object {
    if ($_.objectClass -eq 'user'){
        Write-Host $_.SamAccountName
        $status = Get-ADUser -Identity $_.objectGUID -Property SamAccountName,Enabled
        if ($status.Enabled -eq $False) {
            $inactive += $status.SamAccountName
            Remove-ADGroupMember -Identity $_.objectGUID
        }
    }
}
$inactive | foreach-object{
    $body += "<p> $_</p>"
}


$body += "</html>"
Send-MailMessage -From $emailFrom -to $emailTo -Subject $subject -body $body -SmtpServer $smtpServer -port $smtpPort -UseSsl -Credential $smtpCredentials -bodyashtml

$today = get-date
$domain = get-adrootdse
$inactive = @()
$emailFrom = "Alerts@soratech.com"
$emailTo = "Alerts@soratech.com"
$hostName = hostname
$subject = "Inactive users moved on $($hostName) for domain $($domain.rootDomainNamingContext)"
$smtpServer = "smtp.outlook.com"
$smtpPort = 587

$smtpCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $emailFrom, $PWord
$body = "<html><p>The following users were disabled on $Today : </p>"


Get-ADUser -Filter * -Properties "LastLogonDate" |ForEach-Object{
If ($_.Enabled -eq 'True'){
    Write-Host "Unmoved: $($_.name) They logged in on $($_.LastLogonDate)"
    }
Else{
    $inactive += $_.name
    Move-ADObject $_.ObjectGUID -TargetPath "OU=Inactive Users, $($domain.rootDomainNamingContext)"
    Set-ADUser $_.ObjectGUID -Enabled $false -Description "Acct disabled on $Today due to inactivity. User last logged in on $($_.LastLogonDate)"
    }
}

$inactive | foreach-object{
    $body += "<p> $_</p>"
}


$body += "</html>"
Send-MailMessage -From $emailFrom -to $emailTo -Subject $subject -body $body -SmtpServer $smtpServer -port $smtpPort -UseSsl -Credential $smtpCredentials -bodyashtml
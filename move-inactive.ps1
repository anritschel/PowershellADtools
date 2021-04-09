
$today = get-date
$domain = get-adrootdse
$inactive = @()
$hostName = hostname
$subject = "Inactive users moved on $($hostName) for domain $($domain.rootDomainNamingContext)"
$secrets = Get-Content ./secrets.txt | Out-String | Invoke-Expression
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $secrets.user, (ConvertTo-SecureString -String $secrets.PassWord -AsPlainText -Force)
$body = "<html><p>The following users were disabled on $Today : </p>"

if(Get-Module -ListAvailable -Name activedirectory){
    Import-Module activedirectory
}
else{
    Install-Module activedirectory
    Import-Module activedirectory
}

Get-ADUser -Filter * -Properties "LastLogonDate" |ForEach-Object{
If ($_.LastLogonDate -lt $today.AddDays(-90)){
    $inactive += $_.name
    Move-ADObject $_.ObjectGUID -TargetPath "OU=Inactive Users, $($domain.rootDomainNamingContext)"
    Set-ADUser $_.ObjectGUID -Enabled $false -Description "Acct disabled on $Today due to inactivity. User last logged in on $($_.LastLogonDate)"
    }
}

$inactive | foreach-object{
    $body += "<p> $_</p>"
}


$body += "</html>"
Send-MailMessage -from $secrets.User -to $secrets.to -SmtpServer $secrets.smtpServer -Port $secrets.smtpPort -Credential $Credential -Subject $subject -Body $EmailMessage -UseSsl -BodyAsHtml


$User = "Alerts@soratech.com"
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord



$EmailMessage = "<style>
		table {
			width:100%;
			border:1px solid #000;
			border-collapse:collapse;
		}

		th, td {
			border:1px solid #000;
		}
	</style>
<p>The following SMB shares were discovered, add to the appropriate company's information</p>"
$smtpServer = "smtp.office365.com"
$smtpPort = 587


$data = @()

Get-SmbShare | ForEach-Object{
	Write-Host "Hello"
	$access = get-SMBShareAccess -Name $_.Name
	$smbObject = [PSCustomObject]@{
		Name = $_.Name
		Path = $_.Path
		Security = $access.AccountName 
	}
	$data += $smbObject
	$EmailMessage += "<table><tr><td>Name:<td>path</td><td>Access</td></tr><tr> <td>$($smbObject.Name)</td><td> $($smbObject.Path)</td><td>"
	$smbObject.Security | ForEach-Object { $EmailMessage += "$($_)<br>"} 
	$EmailMessage += "</td></table><br>"
	}
	
$emailMessage += "</html>"

    
Send-MailMessage -from $User -to "aritschel@soratech.com" -SmtpServer "smtp.office365.com" -Port 587 -Credential $Credential -Subject "SMB Share Discovery - $($env:COMPUTERNAME)" -Body $EmailMessage -UseSsl -BodyAsHtml
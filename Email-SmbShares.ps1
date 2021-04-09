
$secrets = Get-Content ./secrets.txt | Out-String | Invoke-Expression
#$PWord = ConvertTo-SecureString -String $secrets.PassWord -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $secrets.user, (ConvertTo-SecureString -String $secrets.PassWord -AsPlainText -Force)
$subject = "SMB Share Discovery - $($env:COMPUTERNAME)"


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

$data = @()

Get-SmbShare | ForEach-Object{
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

    
Send-MailMessage -from $secrets.User -to $secrets.to -SmtpServer $secrets.smtpServer -Port $secrets.smtpPort -Credential $Credential -Subject $subject -Body $EmailMessage -UseSsl -BodyAsHtml
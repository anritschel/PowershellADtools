
Param(
    [Parameter(Mandatory=$true)]
    [string]$path
)

$PWord = ConvertTo-SecureString -String "jdqxmvjnmvlfzdcb1!" -AsPlainText -Force
$fromEmail = "Alerts@soratech.com"
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $fromEmail, $PWord

$subject = "NTFS Permission audit - $($env:COMPUTERNAME) on Path $($path)"
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
<p>The following NFTS Permissions were recorded for $($path), add to the appropriate company's information</p>"
$smtpServer = "smtp.office365.com"
$smtpPort = 587
$toEmail = "aritschel@soratech.com"
$EmailMessage += "<table><tr><td>path</td><td>User</td><td>Access</td></tr><tr><td>$($path)"

$aclPermission = (Get-ACL $path).Access 

$aclPermission | ForEach-Object {
    Write-Host $_.IdentityReference
    $EmailMessage += "<td>$($_.IdentityReference)</td><td>$($_.FileSystemRights)</td></tr><tr><td></td>"
	
}
$EmailMessage += "</tr></table></html>"	


    
Send-MailMessage -from $fromEmail -to $toEmail -SmtpServer $smtpServer -Port $smtpPort -Credential $Credential -Subject $subject -Body $EmailMessage -UseSsl -BodyAsHtml

Param(
    [Parameter(Mandatory=$true)]
    [string]$path
)

$secrets = Get-Content ./secrets.txt | Out-String | Invoke-Expression
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $secrets.user, (ConvertTo-SecureString -String $secrets.PassWord -AsPlainText -Force)
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
$EmailMessage += "<table><tr><td>path</td><td>User</td><td>Access</td></tr><tr><td>$($path)"

$aclPermission = (Get-ACL $path).Access 

$aclPermission | ForEach-Object {
    Write-Host $_.IdentityReference
    $EmailMessage += "<td>$($_.IdentityReference)</td><td>$($_.FileSystemRights)</td></tr><tr><td></td>"
	
}
$EmailMessage += "</tr></table></html>"	


    
Send-MailMessage -from $secrets.User -to $secrets.to -SmtpServer $secrets.smtpServer -Port $secrets.smtpPort -Credential $Credential -Subject $subject -Body $EmailMessage -UseSsl -BodyAsHtml
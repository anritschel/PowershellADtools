$secrets = Get-Content ./secrets.txt | Out-String | Invoke-Expression
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $secrets.user, (ConvertTo-SecureString -String $secrets.PassWord -AsPlainText -Force)
$subject = "DHCP configuration for  $($env:COMPUTERNAME)"

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
<p>The following DHCP Scopes were found on  $($env:COMPUTERNAME), add to the appropriate company's information</p><table>"

$scopes = Get-DhcpServerv4Scope 

$scopes | ForEach-Object {
    $DhcpObject = [PSCustomObject]@{
		ScopeID = $_.ScopeId
		Router = Get-DhcpServerv4OptionValue -ScopeID $_.ScopeID -OptionId 3
		DnsServers = Get-DhcpServerv4OptionValue -ScopeID $_.ScopeID -OptionId 6
    }
    $EmailMessage += "<tr><td> Scope ID</td><td> $($DhcpObject.ScopeID)</td></tr><tr><td> Router </td><td> $($DhcpObject.Router)</td></tr><tr><td> DNS Servers</td><td> $($DhcpObject.DnsServers)</td></tr></table><table> "
    Get-DhcpServerV4Reservation -ScopeId $_.ScopeId | ForEach-Object { 
        $EmailMessage += "<tr><td>Name</td><td>Mac Address</td><td>IP address</td><td>Description</td></tr><tr><td>$($_.Name)</td><td>$($_.ClientId)</td><td>$($IPAddress)</td><td>$($_.Description)</td></tr>"
    } 
    $EmailMessage += "</table>"



}

Send-MailMessage -from $secrets.User -to $secrets.to -SmtpServer $secrets.smtpServer -Port $secrets.smtpPort -Credential $Credential -Subject $subject -Body $EmailMessage -UseSsl -BodyAsHtml
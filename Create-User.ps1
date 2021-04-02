#This script is to create a user account in AD and Microsoft 365

Param(
    [Parameter(Mandatory=$true)]
    [string]$AdminUserName,
    [Parameter(Mandatory=$true)]
    [string]$AdminPassword,
    [Parameter(Mandatory=$true)]
    [string]$FirstName,
    [Parameter(Mandatory=$true)]
    [string]$LastName,
    [Parameter(Mandatory=$true)]
    [string]$newPassword
)


#convert input to secure string for credentials
$adminPW = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($AdminUserName, $adminPW) 

$domain = get-adrootdse
$fullName = "$($firstName) $($LastName)"
#check for azureAD module
if(Get-Module -ListAvailable -Name AzureAD){
    Import-Module AzureAD
}
else{
    Install-Module AzureAD
    Import-Module AzureAD
}

#check for msonline module
if(Get-Module -ListAvailable -Name msonline){
    Import-Module msonline
}
else{
    Install-Module msonline
    Import-Module msonline
}

$exists = $false
$counter = 0
while ($exists = $false) {
    $userName = "$($FirstName.substring(0,$counter))$($LastName)"
    try {
        Get-ADUser - -Identity $userName
        $exists = $true
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] {
        $exists = $false
    }
    $counter +=1
}


New-ADUser -Name $FullName -GivenName $firstName -Surname $LastName -SamAccountName $userName -AccountPassword $newPassword -Enabled $true

Get-ADUser -Identity $userName | Move-ADObject $_.ObjectGUID -TargetPath 'OU=Sora,DC=enco,DC=local'
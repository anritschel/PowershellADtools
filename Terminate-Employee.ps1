#This script is to remove user account from AD and Microsoft 365 tennant

Param(
    [Parameter(Mandatory=$true)]
    [string]$AdminUserName,
    [Parameter(Mandatory=$true)]
    [string]$AdminPassword,
    [Parameter(Mandatory=$true)]
    [string]$userUPN,
    [Parameter(Mandatory=$true)]
    [string]$adAccount,
    [Parameter(Mandatory=$true)]
    [string]$newPassword
)


#convert input to secure string for credentials
$adminPW = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($AdminUserName, $adminPW) 

$domain = get-adrootdse

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

#start Microsoft 365 session and connect to Msol Service
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -AllowRedirection -Authentication Basic 
Import-PSSession $Session
Connect-MsolService -Credential $Cred
connect-AzureAD -Credential $Cred
#Change password, force logout, and block sign in
Set-MsolUserPassword -UserPrincipalName $userUPN -NewPassword $newPassword
Get-AzureADUser -SearchString $userUPN | Revoke-AzureADUserAllRefreshToken
Set-AzureADUser -ObjectID $userUPN -AccountEnabled $false

#Convert to shared mailbox
Set-Mailbox $userUPN -Type shared


$userList = Get-AzureADUser -ObjectID $userUPN

#Get assigned SKUs & remove
$Skus = $userList | Select-Object -ExpandProperty AssignedLicenses | Select-Object SkuID

if($userList.Count -ne 0) {
    if($Skus -is [array])
    {
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        for ($i=0; $i -lt $Skus.Count; $i++) {
            $Licenses.RemoveLicenses +=  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus[$i].SkuId -EQ).SkuID   
        }
        Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    } else {
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $Licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus.SkuId -EQ).SkuID
        Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    }
}

#do work in AD
Set-ADAccountPassword -Identity $adAccount -Reset -NewPassword (ConvertTo-SecureString $newPassword)
Disable-ADAccount -Identity $adAccount
Get-ADUser $adAccount | Move-ADObject -TargetPath "OU=Inactive Users, $($domain.rootDomainNamingContext)"


Remove-PsSession $Session

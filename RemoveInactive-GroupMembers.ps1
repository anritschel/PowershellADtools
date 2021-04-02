#forces parameter to name group
Param(
    [Parameter(Mandatory=$true)]
    [string]$group
)

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

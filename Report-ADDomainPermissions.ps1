# PowerShell command to scan and report on the AD domain permissions (requires the AD PowerShell module):
# Taken from: https://adsecurity.org/?p=4119
$ADDomain = 'DOMAIN.COM'
$DomainRootPermissionsReportDir = 'c:\temp' 
$DomainRootPermissionsReportName = 'DomainRootPermissionsReport.csv' 
if(!(Test-Path $DomainRootPermissionsReportDir)) { 
    new-item -type Directory -path $DomainRootPermissionsReportDir 
} 
$DomainRootPermissionsReportPath = $DomainRootPermissionsReportDir + '\' + $ADDomain + '-' +$DomainRootPermissionsReportName 
$DomainTopLevelObjectDN = (Get-ADDomain $ADDomain).DistinguishedName 
$DomainRootPermissions = Get-ADObject -Identity $DomainTopLevelObjectDN -Properties * | select -ExpandProperty nTSecurityDescriptor | select -ExpandProperty Access $DomainRootPermissions | select IdentityReference,ActiveDirectoryRights,AccessControlType,IsInherited,InheritanceType,ObjectType,InheritedObjectType,ObjectFlags,InheritanceFlags,PropagationFlags ` | export-csv $DomainRootPermissionsReportPath -NoTypeInfo 
$DomainRootPermissions | select IdentityReference,ActiveDirectoryRights,AccessControlType,IsInherited | sort ActiveDirectoryRights,IdentityReference 
Write-Output " " 
Write-Output "———————————————————————————————————————————— " 
Write-Output "| $ADDomain Domain Permission Report saved to $DomainRootPermissionsReportPath | " 
Write-Output "———————————————————————————————————————————— "


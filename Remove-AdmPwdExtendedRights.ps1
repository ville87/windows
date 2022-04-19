<#
.Synopsis
   Removes unauthorized access from the most commonly seen default groups that shouldn't have rights to read the AD stored local admin account password for the given computer - 'Everyone', 'BUILTIN\Users', 'Domain Users', and 'Authenticated Users'.

.DESCRIPTION
   Script is from blog article: https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/you-might-want-to-audit-your-laps-permissions/ba-p/2280785
   Removes unauthorized access from the most commonly seen default group that shouldn't have rights to the CONTROL_ACCESS (as seen if using DSAcls) / ExtendedRights (as seen if using Get-ACL) permission on computer accounts.  
   Holders of this right have permission to read the admin account password for the given computer.  In addition to checking to see if these default groups have ExtendedRights specifically, I also check to see if they have 'Full Control', 
   which is seen as 'GenericAll'.  Full control obviously includes ExtendedRights, but since all rights are included, there's no need to individually list them, so it's labelled 'GenericAll', and filters just looking for 'ExtendedRights'
   would miss those ACEs.
   
   The Alpha version of this function only removes non-inherited ACEs from specific computer objects only.

.EXAMPLE
   Remove-AdmPwdExtendedRights -ComputerName <ComputerName>

   Displays the Access Control Entries (ACEs) within the Access Control List (ACL) that contain either Full Control or that had Extended Rights, for any of the following groups defined as the Identity Reference: 
   
   'Everyone', 'BUILTIN\Users', 'Domain Users', and 'Authenticated Users' 
   
   The variablized ACL has those ACEs removed, but prompts for confirmation that you're sure that you want write the modified ACL to the computer object in AD.

.EXAMPLE
   Remove-AdmPwdExtendedRights -ComputerName <ComputerName> -Force

   Displays the Access Control Entries (ACEs) within the Access Control List (ACL) that contain either Full Control or that had Extended Rights, for any of the following groups defined as the Identity Reference: 
   
   'Everyone', 'Domain Users', and 'Authenticated Users' 
   
   The variablized ACL has those ACEs removed, DOES NOT PROMPT for modification confirmation and attempts to write the modified ACL to the computer object in AD.

.NOTES
This is an Alpha version of this function with very limited testing.  See Disclaimer below.

Alpha Version - 20 April 2021

When looking at ACLs in AD, and trying to understand what you're seeing in the output of a Get-ACL on an AD Object, reference the following Microsoft Documentation which shows the ActiveDirectoryAccessRule Class:

https://docs.microsoft.com/en-us/dotnet/api/system.directoryservices.activedirectoryaccessrule?redirectedfrom=MSDN&view=net-5.0

or this which shows the Object ACE structure:

https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-access_allowed_object_ace?redirectedfrom=MSDN

Info based on the filter criteria in the function below:

ActiveDirectoryRights include permission types
IdentityReference Contains Security Principals
AccessControlType is the Access to the Right (ie Allow or Deny)
ObjectType is the string form of the rightsGUID attribute of the control access right - 
    -Below I filter for 00000000-0000-0000-0000-000000000000, which is the equivalent ALL - so 'Read ALL Properties', or 'Write ALL Properties', but in our case it's 'ALL Extended Rights".

This article shows how an ADSI ACE is read:

https://docs.microsoft.com/en-us/windows/win32/ad/reading-a-control-access-right-set-in-an-objectampaposs-acl

   Disclaimer:

 This is a sample script.  Sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the  possibility of such damages.

 AUTHOR: Eric Jansen, MSFT
#>

function Remove-AdmPwdExtendedRights
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Computer Object in AD to target for removal of Extended Rights.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName,

        # Computer Object in AD to target for removal of Extended Rights.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [Switch]$Force,

        # OU in AD to target for removal of Extended Rights.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $OrganizationalUnit
    )


    try
    {

        $ComputerDN = $(Get-ADComputer $ComputerName).distinguishedname
        $ACL = Get-ACl AD:\$($ComputerDN)
        $ACEsWithDefinedGroups = $ACL.Access | where {$_.IdentityReference -Match "Everyone" -or $_.IdentityReference -eq "BUILTIN\Users" -or $_.IdentityReference -Match "Domain Users" -or $_.IdentityReference -Match "Authenticated Users"}

        If($ACEsWithDefinedGroups){

        $ExtendedRightACEs = $ACEsWithDefinedGroups | 
        where {$_.isInherited -eq $false -and $_.ActiveDirectoryRights -match "ExtendedRight" -and $_.AccessControlType -eq "Allow" -and $_.objectType -eq "00000000-0000-0000-0000-000000000000"}
        
        $FullControlACEs = $ACEsWithDefinedGroups | 
        where {$_.isInherited -eq $false -and $_.ActiveDirectoryRights -match "GenericAll" -and $_.AccessControlType -eq "Allow"}


            ForEach($ACE in $ExtendedRightACEs){
            Write-Host "Removing the Following ACE from the ACL: " -NoNewline -ForegroundColor Gray
            Write-Host "ActiveDirecoryRights: $($ACE.ActiveDirectoryRights); IdentityReference: $($ACE.IdentityReference); AccessControlType: $($ACE.AccessControlType)"
            $ACL.RemoveAccessRule($ACE) | Out-Null
            }

            ForEach($ACE in $FullControlACEs){
            Write-Host "Removing the Following ACE from the ACL: " -NoNewline -ForegroundColor Gray
            Write-Host "ActiveDirecoryRights: $($ACE.ActiveDirectoryRights); IdentityReference: $($ACE.IdentityReference); AccessControlType: $($ACE.AccessControlType)" -ForegroundColor Red
            $ACL.RemoveAccessRule($ACE) | Out-Null
            }

            If($ExtendedRightACEs -ne $null -or $FullControlACEs -ne $null){

                If($Force){
                Set-Acl -AclObject $ACL -Path AD:\$ComputerDN
                }
                Else{
            
                    do
                    {
                      $Answer = Read-Host "Write Changes to $($ComputerName) ACL? (Y/N)"  

                      IF($Answer.ToLower() -eq "y"){
                      Set-Acl -AclObject $ACL -Path AD:\$ComputerDN
                      }
                      ElseIf($Answer.ToLower() -eq "n"){
                      Return
                      }

                    }
                    until ($Answer.ToLower() -eq "y" -or $Answer.ToLower() -eq "n")                       

                }

         
            $ACEsWithDefinedGroups = $PostACL.Access | where {$_.IdentityReference -Match "Everyone" -or $_.IdentityReference -eq "BUILTIN\Users" -or $_.IdentityReference -Match "Domain Users" -or $_.IdentityReference -Match "Authenticated Users"}
        
            $ExtendedRightACEs = $ACEsWithDefinedGroups | 
            where {$_.isInherited -eq $false -and $_.ActiveDirectoryRights -match "ExtendedRight" -and $_.AccessControlType -eq "Allow" -and $_.objectType -eq "00000000-0000-0000-0000-000000000000"}
        
            $FullControlACEs = $ACEsWithDefinedGroups | 
            where {$_.isInherited -eq $false -and $_.ActiveDirectoryRights -match "GenericAll" -and $_.AccessControlType -eq "Allow"}
        
                If($ExtendedRightACECheck -eq $null -and $FullControlACEs -eq $null){
                Write-Host "Successfully removed ExtendedRights from $($ComputerName)" -ForegroundColor Green
                }
                Else{
                Write-Warning "Something didn't go as expected..."
                }

            }

        }
        Else{
        Write-Host "There were no ACE's that included 'Everyone', 'BUILTIN\Users', 'Domain Users', or 'Authenticated Users'."
        }
        
        
    }
    catch
    {
        $_.exception.message
    }
        
}


# Parsing data from message field
# To parse data from the message field, you have to work with the cmdlet "Get-EventLog" (instead of "Get-WinEvent") and work with ReplacementStrings:
(Get-EventLog -LogName Security -InstanceId 4662)[0] | Select @{Name="UserName";Expression={ $_.ReplacementStrings[1] }}

<# example output:
UserName
--------
lab_admin
#> 

# get all LAPS related events and who queried them for which machine:
Get-EventLog -LogName Security -InstanceId 4662 | Select @{Name="UserName";Expression={ $_.ReplacementStrings[1] }}, @{Name="UserDomain";Expression={ $_.ReplacementStrings[2] }}, @{Name="ComputerName";Expression={ (Get-Adobject ($_.ReplacementStrings[6] -replace '%\{(.*)\}','$1')).Name }}, TimeWritten

<# example output:
UserName UserDomain ComputerName TimeWritten
-------- ---------- ------------ -----------
DC1$ winlab winlab 2/19/2021 6:40:37 AM
lab_admin winlab WS1 2/19/2021 6:06:19 AM
ffast winlab WS1 2/19/2021 5:41:49 AM
#>

# Search for passwords from powershell scripts:
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" | Where-Object { $_.Message -like "*passw*"} | Format-Table TimeCreated, ID, ProviderName, Message -AutoSize -Wrap

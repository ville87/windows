#Find failed user logons and the reason of the failed attempt:
function Get-FailureReason {
Param($FailureReason)
switch ($FailureReason) {
'0xC0000064' {"Account does not exist"; break;}
'0xC000006A' {"Incorrect password"; break;}
'0xC000006D' {"Incorrect username or password"; break;}
'0xC000006E' {"Account restriction"; break;}
'0xC000006F' {"Invalid logon hours"; break;}
'0xC000015B' {"Logon type not granted"; break;}
'0xc0000070' {"Invalid Workstation"; break;}
'0xC0000071' {"Password expired"; break;}
'0xC0000072' {"Account disabled"; break;}
'0xC0000133' {"Time difference at DC"; break;}
'0xC0000193' {"Account expired"; break;}
'0xC0000224' {"Password must change"; break;}
'0xC0000234' {"Account locked out"; break;}
'0x0' {"0x0"; break;}
default {"Other"; break;}
}
}
Get-EventLog -LogName 'security' -InstanceId 4625 -Newest 100 | select @{Label='Time';Expression={$_.TimeGenerated.ToString('g')}},`
@{Label='User Name';Expression={$_.replacementstrings[5]}},`
@{Label='Client Name';Expression={$_.replacementstrings[13]}}, `
@{Label='Client Address';Expression={$_.replacementstrings[19]}}, `
@{Label='Server Name';Expression={$_.MachineName}}, `
@{Label='Failure Status';Expression={Get-FailureReason ($_.replacementstrings[7])}},`
@{Label='Failure Sub Status';Expression={Get-FailureReason($_.replacementstrings[9])}}

# Find successful user logins:
Get-WinEvent -LogName 'security' -FilterXPath '*[System[EventID=4624]]' -max 10 | select @{Label='Time';Expression={$_.TimeCreated}},`
@{Label='Account Name';Expression={$_.properties[1].value}},`
@{Label='Account Domain';Expression={$_.properties[2].value}},`
@{Label='Logon Type';Expression={$_.properties[8].value}},`
@{Label='Process Name';Expression={$_.properties[17].value}}

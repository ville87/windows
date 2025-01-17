#####################################
# Windows Event Log parsing samples #
#####################################

# Get all log entries from all enabled windows logs from a specific timeframe
$starttime = (Get-Date).AddHours(-16)
$endtime = (Get-Date).AddHours(-15)
$events = @()
$logstosearch = Get-WinEvent -ListLog * | Where-Object { ($_.isEnabled -eq $true) -and ($_.RecordCount -gt 0)  }
foreach($log in $logstosearch){
    $evententriess = Get-WinEvent -FilterHashtable @{
        'LogName' = $log.LogName
        'StartTime' = $starttime
        'EndTime' = $endtime
    } 
    $events += $evententriess
}
# select specific properties of all events and add them to a new PSObject
$objects=@();$events |Sort-Object -Property TimeCreated | % { $data = [PSCustomObject]@{TimeCreated = $($_.TimeCreated);LogName= $($_.LogName);Message= $($_.Message);Providername= $($_.ProviderName);Properties = $($_.Properties.Value)};$objects += $data}

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

# Find Schannel logins with certificates, list SubjectCN and SubjectAltName to see if there are discrepancies which could identify possible ESC1 abuse:
Get-WinEvent -LogName 'Microsoft-Windows-CAPI2/Operational' -FilterXPath '*[System[EventID=90]]' -max 10 | % { 
    $xmlevent = ([xml]$_.toXml()).Event
    $certs = $xmlevent.UserData.x509Objects.certificate
    $systemdata = $xmlevent.system
    if($certs -notlike $null){
        foreach($cert in $certs){
            $data = [PSCustomObject]@{
                Computer = $($systemdata.Computer)
                TimeCreated = $(Get-date $systemdata.TimeCreated.SystemTime -Format 'yyyy-MM-dd HH:mm')
                Issuer = $($cert.Issuer.CN)
                SubjectCN = $($cert.Subject.CN)
                SubjectAltName = $($cert.Extensions.SubjectAltName.UPN)
            }
            $data
        }
    }
}

<# Example output:
Computer       : dc1.lab.local
TimeCreated    : 2025-01-17 11:51
Issuer         : lab-SERVER1-CA
SubjectCN      : Jdoe
SubjectAltName : rplant@lab.local

#>

# Find successful user logins:
Get-WinEvent -LogName 'security' -FilterXPath '*[System[EventID=4624]]' -max 10 | select @{Label='Time';Expression={$_.TimeCreated}},`
@{Label='Account Name';Expression={$_.properties[1].value}},`
@{Label='Account Domain';Expression={$_.properties[2].value}},`
@{Label='Logon Type';Expression={$_.properties[8].value}},`
@{Label='Process Name';Expression={$_.properties[17].value}}

# Find failed user logons and the reason of the failed attempt:
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

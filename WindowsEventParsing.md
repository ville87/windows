# Parsing Windows Events using PowerShell
## ADCS ESC1 abuse via SChannel
List the last 10 SChannel based logins and get the details of the certificate used for the login:
```powershell
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

<# Example output 
Computer       : dc1.lab.local
TimeCreated    : 2025-01-17 11:51
Issuer         : lab-SERVER1-CA
SubjectCN      : Jdoe
SubjectAltName : rplant@lab.local

#>
```

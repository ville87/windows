# PowerShell based DNS Lookups / DIG
## Simple Lookups
```
# Perform a DNS Lookups Using PowerShell (.Net):
[System.Net.Dns]::GetHostEntry("10.10.10.100").HostName
[System.Net.Dns]::GetHostAddresses("ComputerName").IPAddressToString
# another method
Resolve-DNSName 10.10.10.10
```
## DIG Replacement
Check all types (equal to dig -t ANY):   
`PS C:\> Resolve-DnsName domain.com -Type ANY`   
Check SPF:   
`PS C:\> Resolve-DnsName domain.com -Type TXT`   

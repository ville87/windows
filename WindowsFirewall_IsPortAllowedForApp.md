# Windows Firewall INetFwMgr::IsPortAllowed
Check if Inbound Traffic is Allowed for Specific Applications:
```
function Test-IsPortOpen {
    param(
    [string]$Name,
    [int]$Port
    )
 
    $mgr = New-Object -ComObject "HNetCfg.FwMgr"
    $allow = $null
    $mgr.IsPortAllowed($Name, 2, $Port, "", 6, [ref]$allow, $null)
    $allow
}
 
foreach($f in $(ls "$env:WINDIR\system32\*.exe")) {
    if (Test-IsPortOpen $f.FullName 12345) {
        Write-Host $f.Fullname
    }
}
```
https://docs.microsoft.com/en-us/windows/win32/api/netfw/nf-netfw-inetfwmgr-isportallowed

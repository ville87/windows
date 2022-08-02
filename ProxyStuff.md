# Windows Proxy Stuff
## Proxy Auth
Define proxy ip:   
`[system.net.webrequest]::DefaultWebProxy = new-object system.net.webproxy('http://10.10.10.10:8080')`   
Set proxy auth to logged in user:   
`[system.net.webrequest]::DefaultWebProxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials`

## Bypass Proxy Test
You can try to bypass the proxy by setting a new (empty) proxy in a webrequest:   
```
$Request = [System.Net.HttpWebRequest]::CreateHttp('https://ifconfig.me/')
$Request.Proxy=[System.Net.WebProxy]::new()
$response = $Request.GetResponse()
$stream = $response.GetResponseStream()
$readstream =New-Object System.IO.StreamReader $stream
$readstream.ReadToEnd()
```

## Disable Proxy
```
$regKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
Set-ItemProperty -path $regKey ProxyEnable -value 0 -ErrorAction Stop
Set-ItemProperty -path $regKey ProxyServer -value "" -ErrorAction Stop
Set-ItemProperty -path $regKey AutoConfigURL -Value "" -ErrorAction Stop
```

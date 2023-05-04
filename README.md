# windows

## Git through Proxy   
`$ git config --global http.proxy http://<username>@<proxyserver>:<port>`   
`$ git config --global credential.helper wincred`   

## Base64 encode in PS
`[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("test"))`   

## Check current PS Session Architecture
`write-host 'Current PS console architecture is: '(([IntPtr]::size)*8) 'bit'`   

To run a 64-bit PS command from a 32-bit CMD.exe, you can use following command:   
`C:\Windows\sysnative\WindowsPowerShell\v1.0\powershell.exe "write-host 'Current PS console architecture is: '(([IntPtr]::size)*8) 'bit'"`    

# NT hash
## Calculate NT hash from plaintext using Python script:   
```python
import sys,hashlib,binascii
input = sys.argv[1]
hash = hashlib.new('md4', input.encode('utf-16le')).digest()
print ("Plaintext password provided: ",input)
print ("NT hash: ",binascii.hexlify(hash))
```
Use the script with: `python scriptname.py <plaintext pw>`   


# WinGet
## Install Firefox
`winget install mozilla.firefox`   

# Proxy with PowerShell
```powershell
# Check proxy
[System.Net.WebProxy]::GetDefaultProxy()
Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
netsh winhttp show proxy

# Set proxy credentials
[System.Net.Http.HttpClient]::DefaultProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

# Set NULL proxy (bypass proxy)
[System.Net.Http.HttpClient]::DefaultProxy = New-Object System.Net.WebProxy($null)
[System.Net.HttpWebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($null)
# Specific proxy
[System.Net.Http.HttpClient]::DefaultProxy = New-Object System.Net.WebProxy('http://proxy', $true)

# Test if proxy is used or bypassed for specific URL 
([System.Net.WebRequest]::GetSystemWebproxy()).IsBypassed("https://google.com")
```

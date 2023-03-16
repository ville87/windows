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

# WinGet
## Install Firefox
`winget install mozilla.firefox`   

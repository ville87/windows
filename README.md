# windows

## Git through Proxy   
`$ git config --global http.proxy http://<username>@<proxyserver>:<port>`   
`$ git config --global credential.helper wincred`   

## Base64 encode in PS
`[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("test"))`   

## Check current PS Session Architecture
`write-host 'Current PS console architecture is: '(([IntPtr]::size)*8) 'bit'`   

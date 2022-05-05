Check what was when downloaded via certutil.exe:   
`PS> foreach($item in (Get-ChildItem "C:\Users\$env:username\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData\")){get-content $item.FullName}`   

Native certutil.exe:   
`certutil -urlcache`   

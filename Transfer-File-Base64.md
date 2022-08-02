# Transfer Base64 Encoded File
Convert the file and save the blob:   
```
$FileName = "C:\Users\bob\Desktop\file.exe"
$base64string = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($FileName))
$newstring = $base64string -creplace ('A','@') # NOTE: creplace is important because it must be case sensitive!
$newstring | Out-File C:\Users\bob\Desktop\newfile.b64
```
Now transfer the file to where you need it and convert it back:
```
$b64string = (Get-Content "C:\Users\username\Downloads\newfile.b64") -creplace ('@','A')
$FileName = "c:\Users\username\Desktop\file.exe"
$ByteArray = [System.Convert]::FromBase64String($b64string)
[System.IO.File]::WriteAllBytes($FileName, $ByteArray)
```
Note: Use Get-FileHash to check the file before and after.

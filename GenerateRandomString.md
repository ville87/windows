Generate random alphanumeric string of 20 characters:   
`( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 20 | % {[char]$_}) )`   

If you have to guarantee that there is always characters from each group (Capital letters, small letters, numbers) use:   
`((((0x41..0x5A) | Get-Random -Count 7)+((0x30..0x39) | Get-Random -Count 7 )+((0x61..0x7A) | Get-Random -Count 7 ) ) | Sort-Object { get-random} | ForEach-Object { [char]$_}) -join ""`   

Generate GUID:   
`$i =1; while($i -lt 100){ (([guid]::NewGuid()).guid -split ("-"))[0];$i++}`   

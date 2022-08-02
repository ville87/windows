# Running C# in PowerShell
The following example create a registry key in C#:
```
$code = @"
using System;
using Microsoft.Win32;
namespace sisu
{
public class Program
{
public static void Main(){
RegistryKey key = Registry.CurrentUser.OpenSubKey("Software\\Microsoft\\Windows\\CurrentVersion",true);
key = key.OpenSubKey("Run",true);
key.SetValue("SUI_Agent", "C:\\Users\\bob\\AppData\\Roaming\\test.cmd");
}
}
}
"@
 
Add-Type -TypeDefinition $code -Language CSharp
iex "[sisu.Program]::Main()"
```

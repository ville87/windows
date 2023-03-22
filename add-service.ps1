# Script to add a service using PowerShell
# If you want a gmsa account to be used, replace with your gMSA account name. Remember to include the trailing dollar sign. (Note: The gMSA must be installed already on the system!)
$gMSA = 'DOMAIN\gmsaADFS$'

$serviceName = "demoservice"

# Create the service executable
$source=@"
using System;
using System.ServiceProcess;
using System.Diagnostics;

public class $serviceName : ServiceBase
{ 

	public $serviceName() 
	{
		ServiceName = "$serviceName";
		CanStop = true;
		CanPauseAndContinue = false;
	}

	protected override void OnStart(string [] args) 
	{
		try 
		{
			Process p = new Process();
			p.StartInfo.UseShellExecute = false;
			p.StartInfo.FileName = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe";
			p.StartInfo.Arguments = "-noprofile -noninteractive -executionpolicy bypass -file C:\\demoservice\\service.ps1";
			p.Start();
			p.WaitForExit();
		} 
		catch (Exception) {}
	}

	public static void Main() 
	{
		System.ServiceProcess.ServiceBase.Run(new $serviceName());
	}
}
"@

# Create the service executable
Add-Type -TypeDefinition $source -Language CSharp -OutputAssembly "C:\demoservice\service.exe" -OutputType ConsoleApplication -ReferencedAssemblies "System.ServiceProcess" -Debug:$false

# Create a new service running as local system
Write-Host " Creating service $serviceName to be run as Local System"
$service = New-Service -Name $serviceName -BinaryPathName "C:\demoservice\service.exe"

# Modify the service to run as gMSA
Write-Host " Changing user to $gMSA"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName" -Name "ObjectName" -Value $gMSA

# Start the service
Write-Host " Starting service $serviceName"
Start-Service -Name $serviceName

# Stop and delete the service
Write-Host " Stopping service $serviceName"
Stop-Service $ServiceName -ErrorAction SilentlyContinue | Out-Null
Write-Host " Deleting service $serviceName"
SC.exe DELETE $ServiceName | Out-Null

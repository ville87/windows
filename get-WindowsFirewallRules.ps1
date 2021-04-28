<#
Note about rule precedence in Windows:
1. Explicitly defined allow rules will take precedence over the default block setting.
2. Explicit block rules will take precedence over any conflicting allow rules.
3. More specific rules will take precedence over less specific rules, except in the case of explicit block rules as mentioned in 2. (For example, if the parameters of rule 1 includes an IP address range, while the parameters of rule 2 include a single IP host address, rule 2 will take precedence.)

Source: https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/best-practices-configuring
#>

$csvpath = "$env:Temp\FWRuleExport.csv" # define path to exported CSV file
$FWPortFilters = Get-NetFirewallPortFilter -PolicyStore ActiveStore
# Get program information of rules
$FWAppFilters = Get-NetFirewallApplicationFilter -PolicyStore ActiveStore
# Get service information of rules
$FWSvcFilters = Get-NetFirewallServiceFilter -PolicyStore ActiveStore
# Get interface information for rules
$FWIfTypeFilters = Get-NetFirewallInterfaceTypeFilter -PolicyStore ActiveStore
# Get authentication information for rules 
$FWSecurityFilters = Get-NetFirewallSecurityFilter -PolicyStore ActiveStore
# Get address information for rules
$FWAddressFilters = Get-NetFirewallAddressFilter -PolicyStore ActiveStore
# Get Configured FW rules which are enabled and allow traffic
$FWRulesEnabled = Get-NetFirewallRule -PolicyStore ActiveStore | Where-Object { ($_.Enabled -eq "True") -and ($_.Action -eq "Allow")}
$fwrulearray = @()
foreach($enabledrule in $FWRulesEnabled){
    $fwname = $enabledrule.Name
    $owner = $enabledrule.owner
    $group = $enabledrule.Group
    if($owner -like ""){ $owner = "N/A" }
    if($group -like ""){ $group = "N/A" }
    $fwportitem = $FWPortFilters | Where-Object { $_.InstanceID -Like $fwname }
    $fwappitem = $FWAppFilters | Where-Object { $_.InstanceID -Like $fwname }
    if($fwappitem.Package -like ""){ $fwappitemPackage = "N/A" }else { $fwappitemPackage = $fwappitem.Package }
    $fwsvcitem = $FWSvcFilters | Where-Object { $_.InstanceID -Like $fwname }
    $fwiftypeitem = $FWIfTypeFilters | Where-Object { $_.InstanceID -Like $fwname }
    $fwsecurityitem = $FWSecurityFilters | Where-Object { $_.InstanceID -Like $fwname }
    $fwaddressitem = $FWAddressFilters | Where-Object { $_.InstanceID -Like $fwname }
    if($fwappitem.Program -contains "%windir%") { $friendlyprogramname = $fwappitem.Program -replace ("%windir%","C:\Windows")}
    elseif($fwappitem.Program -contains "%SystemRoot%"){ $friendlyprogramname = $fwappitem.Program -replace ("%SystemRoot%","C:\Windows")}
    else{ $friendlyprogramname = $fwappitem.Program }
    $data = @{
        displayname = $enabledrule.DisplayName
        name = $fwname
        profiles = $enabledrule.Profile
        direction = $enabledrule.Direction
        action = $enabledrule.Action
        group = $group
        owner = $owner
        protocol = $fwportitem.Protocol
        localport = $fwportitem.LocalPort
        localaddress = $fwaddressitem.LocalAddress
        remoteaddress = $fwaddressitem.RemoteAddress
        IcmpType = $fwportitem.IcmpType
        remoteport = $fwportitem.RemotePort
        program = $fwappitem.Program
        friendlyprogramname = $friendlyprogramname
        package = $fwappitemPackage
        service = $fwsvcitem.Service
        interfacetype = $fwiftypeitem.InterfaceType
        authentication = $fwsecurityitem.Authentication
        localprincipals = $fwsecurityitem.LocalUser
        remotemachines = $fwsecurityitem.RemoteMachine
        remoteusers = $fwsecurityitem.RemoteUser
        PolicyStoreSource = $PolicyStoreSource
        PolicyStoreSourceType = $PolicyStoreSourceType
    }
    $fwrulearray += New-Object psobject -Property $data
}
$fwrulearray | Export-Csv -Path $csvpath

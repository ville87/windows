$csvpath = "$env:Temp\FWRuleExport.csv" # define path to exported CSV file
$FWPortFilters = Get-NetFirewallPortFilter 
# Get program information of rules
$FWAppFilters = Get-NetFirewallApplicationFilter
# Get service information of rules
$FWSvcFilters = Get-NetFirewallServiceFilter
# Get interface information for rules
$FWIfTypeFilters = Get-NetFirewallInterfaceTypeFilter
# Get authentication information for rules 
$FWSecurityFilters = Get-NetFirewallSecurityFilter
# Get Configured inbound FW rules which are enabled
$InboundFWRulesEnabled = Get-NetFirewallRule | Where-Object { ($_.Enabled -eq "True") -and ($_.Direction -eq "Inbound") -and ($_.Action -eq "Allow")}
$fwrulearray = @()
foreach($enabledrule in $InboundFWRulesEnabled){
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
    }
    $fwrulearray += New-Object psobject -Property $data
}
$fwrulearray | Export-Csv -Path $csvpath
# Monitoring Mode in Windows
## Requirements
- You need to install Wireshark
- Monitoring mode compatible device. (See https://secwiki.org/w/Npcap/WiFi_adapters)
- To see what is installed: `netsh wlan show interface`
- Download and install latest npcap driver from here: https://nmap.org/npcap/#download
- Make sure during setup to enable "Support raw 802.11 traffic (and monitor mode) for wireless adapters"!

## Switching to Monitor Mode
- Open cmd.exe and change to the folder c:\Windows\System32\Npcap (which should contain the "wlanhelper" binary.
- `c:\Windows\System32\Npcap>wlanhelper 1017c7d9-beb2-41c5-a613-881d0c0f7e2c mode monitor`
- `c:\Windows\System32\Npcap>wlanhelper 1017c7d9-beb2-41c5-a613-881d0c0f7e2c channel 11`

## Switching back
After testing make sure to switch back:   
`c:\Windows\System32\Npcap>wlanhelper 1017c7d9-beb2-41c5-a613-881d0c0f7e2c mode managed`   

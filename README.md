# mRemoteNG OpenVPN External tool

## Synopsis
Connect to OpenVPN via mRemoteNG external tool.
 
## Description
The Userfield is used to pass parameters.</br>
There need to have two external tools configured with the option 'Wait for exit' enabled : 
#### Connection :
```Bash
"path\to\file\RDPOpenVPN.ps1" -u %USERNAME% -p %PASSWORD% -config %USERFIELD%
```
#### Disconnection :
```Bash
"path\to\file\RDPOpenVPN.ps1" -deco -config %USERFIELD%
```
Userfield should contain the config name and -askdeco if needed.

- If VPN is already running with config, exit immediately.
- When connecting, the script will try to read the logfile and exit if connected. **// TODO : Stop if error**
- If not able to access the logfile, then wait 15 sec and exit.

PS: Openvpn folder should be added in PATH or folder location added in the script.</br>
PPS: Enable silent connection in OpenVPN-gui.


|PARAMETER|Info|
|---------|----|
|-deco|Used for disconnection.|
|-askdeco|Will prevent the disconnection if there are other connected session in mRemoteNG with the same config.|
|-vpn \<string\>|For future improvement, if more vpn can be added.|
|-config \<string\>|The name of the OpenVPN config.|
|-u \<string\>|Used to retrieve the username from mRemoteNG.|
|-p \<string\>|Used to retrieve the password from mRemoteNG. **\/!\ Special Character Escaping /!\\** Check [doc](https://mremoteng.readthedocs.io/en/latest/user_interface/external_tools.html#special-character-escaping) for more info.|
|-w \<int\>|Set a wait time in sec if the script was not able to find the VPN log. Default is 15 sec.|
        
    
I lost the game.

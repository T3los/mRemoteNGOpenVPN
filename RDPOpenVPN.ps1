<#
    .SYNOPSIS
        Connect to OpenVPN via mRemoteNG external tool.
 
    .DESCRIPTION
        The Userfield is used to pass parameters.
        
        There need to have two external tools configured with the option 'Wait for exit' enabled : 
            - Connection : "path\to\file\RDPOpenVPN.ps1" -u %USERNAME% -p %password% -config %USERFIELD%
            - Disconnection : "path\to\file\RDPOpenVPN.ps1" -deco -config %USERFIELD%

        Userfield should contain the config name and -askdeco if needed.
        
        If VPN is already running with config, exit immediately.
        When connecting, the script will try to read the logfile and exit if connected. // TODO : Stop if error
        If not able to access the logfile, then wait 15 sec and exit.
        
        PS: openvpn folder should be added in PATH or folder location added in the scipt.
        PS: enable silent connection in OpenVPN-gui.
        
        I lost the game.
 
    .PARAMETER deco
        Used for disconnection.
 
    .PARAMETER askdeco
        Will prevent the disconnection if there are other connected session in mRemoteNG with the same config.
 
    .PARAMETER vpn
        For future improvement, if more vpn can be added.
 
    .PARAMETER config
        The name of the OpenVPN config.
 
    .PARAMETER u
        Used to retrieve the username from mRemoteNG.

    .PARAMETER p
        Used to retrieve the password from mRemoteNG. /!\ Special Character Escaping /!\ 
        Check https://mremoteng.readthedocs.io/en/latest/user_interface/external_tools.html#special-character-escaping for more info.

    .PARAMETER w
        Set a wait time in sec, if the script was note able to find the VPN log.
        Default is 15 sec.
#>

param (
    [Switch]$deco,
    [Switch]$askdeco,
    [Parameter()][string]$vpn = "openVPN",
    [Parameter()][string]$config,
    [Parameter()][string]$u,
    [Parameter()][string]$p,
    [Parameter()][int]$w = 15)


####################
### OPEN VPN
####################

function connect_open_VPN{
    $cmd = Get-WmiObject Win32_Process -Filter "name = 'openvpn.exe'" | Select-Object CommandLine
    if (($cmd -match '(?<=--config \")(?<config>.*?)(?:\.ovpn\")') -and ($config -eq $matches.config)) {exit}
    else{
        openvpn-gui --command connect $config 
        Start-Sleep -Milliseconds  500
        $cmd = Get-WmiObject Win32_Process -Filter "name = 'openvpn.exe'" | Select-Object CommandLine
        if ($cmd -match '(?<=--log \")(?<logpath>.*?)(?:\")') {
            Get-Content -Path $matches.logpath -Tail 1 -Wait | where {if ($_ -match '(,CONNECTED,SUCCESS)') {exit}}}
        else{
            Wait
            exit}}}

function deconnect_open_VPN{
    If(($askdeco) -and (Select-Xml -Path "$env:APPDATA\mRemoteNG\confCons.xml" -XPath //Node | foreach {if (($_.Node.UserField -eq "$config -askdeco")-and($_.Node.Connected -eq 'true' ) ){$_}})){exit}
    else{
        openvpn-gui --command disconnect $config 
        exit}}


####################
### PROGRESS BAR
####################

function Wait{
    $w = $w*10
    for ($i = 1; $i -le $w; $i++ ){
        Write-Progress -Activity "Connection..." -Status "$($i/10) sec :" -PercentComplete ($i/$w*100) 
        Start-Sleep -Milliseconds  100
    }}

####################
### START
####################

clear
$pshost = get-host
$pswindow = $pshost.ui.rawui
$newsize = $pswindow.windowsize
$newsize.height = 20
$newsize.width = 80
$pswindow.windowsize = $newsize
$newsize = $pswindow.buffersize
$newsize.height = 20
$newsize.width = 80
$pswindow.buffersize = $newsize
$newsize = $pswindow.CursorPosition
$newsize.X = 0
$newsize.Y = 19
$pswindow.CursorPosition = $newsize
                
Write-Host "        _________   ______   _         _____    ______                "  -BackgroundColor Black 
Write-Host "       |___   ___| |  ____| | |       /  _  \  / _____\               "  -BackgroundColor Black
Write-Host "           | |     | |___   | |      |  | |  | | |____                "  -BackgroundColor Black
Write-Host "           | |     |  ___|  | |      |  | |  | \____  \               "  -BackgroundColor Black
Write-Host "           | |     | |____  | |____  |  |_|  |  ____| |               "  -BackgroundColor Black
Write-Host "           |_|     |______| |______|  \_____/  \______/               "  -BackgroundColor Black
Write-Host "                                                                      "  -BackgroundColor Black
Write-Host ""

If (!$deco){
    Switch ($vpn){
        "openVPN"{connect_open_VPN}
        "Other VPN"{exit}}}
Else{
    Switch ($vpn){
        "openVPN"{deconnect_open_VPN}
        "Other VPN"{exit}}}

@ECHO OFF
REM ======================================================
REM GamePassAutoTunnel.bat
REM
REM Automates NFL Gamepass access
REM - Starts SSH dynamic tunnel
REM - Configures IExplorer to use tunnel
REM - Starts GamePass
REM - Reconfigures IExplorer to use direct connection
REM - Kills Tunnel
REM
REM Changelog:
REM v1.2 - 01/03/2014 - FA
REM - Added user Variables
REM 
REM v1.1 - 01/03/2014 - FA
REM - Added private key usage
REM - Cleaned Up
REM - Changed the proxy reset method
REM
REM v1.0 - 08/11/2013 - FA
REM - Initial Version
REM
REM ======================================================

REM ========================================
REM User Variables
REM ========================================
REM SSH Server 
SET sshServer=255.255.255.255
REM
REM SSH User
SET sshUser=tunnelUser
REM
REM SSH Password, needed when not using
REM a key file
SET sshPassword="MyStrongPassword"
REM
REM Use private key file
SET useKeyFile=FALSE
REM
REM SSH private key file
REM Needed when useKeyFile is set to TRUE
SET privateKey=NFL_Priv.ppk
REM
REM Port to use for local proxy
SET proxyPort=5555
REM
REM Initial connection wait time
REM Depends on the speed of the ssh server
REM Default: 3s
SET initWait=3
REM
REM How long to wait for gamepass to load
REM Depends on the speed of the ssh server
REM and how fast you can log in
REM Default: 60s
SET gamepassWait=60
REM ========================================

TITLE NFL GamePass AutoTunnel
MODE con: cols=65 lines=25

ECHO Script to Auto-start NFL GamePass through SSH Tunnel
ECHO ====================================================

SET scriptPath=%~dp0
SET ERRORLEVEL=0

IF NOT EXIST "%scriptPath%\plink.exe" (

        ECHO. && ECHO == plink.exe doesn't exist, downloading...
        bitsadmin /TRANSFER xxx "http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe" "%scriptPath%\plink.exe" > NUL 2>&1

        IF %ERRORLEVEL% NEQ 0 (
            ECHO. && ECHO [ERROR] Plink Download Failed
            ECHO.
            ECHO Please check internet connection
            ECHO or download plink.exe manually from:
            ECHO http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html
            ECHO.
            SET /P variable=Press Enter to exit...
            exit 1
        )
)

IF %useKeyFile%==TRUE (
    IF NOT EXIST "%scriptPath%%privateKey%" (
        ECHO. && ECHO [ERROR] SSH Private key file doesn't exit
        ECHO Please check its location and script settings
        ECHO.
        SET /P variable=Press Enter to exit...
        EXIT 1
    )
    ECHO. && ECHO == Update plink cache
    ECHO y | "%scriptPath%plink.exe" -i "%scriptPath%%privateKey%" %sshUser%@%sshServer% exit > NUL 2>&1
)

IF %useKeyFile%==FALSE (
    ECHO. && ECHO == Update plink cache
    ECHO y | "%scriptPath%plink.exe" -pw %sshPassword% %sshUser%@%sshServer% exit 
)

ECHO. && ECHO == Start SSH proxy
IF %useKeyFile%==TRUE (
    start /min "Tunnel" "%scriptPath%plink.exe" -ssh -i "%scriptPath%%privateKey%" -N -T -D %proxyPort% %sshUser%@%sshServer%
)

IF %useKeyFile%==FALSE (
    start /min "Tunnel" "%scriptPath%plink.exe" -ssh -pw %sshPassword% -N -T -D %proxyPort% %sshUser%@%sshServer%
)

ECHO. && ECHO Wait [%initWait%s]
TIMEOUT /NOBREAK /T %initWait% > NUL 2>&1

ECHO. && ECHO == Configure IExplorer
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d socks=localhost:%proxyPort% /f > NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f > NUL 2>&1

ECHO. && ECHO == Start NFL Gamepass
start "" "%PROGRAMFILES%\Internet Explorer\iexplore.exe" -private http://gamepass.nfl.com/nflgp/console.jsp

ECHO. && ECHO Wait [%gamepassWait%s]
TIMEOUT /NOBREAK /T %gamepassWait% > NUL 2>&1

ECHO. && ECHO == Reset proxy
REM Disable proxy
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f > NUL 2>&1
netsh winhttp reset proxy > NUL 2>&1

REM IExplorer will only load new settings when a new instance is started, starting and killing it
REM Create a fake file for IExplorer to load
ECHO "<html><head><title>KILLME</title></head><body>temp file for gamepass script</body></html>" > "%scriptPath%KILLME.html"

REM Start IExplorer
start /min "Reload Settings" "%PROGRAMFILES%\Internet Explorer\iexplore.exe" "%scriptPath%KILLME.html"
TIMEOUT /NOBREAK /T 1 > NUL 2>&1

REM Kill IExplorer
taskkill /F /FI "WINDOWTITLE eq KILLME*" > NUL 2>&1

REM Delete temp file
DEL /F /Q "%scriptPath%KILLME.html"

REM Kill tunnel
ECHO. && ECHO == Kill Tunnel
taskkill /F /FI "IMAGENAME eq plink.exe" > NUL 2>&1

ECHO. && ECHO All Done
ECHO =========================
ECHO Go Browns! Steelers Suck! 
ECHO =========================
TIMEOUT /NOBREAK /T 5 > NUL 2>&1



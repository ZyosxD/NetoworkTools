@echo off
setlocal enabledelayedexpansion

rem ============================================================================
rem  Initialization and Environment Setup
rem ============================================================================

rem --- Log File Setup ---
set "SESSION_LOG=%TEMP%\diag_session_%RANDOM%.log"
echo Session Log Started at %date% %time% > "!SESSION_LOG!"

rem --- Get Special Characters ---
for /f "tokens=1 delims= " %%a in ('echo prompt $E^| cmd') do (
  set "ESC=%%a"
)

rem --- Color Definitions ---
set "color_reset=!ESC![0m"
set "color_red=!ESC![31m"
set "color_green=!ESC![32m"
set "color_yellow=!ESC![33m"
set "color_blue=!ESC![34m"

rem ============================================================================
rem  Main Menu
rem ============================================================================
:menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!          --- Network Diagnostic Tool ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo Please select an option:
echo.
echo 1. [Auto]     Automatic Diagnostics
echo 2. [IP]       IP Configuration
echo 3. [Ping]     Ping Utility
echo 4. [Tracert]  Trace Route
echo 5. [Advanced] Advanced Diagnostics
echo 6. [Exit]     Exit and Save Log
echo.
set /p choice="Enter your choice: "

rem --- Menu Logic ---
if /i "%choice%"=="1" goto auto_diag
if /i "%choice%"=="2" goto ipconfig_menu
if /i "%choice%"=="3" goto ping_menu
if /i "%choice%"=="4" goto tracert
if /i "%choice%"=="5" goto advanced_menu
if /i "%choice%"=="6" goto save_and_exit

rem ============================================================================
rem  Automatic Diagnostics
rem ============================================================================
:auto_diag
cls
call :log_header "Automatic Diagnostics"
echo !color_yellow!Starting automatic diagnostics...!color_reset!
echo.

rem --- Step 1: Get Default Gateway (Router) ---
echo !color_yellow![Step 1 of 3] Verifying router connection...!color_reset!
set "gateway="
for /f "tokens=3" %%g in ('ipconfig ^| findstr /c:"Default Gateway"') do (
    if "!gateway!"=="" set gateway=%%g
)

if "!gateway!"=="" (
    call :log_and_echo !color_red!Error: Default Gateway (Router) not found.!color_reset!
    call :log_and_echo Please ensure you are connected to a network.
    pause
    goto menu
)

rem --- Step 2: Ping the Router ---
ping -n 2 !gateway! > nul
if !errorlevel! equ 0 (
    call :log_and_echo [ !color_green!OK!color_reset! ] Connection to the router (!gateway!) is successful.
) else (
    call :log_and_echo [ !color_red!FAIL!color_reset! ] Cannot contact the router (!gateway!).
    call :log_and_echo !color_red!Likely problem: Network cable unplugged, or an issue with WiFi/router.!color_reset!
    pause
    goto menu
)

rem --- Step 3: Ping the Internet ---
echo !color_yellow![Step 2 of 3] Verifying Internet connection...!color_reset!
ping -n 2 8.8.8.8 > nul
if !errorlevel! equ 0 (
    call :log_and_echo [ !color_green!OK!color_reset! ] Internet connection is successful.
) else (
    call :log_and_echo [ !color_red!FAIL!color_reset! ] Cannot connect to the Internet.
    call :log_and_echo !color_red!Likely problem: The router has no Internet connection, or a firewall is blocking access.!color_reset!
    pause
    goto menu
)

rem --- Step 4: DNS Check ---
echo !color_yellow![Step 3 of 3] Verifying DNS resolution...!color_reset!
nslookup google.com > nul
if !errorlevel! equ 0 (
    call :log_and_echo [ !color_green!OK!color_reset! ] DNS servers are working correctly.
) else (
    call :log_and_echo [ !color_red!FAIL!color_reset! ] DNS servers are not responding.
    call :log_and_echo !color_red!Likely problem: The configured DNS servers are not working. Try flushing the DNS cache.!color_reset!
    pause
    goto menu
)

echo.
call :log_and_echo !color_green!================================================================!color_reset!
call :log_and_echo !color_green! Diagnostics complete. Your connection is fully functional!                !color_reset!
call :log_and_echo !color_green!================================================================!color_reset!
echo.
pause
goto menu


rem ============================================================================
rem  Core Network Commands
rem ============================================================================

rem --- IP Config Sub-menu ---
:ipconfig_menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!              --- IP Config Menu ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo 1. Display IP Configuration
echo 2. Release IP Address
echo 3. Renew IP Address
echo 4. Flush DNS Cache
echo 5. Back to Main Menu
echo.
set /p ip_choice="Enter your choice: "

if /i "%ip_choice%"=="1" goto ipconfig_all
if /i "%ip_choice%"=="2" goto ipconfig_release
if /i "%ip_choice%"=="3" goto ipconfig_renew
if /i "%ip_choice%"=="4" goto ipconfig_flushdns
if /i "%ip_choice%"=="5" goto menu

:ipconfig_all
cls
call :log_and_run "Display IP Configuration" ipconfig /all
pause
goto ipconfig_menu

:ipconfig_release
cls
call :log_and_run "Release IP Address" ipconfig /release
pause
goto ipconfig_menu

:ipconfig_renew
cls
call :log_and_run "Renew IP Address" ipconfig /renew
pause
goto ipconfig_menu

:ipconfig_flushdns
cls
call :log_and_run "Flush DNS Cache" ipconfig /flushdns
pause
goto ipconfig_menu

rem --- Ping Sub-menu ---
:ping_menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!               --- Ping Menu ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo 1. Standard Ping (4 packets)
echo 2. Extended Ping (continuous, press Ctrl+C to stop)
echo 3. Back to Main Menu
echo.
set /p ping_choice="Enter your choice: "

if /i "%ping_choice%"=="1" goto ping_standard
if /i "%ping_choice%"=="2" goto ping_extended
if /i "%ping_choice%"=="3" goto menu

:ping_standard
cls
set /p host="Enter the host to ping: "
if "!host!"=="" (
    echo !color_red!Host cannot be empty.!color_reset!
    pause
    goto ping_menu
)
call :log_and_run "Standard Ping for %host%" ping %host%
pause
goto ping_menu

:ping_extended
cls
set /p host="Enter the host for extended ping: "
if "!host!"=="" (
    echo !color_red!Host cannot be empty.!color_reset!
    pause
    goto ping_menu
)
call :log_header "Extended Ping for %host%"
call :log_and_echo "Starting extended ping on %host%. User must press Ctrl+C to stop."
echo !color_yellow!Running extended ping on %host%...!color_reset!
echo !color_yellow!Press CTRL+C to stop.!color_reset!
ping %host% -t
echo.
call :log_and_echo "Extended ping stopped by user."
echo !color_green!Done.!color_reset!
pause
goto ping_menu


rem --- Tracert Command ---
:tracert
cls
set /p host="Enter the host to trace route: "
if "!host!"=="" (
    echo !color_red!Host cannot be empty.!color_reset!
    pause
    goto menu
)
call :log_and_run "Trace Route for %host%" tracert %host%
pause
goto menu

rem ============================================================================
rem  Advanced Network Diagnostics
rem ============================================================================
:advanced_menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!         --- Advanced Diagnostics Menu ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo 1. Measure Latency and Packet Loss
echo 2. Identify Connected Devices
echo 3. Show Saved WiFi Profiles
echo 4. Show Available WiFi Networks
echo 5. Show Saved WiFi Password
echo 6. Show Active Network Connections (netstat)
echo 7. DNS Lookup (nslookup)
echo 8. Back to Main Menu
echo.
set /p adv_choice="Enter your choice: "

if /i "%adv_choice%"=="1" goto latency_test
if /i "%adv_choice%"=="2" goto connected_devices
if /i "%adv_choice%"=="3" goto wifi_profiles
if /i "%adv_choice%"=="4" goto wifi_networks
if /i "%adv_choice%"=="5" goto wifi_password
if /i "%adv_choice%"=="6" goto netstat
if /i "%adv_choice%"=="7" goto nslookup
if /i "%adv_choice%"=="8" goto menu

rem --- Latency and Packet Loss Test ---
:latency_test
cls
set /p host="Enter the host to test: "
if "!host!"=="" (
    echo !color_red!Host cannot be empty.!color_reset!
    pause
    goto advanced_menu
)
set "PING_RESULTS_FILE=%TEMP%\ping_results_%RANDOM%.txt"
call :log_header "Latency and Packet Loss Test for %host%"
echo !color_yellow!Testing latency and packet loss for %host%...!color_reset!
echo !color_yellow!Sending 10 pings... please wait.!color_reset!
ping -n 10 %host% > "!PING_RESULTS_FILE!"
type "!PING_RESULTS_FILE!" >> "!SESSION_LOG!"
type "!PING_RESULTS_FILE!"
set "avg_latency=Not found"
for /f "tokens=3 delims=," %%a in ('findstr /c:"Average" /c:"Promedio" "!PING_RESULTS_FILE!"') do (
    for /f "tokens=3 delims== " %%b in ("%%a") do (
        set "avg_latency=%%b"
    )
)
set "packet_loss=Not found"
for /f "tokens=2 delims=()" %%a in ('findstr /c:"loss" /c:"perdidos" "!PING_RESULTS_FILE!"') do (
    set "packet_loss=%%a"
)
del "!PING_RESULTS_FILE!"
echo.
call :log_and_echo Average Latency: %avg_latency%
call :log_and_echo Packet Loss: %packet_loss%
echo.
pause
goto advanced_menu

rem --- Connected Devices ---
:connected_devices
cls
call :log_and_run "Identify Connected Devices" arp -a
pause
goto advanced_menu

rem --- Saved WiFi Profiles ---
:wifi_profiles
cls
call :log_and_run "Show Saved WiFi Profiles" netsh wlan show profiles
pause
goto advanced_menu

rem --- Available WiFi Networks ---
:wifi_networks
cls
call :log_and_run "Show Available WiFi Networks" netsh wlan show networks
pause
goto advanced_menu

rem --- Show WiFi Password ---
:wifi_password
cls
call :log_header "Show Saved WiFi Password"
echo !color_yellow!Showing saved WiFi profiles...!color_reset!
call :log_and_run "List WiFi Profiles" netsh wlan show profiles
echo.
set /p profile_name="Enter the name of the profile to see its password: "
if "!profile_name!"=="" (
    echo !color_red!Profile name cannot be empty.!color_reset!
    pause
    goto advanced_menu
)
call :log_header "Retrieve password for !profile_name!"
echo !color_yellow!Retrieving password for "!profile_name!"...!color_reset!
for /f "tokens=* delims=" %%a in ('netsh wlan show profile name^="!profile_name!" key^=clear ^| findstr "Key Content"') do (
    echo %%a
    echo %%a >> "!SESSION_LOG!"
)
echo.
echo !color_green!Done.!color_reset!
pause
goto advanced_menu

rem --- Netstat ---
:netstat
cls
call :log_and_run "Show Active Network Connections" netstat -an
pause
goto advanced_menu

rem --- NSLookup ---
:nslookup
cls
set /p domain="Enter the domain to look up (e.g., google.com): "
if "!domain!"=="" (
    echo !color_red!Domain cannot be empty.!color_reset!
    pause
    goto advanced_menu
)
call :log_and_run "DNS Lookup for !domain!" nslookup !domain!
pause
goto advanced_menu

rem ============================================================================
rem  Exit and Logging Logic
rem ============================================================================
:save_and_exit
cls
set "TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "FINAL_LOG=log_diagnostico_%TIMESTAMP%.txt"
copy "!SESSION_LOG!" "!FINAL_LOG!" > nul
del "!SESSION_LOG!"
echo !color_green!Log file saved as: %FINAL_LOG%!color_reset!
echo Thank you for using the Network Diagnostic Tool.
pause
exit

rem ============================================================================
rem  Utility Functions
rem ============================================================================

:log_and_echo
echo %*
echo %* >> "!SESSION_LOG!"
goto :eof

:log_header
echo. >> "!SESSION_LOG!"
echo --- Log for %~1 at %date% %time% --- >> "!SESSION_LOG!"
goto :eof

:log_and_run
call :log_header "%~1"
echo !color_yellow!Running command: %~2 %~3 %~4...!color_reset!
(
    echo.
    FOR /F "usebackq tokens=* delims=" %%a in (`%~2 %~3 %~4`) do (
        echo %%a
        echo %%a >> "!SESSION_LOG!"
    )
    echo.
)
echo !color_green!Done.!color_reset!
goto :eof

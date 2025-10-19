@echo off
setlocal enabledelayedexpansion

rem ============================================================================
rem  Initialization and Environment Setup
rem ============================================================================

rem --- Get Special Characters ---
rem Enables ANSI escape codes for colored text.
for /f "tokens=1 delims= " %%a in ('echo prompt $E^| cmd') do (
  set "ESC=%%a"
)
rem Gets a Carriage Return (CR) character for the progress bar.
for /f %%a in ('copy /z "%~f0" nul') do set "cr=%%a"


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
echo !color_yellow!      --- Network Diagnostic Tool ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo Please select an option:
echo.
echo 1. [IP] IP Config
echo 2. [Ping] Ping
echo 3. [Tracert] Tracert
echo 4. [Advanced] Advanced Diagnostics
echo 5. [Exit] Exit
rem To add a new option, add another 'echo' line here.
echo.
set /p choice="Enter your choice: "

rem --- Menu Logic ---
rem To add a new option, add another 'if' condition here to go to the new label.
if /i "%choice%"=="1" goto ipconfig_menu
if /i "%choice%"=="2" goto ping
if /i "%choice%"=="3" goto tracert
if /i "%choice%"=="4" goto advanced_menu
if /i "%choice%"=="5" exit

rem ============================================================================
rem  Core Network Commands
rem ============================================================================

rem --- IP Config Sub-Menu ---
:ipconfig_menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!           --- IP Config Menu ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo 1. Display IP Configuration
echo 2. Release IP Address
echo 3. Renew IP Address
echo 4. Back to Main Menu
echo.
set /p ip_choice="Enter your choice: "

if /i "%ip_choice%"=="1" goto ipconfig_all
if /i "%ip_choice%"=="2" goto ipconfig_release
if /i "%ip_choice%"=="3" goto ipconfig_renew
if /i "%ip_choice%"=="4" goto menu

:ipconfig_all
cls
echo !color_yellow!Displaying full IP configuration...!color_reset!
ipconfig /all
echo.
echo !color_green!Done.!color_reset!
pause
goto ipconfig_menu

:ipconfig_release
cls
echo !color_yellow!Releasing IP address...!color_reset!
ipconfig /release
echo.
echo !color_green!Done.!color_reset!
pause
goto ipconfig_menu

:ipconfig_renew
cls
echo !color_yellow!Renewing IP address...!color_reset!
ipconfig /renew
echo.
echo !color_green!Done.!color_reset!
pause
goto ipconfig_menu

rem --- Ping Command ---
:ping
cls
set /p host="Enter host to ping: "
if "!host!"=="" (
    echo !color_red!Host cannot be empty.!color_reset!
    pause
    goto menu
)
echo !color_yellow!Pinging %host%...!color_reset!
rem The progress bar runs in parallel to the ping command.
rem It runs for 4 seconds, the typical duration of a default ping.
(
  (
    for /l %%i in (1,1,4) do (
        call :progress_bar %%i 4
        timeout /t 1 /nobreak >nul
    )
  ) & ping %host%
)
echo.
echo !color_green!Done.!color_reset!
pause
goto menu

rem --- Tracert Command ---
:tracert
cls
set /p host="Enter host to tracert: "
if "!host!"=="" (
    echo !color_red!Host cannot be empty.!color_reset!
    pause
    goto menu
)
echo !color_yellow!Running tracert on %host%...!color_reset!
echo !color_yellow!This may take a few moments.!color_reset!
rem The progress bar runs in parallel to the tracert command.
rem It runs for 30 seconds, a rough estimate for a tracert.
(
  (
    for /l %%i in (1,1,30) do (
        call :progress_bar %%i 30
        timeout /t 1 /nobreak >nul
    )
  ) & tracert %host%
)
echo.
echo !color_green!Done.!color_reset!
pause
goto menu

rem ============================================================================
rem  Advanced Network Diagnostics
rem ============================================================================

rem --- Advanced Diagnostics Sub-Menu ---
:advanced_menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!      --- Advanced Diagnostics Menu ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo 1. Measure Latency and Packet Loss
echo 2. Identify Connected Devices
echo 3. Back to Main Menu
echo.
set /p adv_choice="Enter your choice: "

if /i "%adv_choice%"=="1" goto latency_test
if /i "%adv_choice%"=="2" goto connected_devices
if /i "%adv_choice%"=="3" goto menu

rem --- Latency and Packet Loss Test ---
:latency_test
cls
set /p host="Enter host to test: "
if "!host!"=="" (
    echo !color_red!Host cannot be empty.!color_reset!
    pause
    goto advanced_menu
)
echo !color_yellow!Testing latency and packet loss for %host%...!color_reset!
echo !color_yellow!Sending 10 pings... please wait.!color_reset!

rem The progress bar runs in parallel to the ping command.
(
  (
    for /l %%i in (1,1,10) do (
        call :progress_bar %%i 10
        timeout /t 1 /nobreak >nul
    )
  ) & ping -n 10 %host% > ping_results.txt
)


set "avg_latency=Not found"
for /f "tokens=3 delims=," %%a in ('find "Average" ping_results.txt') do (
    for /f "tokens=3 delims== " %%b in ("%%a") do (
        set "avg_latency=%%b"
    )
)

set "packet_loss=Not found"
for /f "tokens=2 delims=()" %%a in ('find "loss" ping_results.txt') do (
    set "packet_loss=%%a"
)
del ping_results.txt

echo.
echo Average Latency: !color_green!%avg_latency%!color_reset!
echo Packet Loss: !color_red!%packet_loss%!color_reset!
echo.
echo !color_green!Done.!color_reset!
pause
goto advanced_menu

rem --- Connected Devices ---
:connected_devices
cls
echo !color_yellow!Identifying connected devices on the local network...!color_reset!
arp -a
echo.
echo !color_green!Done.!color_reset!
pause
goto advanced_menu

rem ============================================================================
rem  Utility Functions
rem ============================================================================

:progress_bar
rem Usage: call :progress_bar current_step total_steps
set /a "percent=(%1*100)/%2"
set /a "progress=(%1*50)/%2"
set "bar="
for /l %%i in (1, 1, !progress!) do (
  set "bar=!bar!█"
)
set "spaces="
for /l %%i in (!progress!, 1, 49) do (
  set "spaces=!spaces! "
)
rem Using carriage return (CR) to overwrite the line.
<nul set /p ".=!bar!!spaces! [%percent%%%]!cr!"
goto :eof

rem ============================================================================
rem  How to Add a New Module
rem ============================================================================
rem 1. Add a menu entry in the :menu section.
rem    Example: echo X. [New] New Feature
rem
rem 2. Add a new 'if' condition in the :menu section to handle the user's choice.
rem    Example: if /i "%choice%"=="X" goto new_feature
rem
rem 3. Create a new label for your feature's code block.
rem    Example: :new_feature
rem
rem 4. Add your command or logic under the new label.
rem
rem 5. End your feature's code block with a 'pause' and a jump back to the menu.
rem    Example:
rem    pause
rem    goto menu
rem ============================================================================

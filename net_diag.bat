@echo off
rem Cambia la página de códigos para soportar caracteres en español.
chcp 1252 > nul
setlocal enabledelayedexpansion

rem ============================================================================
rem  Inicialización y Configuración del Entorno
rem ============================================================================

rem --- Obtener Caracteres Especiales ---
rem Habilita los códigos de escape ANSI para el texto en color.
for /f "tokens=1 delims= " %%a in ('echo prompt $E^| cmd') do (
  set "ESC=%%a"
)
rem Obtiene un carácter de Retorno de Carro (CR) para la barra de progreso.
for /f %%a in ('copy /z "%~f0" nul') do set "cr=%%a"


rem --- Definiciones de Color ---
set "color_reset=!ESC![0m"
set "color_red=!ESC![31m"
set "color_green=!ESC![32m"
set "color_yellow=!ESC![33m"
set "color_blue=!ESC![34m"

rem ============================================================================
rem  Menú Principal
rem ============================================================================
:menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!      --- Herramienta de Diagnóstico de Red ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo Por favor, selecciona una opción:
echo.
echo 1. [IP]       Configuración IP
echo 2. [Ping]     Hacer Ping
echo 3. [Tracert]  Trazar Ruta
echo 4. [Avanzado] Diagnósticos Avanzados
echo 5. [Salir]    Salir
echo.
set /p choice="Introduce tu elección: "

rem --- Lógica del Menú ---
if /i "%choice%"=="1" goto ipconfig_menu
if /i "%choice%"=="2" goto ping
if /i "%choice%"=="3" goto tracert
if /i "%choice%"=="4" goto advanced_menu
if /i "%choice%"=="5" exit

rem ============================================================================
rem  Comandos de Red Principales
rem ============================================================================

rem --- Submenú de Configuración IP ---
:ipconfig_menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!           --- Menú de Configuración IP ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo 1. Mostrar Configuración IP
echo 2. Liberar Dirección IP
echo 3. Renovar Dirección IP
echo 4. Volver al Menú Principal
echo.
set /p ip_choice="Introduce tu elección: "

if /i "%ip_choice%"=="1" goto ipconfig_all
if /i "%ip_choice%"=="2" goto ipconfig_release
if /i "%ip_choice%"=="3" goto ipconfig_renew
if /i "%ip_choice%"=="4" goto menu

:ipconfig_all
cls
echo !color_yellow!Mostrando la configuración IP completa...!color_reset!
ipconfig /all
echo.
echo !color_green!Hecho.!color_reset!
pause
goto ipconfig_menu

:ipconfig_release
cls
echo !color_yellow!Liberando la dirección IP...!color_reset!
ipconfig /release
echo.
echo !color_green!Hecho.!color_reset!
pause
goto ipconfig_menu

:ipconfig_renew
cls
echo !color_yellow!Renovando la dirección IP...!color_reset!
ipconfig /renew
echo.
echo !color_green!Hecho.!color_reset!
pause
goto ipconfig_menu

rem --- Comando Ping ---
:ping
cls
set /p host="Introduce el host para hacer ping: "
if "!host!"=="" (
    echo !color_red!El host no puede estar vacío.!color_reset!
    pause
    goto menu
)
echo !color_yellow!Haciendo ping a %host%...!color_reset!
(
  (
    for /l %%i in (1,1,4) do (
        call :progress_bar %%i 4
        timeout /t 1 /nobreak >nul
    )
  ) & ping %host%
)
echo.
echo !color_green!Hecho.!color_reset!
pause
goto menu

rem --- Comando Tracert ---
:tracert
cls
set /p host="Introduce el host para trazar la ruta: "
if "!host!"=="" (
    echo !color_red!El host no puede estar vacío.!color_reset!
    pause
    goto menu
)
echo !color_yellow!Trazando la ruta a %host%...!color_reset!
echo !color_yellow!Esto puede tardar unos momentos.!color_reset!
(
  (
    for /l %%i in (1,1,30) do (
        call :progress_bar %%i 30
        timeout /t 1 /nobreak >nul
    )
  ) & tracert %host%
)
echo.
echo !color_green!Hecho.!color_reset!
pause
goto menu

rem ============================================================================
rem  Diagnósticos de Red Avanzados
rem ============================================================================

rem --- Submenú de Diagnósticos Avanzados ---
:advanced_menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!      --- Menú de Diagnósticos Avanzados ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo 1. Medir Latencia y Pérdida de Paquetes
echo 2. Identificar Dispositivos Conectados
echo 3. Volver al Menú Principal
echo.
set /p adv_choice="Introduce tu elección: "

if /i "%adv_choice%"=="1" goto latency_test
if /i "%adv_choice%"=="2" goto connected_devices
if /i "%adv_choice%"=="3" goto menu

rem --- Prueba de Latencia y Pérdida de Paquetes ---
:latency_test
cls
set /p host="Introduce el host para la prueba: "
if "!host!"=="" (
    echo !color_red!El host no puede estar vacío.!color_reset!
    pause
    goto advanced_menu
)
echo !color_yellow!Probando latencia y pérdida de paquetes para %host%...!color_reset!
echo !color_yellow!Enviando 10 pings... por favor, espera.!color_reset!

(
  (
    for /l %%i in (1,1,10) do (
        call :progress_bar %%i 10
        timeout /t 1 /nobreak >nul
    )
  ) & ping -n 10 %host% > ping_results.txt
)

set "avg_latency=No encontrado"
for /f "tokens=3 delims=," %%a in ('find "Average" ping_results.txt') do (
    for /f "tokens=3 delims== " %%b in ("%%a") do (
        set "avg_latency=%%b"
    )
)

set "packet_loss=No encontrado"
for /f "tokens=2 delims=()" %%a in ('find "loss" ping_results.txt') do (
    set "packet_loss=%%a"
)
del ping_results.txt

echo.
echo Latencia Promedio: !color_green!%avg_latency%!color_reset!
echo Pérdida de Paquetes: !color_red!%packet_loss%!color_reset!
echo.
echo !color_green!Hecho.!color_reset!
pause
goto advanced_menu

rem --- Dispositivos Conectados ---
:connected_devices
cls
echo !color_yellow!Identificando dispositivos conectados en la red local...!color_reset!
arp -a
echo.
echo !color_green!Hecho.!color_reset!
pause
goto advanced_menu

rem ============================================================================
rem  Funciones de Utilidad
rem ============================================================================

:progress_bar
rem Uso: call :progress_bar paso_actual pasos_totales
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
rem Usando retorno de carro (CR) para sobrescribir la línea.
<nul set /p ".=!bar!!spaces! [!percent!%%]!cr!"
goto :eof

rem ============================================================================
rem  Cómo Añadir un Nuevo Módulo
rem ============================================================================
rem 1. Añade una entrada en el menú en la sección :menu.
rem    Ejemplo: echo X. [Nuevo] Nueva Función
rem
rem 2. Añade una nueva condición 'if' en la sección :menu para manejar la elección.
rem    Ejemplo: if /i "%%choice%%"=="X" goto nueva_funcion
rem
rem 3. Crea una nueva etiqueta para el bloque de código de tu función.
rem    Ejemplo: :nueva_funcion
rem
rem 4. Añade tu comando o lógica bajo la nueva etiqueta.
rem
rem 5. Finaliza el bloque de código de tu función con un 'pause' y un salto al menú.
rem    Ejemplo:
rem    pause
rem    goto menu
rem ============================================================================

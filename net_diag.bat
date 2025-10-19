@echo off
rem Cambia la página de códigos a 850, común para español en consolas de Windows.
chcp 850 > nul
setlocal enabledelayedexpansion

rem ============================================================================
rem  Inicialización y Configuración del Entorno
rem ============================================================================

rem --- Obtener Caracteres Especiales ---
for /f "tokens=1 delims= " %%a in ('echo prompt $E^| cmd') do (
  set "ESC=%%a"
)

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
echo 1. [Auto]     Diagnóstico Automático
echo 2. [IP]       Configuración IP
echo 3. [Ping]     Hacer Ping
echo 4. [Tracert]  Trazar Ruta
echo 5. [Avanzado] Diagnósticos Avanzados
echo 6. [Salir]    Salir
echo.
set /p choice="Introduce tu elección: "

rem --- Lógica del Menú ---
if /i "%choice%"=="1" goto auto_diag
if /i "%choice%"=="2" goto ipconfig_menu
if /i "%choice%"=="3" goto ping_menu
if /i "%choice%"=="4" goto tracert
if /i "%choice%"=="5" goto advanced_menu
if /i "%choice%"=="6" exit

rem ============================================================================
rem  Diagnóstico Automático
rem ============================================================================
:auto_diag
cls
echo !color_yellow!Iniciando diagnóstico automático...!color_reset!
echo.

rem --- Paso 1: Obtener Puerta de Enlace (Router) ---
echo !color_yellow![Paso 1 de 3] Verificando conexión con el router...!color_reset!
set "gateway="
for /f "tokens=3" %%g in ('ipconfig ^| findstr /c:"Puerta de enlace predeterminada" /c:"Default Gateway"') do (
    if "!gateway!"=="" set gateway=%%g
)

if "!gateway!"=="" (
    echo   !color_red!Error: No se pudo encontrar la puerta de enlace (router).!color_reset!
    echo   Asegúrate de estar conectado a una red.
    pause
    goto menu
)

rem --- Paso 2: Ping al Router ---
ping -n 2 !gateway! > nul
if !errorlevel! equ 0 (
    echo   [ !color_green!OK!color_reset! ] Conexión con el router (!gateway!) exitosa.
) else (
    echo   [ !color_red!FALLO!color_reset! ] No se puede contactar con el router (!gateway!).
    echo   !color_red!Problema probable: Cable de red desconectado o fallo en el WiFi/router.!color_reset!
    pause
    goto menu
)

rem --- Paso 3: Ping a Internet ---
echo !color_yellow![Paso 2 de 3] Verificando conexión a Internet...!color_reset!
ping -n 2 8.8.8.8 > nul
if !errorlevel! equ 0 (
    echo   [ !color_green!OK!color_reset! ] Conexión a Internet exitosa.
) else (
    echo   [ !color_red!FALLO!color_reset! ] No se puede conectar a Internet.
    echo   !color_red!Problema probable: El router no tiene conexión a Internet o un firewall está bloqueando el acceso.!color_reset!
    pause
    goto menu
)

rem --- Paso 4: Verificación DNS ---
echo !color_yellow![Paso 3 de 3] Verificando resolución de DNS...!color_reset!
nslookup google.com > nul
if !errorlevel! equ 0 (
    echo   [ !color_green!OK!color_reset! ] Los servidores DNS funcionan correctamente.
) else (
    echo   [ !color_red!FALLO!color_reset! ] Los servidores DNS no responden.
    echo   !color_red!Problema probable: Los DNS configurados no funcionan. Prueba vaciando la caché DNS.!color_reset!
    pause
    goto menu
)

echo.
echo !color_green!================================================================!color_reset!
echo !color_green! El diagnóstico ha finalizado. ¡Tu conexión es totalmente funcional!
!color_green!
echo !color_green!================================================================!color_reset!
echo.
pause
goto menu


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
echo 4. Vaciar Caché de DNS
echo 5. Volver al Menú Principal
echo.
set /p ip_choice="Introduce tu elección: "

if /i "%ip_choice%"=="1" goto ipconfig_all
if /i "%ip_choice%"=="2" goto ipconfig_release
if /i "%ip_choice%"=="3" goto ipconfig_renew
if /i "%ip_choice%"=="4" goto ipconfig_flushdns
if /i "%ip_choice%"=="5" goto menu

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

:ipconfig_flushdns
cls
echo !color_yellow!Vaciando la caché de resolución de DNS...!color_reset!
ipconfig /flushdns
echo.
echo !color_green!Hecho.!color_reset!
pause
goto ipconfig_menu

rem --- Submenú de Ping ---
:ping_menu
cls
echo.
echo !color_blue!===============================================!color_reset!
echo !color_yellow!               --- Menú de Ping ---
!color_reset!
echo !color_blue!===============================================!color_reset!
echo.
echo 1. Ping Estándar (4 paquetes)
echo 2. Ping Extendido (continuo, pulsa Ctrl+C para parar)
echo 3. Volver al Menú Principal
echo.
set /p ping_choice="Introduce tu elección: "

if /i "%ping_choice%"=="1" goto ping_standard
if /i "%ping_choice%"=="2" goto ping_extended
if /i "%ping_choice%"=="3" goto menu

:ping_standard
cls
set /p host="Introduce el host para hacer ping: "
if "!host!"=="" (
    echo !color_red!El host no puede estar vacío.!color_reset!
    pause
    goto ping_menu
)
echo !color_yellow!Haciendo ping estándar a %host%...!color_reset!
ping %host%
echo.
echo !color_green!Hecho.!color_reset!
pause
goto ping_menu

:ping_extended
cls
set /p host="Introduce el host para hacer ping extendido: "
if "!host!"=="" (
    echo !color_red!El host no puede estar vacío.!color_reset!
    pause
    goto ping_menu
)
echo !color_yellow!Haciendo ping extendido a %host%...!color_reset!
echo !color_yellow!Pulsa CTRL+C para detener el ping.!color_reset!
ping %host% -t
echo.
echo !color_green!Hecho.!color_reset!
pause
goto ping_menu


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
tracert %host%
echo.
echo !color_green!Hecho.!color_reset!
pause
goto menu

rem ============================================================================
rem  Diagnósticos de Red Avanzados
rem ============================================================================
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
echo 3. Ver Redes WiFi Guardadas
echo 4. Ver Redes WiFi Disponibles
echo 5. Ver Conexiones de Red Activas (netstat)
echo 6. Consultar DNS (nslookup)
echo 7. Volver al Menú Principal
echo.
set /p adv_choice="Introduce tu elección: "

if /i "%adv_choice%"=="1" goto latency_test
if /i "%adv_choice%"=="2" goto connected_devices
if /i "%adv_choice%"=="3" goto wifi_profiles
if /i "%adv_choice%"=="4" goto wifi_networks
if /i "%adv_choice%"=="5" goto netstat
if /i "%adv_choice%"=="6" goto nslookup
if /i "%adv_choice%"=="7" goto menu

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
ping -n 10 %host% > ping_results.txt
set "avg_latency=No encontrado"
for /f "tokens=3 delims=," %%a in ('findstr /c:"Average" /c:"Promedio" ping_results.txt') do (
    for /f "tokens=3 delims== " %%b in ("%%a") do (
        set "avg_latency=%%b"
    )
)
set "packet_loss=No encontrado"
for /f "tokens=2 delims=()" %%a in ('findstr /c:"loss" /c:"perdidos" ping_results.txt') do (
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

rem --- Redes WiFi Guardadas ---
:wifi_profiles
cls
echo !color_yellow!Mostrando redes WiFi guardadas...!color_reset!
netsh wlan show profiles
echo.
echo !color_green!Hecho.!color_reset!
pause
goto advanced_menu

rem --- Redes WiFi Disponibles ---
:wifi_networks
cls
echo !color_yellow!Buscando redes WiFi disponibles...!color_reset!
netsh wlan show networks
echo.
echo !color_green!Hecho.!color_reset!
pause
goto advanced_menu

rem --- Netstat ---
:netstat
cls
echo !color_yellow!Mostrando conexiones de red activas...!color_reset!
netstat -an
echo.
echo !color_green!Hecho.!color_reset!
pause
goto advanced_menu

rem --- NSLookup ---
:nslookup
cls
set /p domain="Introduce el dominio a consultar (ej: google.com): "
if "!domain!"=="" (
    echo !color_red!El dominio no puede estar vacío.!color_reset!
    pause
    goto advanced_menu
)
echo !color_yellow!Consultando DNS para !domain!... !color_reset!
nslookup !domain!
echo.
echo !color_green!Hecho.!color_reset!
pause
goto advanced_menu

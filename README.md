# Herramienta de Diagnóstico de Red "Navaja Suiza" (Python)

¡Bienvenido a la nueva y mejorada Herramienta de Diagnóstico de Red! 🛠️

Esta herramienta ha sido completamente reescrita en **Python** para ofrecer compatibilidad multiplataforma (Windows, Linux, macOS) y funcionalidades avanzadas que no eran posibles en la versión anterior.

---

## 🚀 Nuevas Funcionalidades (Versión 2.0)

Además de todas las funciones clásicas, ahora incluye:
*   **Compatibilidad Total**: Funciona en Windows, Linux y macOS. 💻🐧🍎
*   **Escáner de Red Local**: Descubre dispositivos conectados a tu red mediante un barrido de ping.
*   **Escáner de Puertos**: Comprueba qué puertos (servicios) están abiertos en un dispositivo. 🔓
*   **Test de Velocidad de Internet**: Mide tu velocidad de descarga real. ⚡
*   **Información Pública y GeoIP**: Muestra tu IP pública, proveedor (ISP) y ubicación aproximada. 🌍
*   **Búsqueda de Fabricante MAC**: Identifica la marca de los dispositivos conectados. 🏭

---

## 📋 Requisitos e Instalación

Necesitas tener **Python 3** instalado en tu sistema.

1.  **Instalar Python** (si no lo tienes):
    *   **Windows**: Descárgalo en [python.org](https://www.python.org/downloads/).
    *   **Linux**: `sudo apt install python3`
    *   **macOS**: Viene preinstalado o `brew install python`.

2.  **Ejecutar la herramienta**:
    Abre tu terminal o consola y ejecuta:
    ```bash
    python3 net_diag.py
    ```
    *(En Windows puede ser simplemente `python net_diag.py`)*

---

## 🛠️ Menú de Opciones

1.  **Auto Diagnostics**: Revisa conexión a Internet y DNS automáticamente.
2.  **Ping Utility**: Comprueba la latencia con cualquier servidor.
3.  **Traceroute**: Ve la ruta que toman tus datos.
4.  **Local Network Scanner**: Escanea tu red WiFi/LAN para encontrar otros equipos.
5.  **Port Scanner**: Revisa puertos abiertos (TCP) en una IP específica.
6.  **WiFi Profiles**: (Windows) Recupera contraseñas guardadas. (Linux/Mac) Muestra perfiles.
7.  **System & Public IP**: Muestra info de tu PC e IP pública.
8.  **Internet Speed Test**: Prueba de velocidad de descarga.
9.  **Config**: Herramientas extra (Netstat, liberar IP, DNS).

---

## 📝 Notas Importantes
*   **Permisos**: Algunas funciones (como liberar IP o escaneos profundos) pueden requerir ejecutar la terminal como **Administrador** (Windows) o con `sudo` (Linux/Mac).
*   **WiFi Passwords**: La recuperación automática de contraseñas WiFi es nativa de Windows. En Linux/Mac, la herramienta te indicará los comandos manuales por seguridad.

¡Disfruta de tu nueva navaja suiza de red! 🎉

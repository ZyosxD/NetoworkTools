# Herramienta de Diagnóstico de Red

¡Hola! 👋 ¡Bienvenido a la Herramienta de Diagnóstico de Red!

Esta es una aplicación de línea de comandos todo-en-uno para Windows, diseñada para ser tu asistente personal en la solución de problemas de red. Desde diagnósticos automáticos hasta herramientas avanzadas, todo está aquí. 🛠️

---

## 🚀 ¿Qué puedes hacer con esta herramienta?

Esta versión es mucho más potente. Aquí tienes un resumen de todo lo que incluye:

### **Funciones Clave**
*   **Generación Automática de Logs** 📝: ¡Todas las operaciones que realizas en una sesión se guardan automáticamente! Al salir, se generará un archivo `.txt` con el resumen completo de los diagnósticos.
*   **Diagnóstico Automático** 🩺: Ejecuta una serie de pruebas (conexión con el router, acceso a internet, resolución DNS) y te dice exactamente dónde está el problema.
*   **Configuración IP** 📄: Revisa todos los detalles de tu conexión (IP, puerta de enlace, DNS) y vacía la caché de DNS.
*   **Ping** 핑: Comprueba si un servidor está en línea, con opción de ping estándar o extendido (`-t`).
*   **Tracert (Trazar Ruta)** 🗺️: Descubre la ruta que toman tus datos para llegar a un destino.

### **Diagnósticos Avanzados**
*   **Medir Latencia y Paquetes Perdidos** 🔬: Realiza una prueba para medir la calidad de tu conexión.
*   **NUEVO ✨: Identificar Dispositivos Conectados (con Fabricante)** 🏭: Muestra una lista de todos los dispositivos en tu red local, y ahora ¡también identifica al fabricante de cada dispositivo (Apple, Samsung, etc.) a partir de su dirección MAC! (Nota: esta función requiere conexión a internet).
*   **Gestión de WiFi** 📶:
    *   **Ver Redes WiFi Guardadas**: Muestra una lista de todas las redes WiFi que has guardado.
    *   **Ver Redes WiFi Disponibles**: Escanea y muestra las redes WiFi a tu alcance.
    *   **Ver Contraseña de WiFi Guardada**: Muestra la contraseña de una red WiFi guardada.
*   **Herramientas Adicionales** ⚙️:
    *   **Ver Conexiones Activas (`netstat`)**: Lista todas las conexiones de red de tu ordenador.
    *   **Consultar DNS (`nslookup`)**: Traduce un nombre de dominio a su dirección IP.

---

## 📋 Cómo Empezar

1.  **Descarga el archivo**: Asegúrate de tener el archivo `net_diag.bat`.
2.  **Abre una consola de comandos**: Pulsa **Windows + R**, escribe `cmd` y pulsa **Enter**.
3.  **Navega hasta la carpeta**: Usa el comando `cd` para moverte a la carpeta donde guardaste el archivo.
4.  **Ejecuta la herramienta**:
    ```
    net_diag.bat
    ```
5.  **¡Listo!** 🎉 Se abrirá el menú. Al salir, la herramienta te informará del nombre del archivo de log que ha sido creado.

---

¡Espero que esta versión súper mejorada te sea de gran ayuda! 😊

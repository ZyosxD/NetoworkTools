# Herramienta de Diagnóstico de Red

¡Hola! 👋 ¡Bienvenido a la Herramienta de Diagnóstico de Red!

Esta es una aplicación de línea de comandos todo-en-uno para Windows, diseñada para ser tu asistente personal en la solución de problemas de red. Desde diagnósticos automáticos hasta herramientas avanzadas, todo está aquí. 🛠️

---

## 🚀 ¿Qué puedes hacer con esta herramienta?

Esta versión es mucho más potente. Aquí tienes un resumen de todo lo que incluye:

### **Funciones Clave**
*   **NUEVO ✨: Generación Automática de Logs** 📝: ¡Todas las operaciones que realizas en una sesión se guardan automáticamente! Al salir de la herramienta, se generará un archivo `.txt` con el resumen completo de los diagnósticos, perfecto para revisar más tarde o compartir con un técnico.
*   **Diagnóstico Automático** 🩺: ¿No estás seguro de qué pasa? Esta opción ejecuta una serie de pruebas (conexión con el router, acceso a internet, resolución DNS) y te dice exactamente dónde está el problema con un resumen fácil de entender.
*   **Configuración IP** 📄: Revisa todos los detalles de tu conexión (IP, puerta de enlace, DNS).
    *   También puedes **vaciar la caché de DNS** (`flushdns`) desde aquí.
*   **Ping** 핑: Comprueba si un servidor está en línea.
    *   Elige entre un **ping estándar** o un **ping extendido** (`-t`) para monitorear la conexión y detectar pérdidas de paquetes.
*   **Tracert (Trazar Ruta)** 🗺️: Descubre la ruta que toman tus datos para llegar a un destino.

### **Diagnósticos Avanzados**
*   **Medir Latencia y Paquetes Perdidos** 🔬: Realiza una prueba para medir la calidad de tu conexión.
*   **Ver Dispositivos Conectados** 💻: Muestra una lista de dispositivos en tu red local.
*   **Gestión de WiFi** 📶:
    *   **Ver Redes WiFi Guardadas**: Muestra una lista de todas las redes WiFi que has guardado en tu equipo.
    *   **Ver Redes WiFi Disponibles**: Escanea y muestra las redes WiFi a tu alcance.
    *   **Ver Contraseña de WiFi Guardada**: ¡Puedes ver la contraseña de una red WiFi que ya tengas guardada!
*   **Herramientas Adicionales** ⚙️:
    *   **Ver Conexiones Activas (`netstat`)**: Lista todas las conexiones de red entrantes y salientes de tu ordenador.
    *   **Consultar DNS (`nslookup`)**: Traduce un nombre de dominio (como `google.com`) a su dirección IP.

---

## 📋 Cómo Empezar

¡Usar la herramienta sigue siendo súper fácil!

1.  **Descarga el archivo**: Asegúrate de tener el archivo `net_diag.bat`.
2.  **Abre una consola de comandos**: Pulsa **Windows + R**, escribe `cmd` y pulsa **Enter**.
3.  **Navega hasta la carpeta**: Usa el comando `cd` para moverte a la carpeta donde guardaste el archivo.
4.  **Ejecuta la herramienta**:
    ```
    net_diag.bat
    ```
5.  **¡Listo!** 🎉 Se abrirá el menú, donde podrás elegir la opción que necesites. Al salir, la herramienta te informará del nombre del archivo de log que ha sido creado.

---

¡Espero que esta versión súper mejorada te sea de gran ayuda! 😊

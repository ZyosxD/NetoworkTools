import os
import sys
import subprocess
import socket
import platform
import threading
import json
import urllib.request
import time
import logging
import datetime

# ==============================================================================
# Logger Class
# ==============================================================================
class Logger:
    def __init__(self):
        self.log_file = f"diag_session_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        logging.basicConfig(
            filename=self.log_file,
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        self.console = logging.StreamHandler(sys.stdout)
        self.console.setLevel(logging.INFO)
        # We don't add console handler to root logger to avoid double printing if we use print()
        # Instead, we will use a custom log method that prints and logs.

    def log(self, message, level="INFO", print_to_console=True, color=None):
        """
        Logs a message to the file and optionally prints it to the console.
        """
        if print_to_console:
            final_msg = message
            if color:
                final_msg = f"{color}{message}{PlatformHelper.COLORS['RESET']}"
            print(final_msg)

        if level == "INFO":
            logging.info(message)
        elif level == "ERROR":
            logging.error(message)
        elif level == "WARNING":
            logging.warning(message)

    def get_log_filename(self):
        return self.log_file

# ==============================================================================
# PlatformHelper Class
# ==============================================================================
class PlatformHelper:
    OS_NAME = platform.system()  # Windows, Linux, Darwin

    COLORS = {
        "RESET": "\033[0m",
        "RED": "\033[91m",
        "GREEN": "\033[92m",
        "YELLOW": "\033[93m",
        "BLUE": "\033[94m",
        "CYAN": "\033[96m",
        "BOLD": "\033[1m"
    }

    @staticmethod
    def clear_screen():
        if PlatformHelper.OS_NAME == "Windows":
            os.system("cls")
        else:
            os.system("clear")

    @staticmethod
    def get_ping_cmd(host, count=4):
        flag = "-n" if PlatformHelper.OS_NAME == "Windows" else "-c"
        return ["ping", flag, str(count), host]

    @staticmethod
    def get_tracert_cmd(host):
        if PlatformHelper.OS_NAME == "Windows":
            return ["tracert", host]
        else:
            return ["traceroute", host] # Linux/Mac might need installation, usually pre-installed on Mac

    @staticmethod
    def is_admin():
        try:
            if PlatformHelper.OS_NAME == "Windows":
                import ctypes
                return ctypes.windll.shell32.IsUserAnAdmin() != 0
            else:
                return os.geteuid() == 0
        except:
            return False

# Initialize Global Objects
logger = Logger()

# ==============================================================================
# Main Menu
# ==============================================================================
def main_menu():
    while True:
        # Don't clear screen immediately so user can see previous output
        print("\n" + "="*60)
        logger.log("   --- Python Network Diagnostic Tool (Swiss Army Knife) ---   ", color=PlatformHelper.COLORS['BLUE'], print_to_console=True)
        print("="*60)
        print("1. [Auto]     Automatic Diagnostics")
        print("2. [Ping]     Ping Utility")
        print("3. [Trace]    Traceroute")
        print("4. [Scan]     Local Network Scanner (Ping Sweep)")
        print("5. [Port]     Port Scanner (TCP)")
        print("6. [WiFi]     WiFi Profiles & Passwords")
        print("7. [Info]     System & Public IP Info")
        print("8. [Speed]    Internet Speed Test")
        print("9. [Config]   IP Configuration / Netstat / DNS")
        print("0. [Exit]     Exit")
        print("="*60)

        choice = input("Enter selection: ").strip()
        print() # Spacer

        if choice == '0':
            logger.log("Exiting tool. Goodbye!", color=PlatformHelper.COLORS['GREEN'])
            break

        elif choice == '1':
            logger.log("--- Starting Automatic Diagnostics ---", color=PlatformHelper.COLORS['CYAN'])
            # 1. Gateway Check (Assuming typical gateways end in .1 or we parse it)
            # Parsing gateway is complex cross-platform. We'll skip straight to internet check.
            # 2. Internet
            NetworkOps.ping_host("8.8.8.8", 2)
            # 3. DNS
            NetworkOps.nslookup("google.com")

        elif choice == '2':
            host = input("Enter host to ping (e.g., google.com): ").strip()
            if host: NetworkOps.ping_host(host)

        elif choice == '3':
            host = input("Enter host to trace (e.g., google.com): ").strip()
            if host: NetworkOps.traceroute_host(host)

        elif choice == '4':
            base = input("Enter subnet base (e.g., 192.168.1): ").strip()
            if base:
                Scanner.scan_local_network(base)

        elif choice == '5':
            host = input("Enter IP to scan ports: ").strip()
            if host: Scanner.port_scan(host)

        elif choice == '6':
            WiFiOps.get_saved_profiles()
            sub = input("Enter profile name to show password (or Enter to skip): ").strip()
            if sub: WiFiOps.get_wifi_password(sub)

        elif choice == '7':
            Tools.get_system_info()
            Tools.get_public_ip()

        elif choice == '8':
            Tools.speed_test()

        elif choice == '9':
            print("1. Netstat (Active Connections)")
            print("2. Release/Renew IP")
            print("3. Flush DNS (Windows Only)")
            sub = input("Selection: ").strip()
            if sub == '1':
                NetworkOps.get_active_connections()
            elif sub == '2':
                WiFiOps.release_renew_ip()
            elif sub == '3':
                if PlatformHelper.OS_NAME == "Windows":
                    NetworkOps.run_command(["ipconfig", "/flushdns"], "Flush DNS")
                else:
                    logger.log("Flush DNS is OS specific (systemd-resolve --flush-caches on Linux).", color=PlatformHelper.COLORS['YELLOW'])

        else:
            print("Invalid selection.")

        input("\nPress Enter to return to menu...")
        PlatformHelper.clear_screen()

if __name__ == "__main__":
    try:
        PlatformHelper.clear_screen()
        logger.log("Initializing Network Diagnostic Tool...", color=PlatformHelper.COLORS['BLUE'])
        logger.log(f"Detected OS: {PlatformHelper.OS_NAME}")
        logger.log(f"Session Log: {logger.get_log_filename()}")
        main_menu()
    except KeyboardInterrupt:
        logger.log("\nExecution interrupted by user.", level="WARNING")
    except Exception as e:
        logger.log(f"Unexpected Error: {str(e)}", level="ERROR")

# ==============================================================================
# NetworkOps Class
# ==============================================================================
class NetworkOps:
    @staticmethod
    def run_command(command_list, description):
        """
        Executes a shell command and returns the output (stdout).
        Logs the execution and result.
        """
        cmd_str = " ".join(command_list)
        logger.log(f"\n[Running] {description} ({cmd_str})...", color=PlatformHelper.COLORS['YELLOW'])

        try:
            # shell=False is safer, but command_list must be split properly.
            # capturing stderr as well.
            result = subprocess.run(
                command_list,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True
            )
            output = result.stdout.strip()

            if result.returncode == 0:
                logger.log(output)
                logger.log("[SUCCESS]", color=PlatformHelper.COLORS['GREEN'])
                return True, output
            else:
                logger.log(output)
                logger.log("[FAILED]", color=PlatformHelper.COLORS['RED'])
                return False, output
        except FileNotFoundError:
            err_msg = f"Command not found: {command_list[0]}"
            logger.log(err_msg, level="ERROR", color=PlatformHelper.COLORS['RED'])
            return False, err_msg
        except Exception as e:
            err_msg = f"Error executing command: {str(e)}"
            logger.log(err_msg, level="ERROR", color=PlatformHelper.COLORS['RED'])
            return False, err_msg

    @staticmethod
    def ping_host(host, count=4):
        cmd = PlatformHelper.get_ping_cmd(host, count)
        return NetworkOps.run_command(cmd, f"Ping {host}")

    @staticmethod
    def traceroute_host(host):
        cmd = PlatformHelper.get_tracert_cmd(host)
        return NetworkOps.run_command(cmd, f"Traceroute {host}")

    @staticmethod
    def nslookup(domain):
        cmd = ["nslookup", domain]
        return NetworkOps.run_command(cmd, f"DNS Lookup {domain}")

    @staticmethod
    def get_active_connections():
        # -an displays addresses and port numbers in numerical form
        cmd = ["netstat", "-an"]
        return NetworkOps.run_command(cmd, "Active Connections")

# ==============================================================================
# Scanner Class (Advanced)
# ==============================================================================
class Scanner:
    @staticmethod
    def _ping_worker(ip, active_hosts, lock):
        # Silent ping, short timeout
        cmd = PlatformHelper.get_ping_cmd(ip, count=1)
        # Windows ping timeout is in ms (-w), Linux is in sec (-W)
        # macOS (Darwin) ping timeout is in ms (-W)
        if PlatformHelper.OS_NAME == "Windows":
             cmd.extend(["-w", "200"]) # 200ms
        elif PlatformHelper.OS_NAME == "Darwin":
             cmd.extend(["-W", "1000"]) # 1000ms
        else:
             cmd.extend(["-W", "1"])   # 1s

        try:
            # We don't use NetworkOps.run_command to avoid spamming logs for every IP
            result = subprocess.run(
                cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            )
            if result.returncode == 0:
                with lock:
                    active_hosts.append(ip)
        except:
            pass

    @staticmethod
    def scan_local_network(subnet_base):
        """
        Scans a Class C subnet (e.g. 192.168.1) for active hosts.
        Uses threading for speed.
        Returns a list of dictionaries: {'ip': ip, 'mac': mac, 'vendor': vendor}
        """
        logger.log(f"Scanning subnet {subnet_base}.1 - 254...", color=PlatformHelper.COLORS['YELLOW'])
        active_hosts = []
        threads = []
        lock = threading.Lock()

        # 1. Ping Sweep to populate ARP table
        for i in range(1, 255):
            ip = f"{subnet_base}.{i}"
            t = threading.Thread(target=Scanner._ping_worker, args=(ip, active_hosts, lock))
            t.start()
            threads.append(t)
            if i % 50 == 0: time.sleep(0.1)

        for t in threads:
            t.join()

        logger.log(f"Found {len(active_hosts)} active hosts.", color=PlatformHelper.COLORS['GREEN'])

        # 2. Extract MACs from ARP Table and lookup Vendor
        results = []
        try:
            # Run arp -a to get the full table
            cmd = ["arp", "-a"]
            proc = subprocess.run(cmd, stdout=subprocess.PIPE, text=True)
            arp_output = proc.stdout

            # Simple line-by-line parsing
            # Windows: "  192.168.1.1          00-11-22-33-44-55     dynamic"
            # Linux:   "? (192.168.1.1) at 00:11:22:33:44:55 [ether] on eth0"

            for ip in active_hosts:
                mac = "Unknown"
                vendor = "Unknown"

                # Try to find IP in arp output
                # We look for the IP followed by some MAC-like pattern
                for line in arp_output.splitlines():
                    if ip in line:
                        # Rudimentary extraction of MAC: look for hex-hex-... or hex:hex:...
                        # Regex would be better but keeping it stdlib simple without re module complexity if possible,
                        # but re is standard. Let's use simple string splitting for robustness.
                        parts = line.split()
                        for part in parts:
                            # MAC check (basic len and chars)
                            # MacOS/BSD can drop leading zeros (e.g. 0:a:b:c:d:e)
                            # So we check for presence of ':' or '-' and at least 5 separators
                            if (part.count(':') == 5 or part.count('-') == 5) and len(part) >= 11:
                                mac = part
                                break

                if mac != "Unknown":
                    vendor = Scanner.get_mac_vendor(mac)

                results.append({'ip': ip, 'mac': mac, 'vendor': vendor})
                logger.log(f"Host: {ip} | MAC: {mac} | Vendor: {vendor}")

        except Exception as e:
            logger.log(f"Error parsing ARP table: {str(e)}", level="ERROR")
            # Fallback: just return IPs
            for ip in active_hosts:
                results.append({'ip': ip, 'mac': "Unknown", 'vendor': "Unknown"})

        return results

    @staticmethod
    def _port_worker(ip, port, open_ports, lock):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1.0)
        try:
            result = s.connect_ex((ip, port))
            if result == 0:
                with lock:
                    open_ports.append(port)
        except:
            pass
        finally:
            s.close()

    @staticmethod
    def port_scan(ip, ports=[21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 3306, 3389, 5432, 8080]):
        """
        Scans common TCP ports on a target IP.
        """
        logger.log(f"Scanning ports on {ip}...", color=PlatformHelper.COLORS['YELLOW'])
        open_ports = []
        threads = []
        lock = threading.Lock()

        for port in ports:
            t = threading.Thread(target=Scanner._port_worker, args=(ip, port, open_ports, lock))
            t.start()
            threads.append(t)

        for t in threads:
            t.join()

        open_ports.sort()
        if open_ports:
             logger.log(f"Open ports on {ip}: {open_ports}", color=PlatformHelper.COLORS['GREEN'])
        else:
             logger.log(f"No open common ports found on {ip}.", color=PlatformHelper.COLORS['YELLOW'])
        return open_ports

    @staticmethod
    def get_mac_vendor(mac_address):
        """
        Queries api.macvendors.com for the vendor.
        """
        logger.log(f"Looking up vendor for MAC: {mac_address}...", color=PlatformHelper.COLORS['YELLOW'])
        url = f"https://api.macvendors.com/{mac_address}"
        try:
            # Need a delay as this API is rate limited (1 req/sec usually)
            time.sleep(1.1)
            req = urllib.request.Request(url)
            with urllib.request.urlopen(req) as response:
                vendor = response.read().decode('utf-8').strip()
                logger.log(f"Vendor: {vendor}", color=PlatformHelper.COLORS['GREEN'])
                return vendor
        except urllib.error.HTTPError as e:
            logger.log(f"Vendor Lookup Failed: {e.code}", level="WARNING")
            return "Unknown"
        except Exception as e:
            logger.log(f"Vendor Lookup Error: {str(e)}", level="ERROR")
            return "Error"

# ==============================================================================
# Tools Class (Bandwidth & Info)
# ==============================================================================
class Tools:
    @staticmethod
    def speed_test():
        """
        Downloads a test file to measure bandwidth.
        Uses a known reliable speedtest file (10MB).
        """
        url = "http://speedtest.tele2.net/10MB.zip"
        file_size_mb = 10
        logger.log(f"Running download speed test (Target: {url})...", color=PlatformHelper.COLORS['YELLOW'])

        start_time = time.time()
        try:
            with urllib.request.urlopen(url) as response:
                while True:
                    chunk = response.read(1024*1024) # read in 1MB chunks
                    if not chunk:
                        break
            end_time = time.time()
            duration = end_time - start_time
            if duration > 0:
                speed_mbps = (file_size_mb * 8) / duration
                logger.log(f"Download completed in {duration:.2f} seconds.", color=PlatformHelper.COLORS['GREEN'])
                logger.log(f"Estimated Speed: {speed_mbps:.2f} Mbps", color=PlatformHelper.COLORS['CYAN'])
            else:
                logger.log("Download too fast to measure!", color=PlatformHelper.COLORS['GREEN'])
        except Exception as e:
            logger.log(f"Speed test failed: {str(e)}", level="ERROR", color=PlatformHelper.COLORS['RED'])

    @staticmethod
    def get_public_ip():
        """
        Gets public IP and location info.
        """
        logger.log("Fetching Public IP and Location...", color=PlatformHelper.COLORS['YELLOW'])
        try:
            # ip-api.com provides free JSON API without key for non-commercial use
            with urllib.request.urlopen("http://ip-api.com/json") as response:
                data = json.loads(response.read().decode())
                if data['status'] == 'success':
                    logger.log(f"Public IP: {data['query']}", color=PlatformHelper.COLORS['GREEN'])
                    logger.log(f"Location: {data['city']}, {data['country']}", color=PlatformHelper.COLORS['GREEN'])
                    logger.log(f"ISP: {data['isp']}", color=PlatformHelper.COLORS['GREEN'])
                else:
                    logger.log("Could not retrieve public IP details.", level="WARNING")
        except Exception as e:
            logger.log(f"Error fetching public IP: {str(e)}", level="ERROR")

    @staticmethod
    def get_system_info():
        """
        Displays basic system info.
        """
        logger.log("Gathering System Information...", color=PlatformHelper.COLORS['YELLOW'])
        info = {
            "OS": f"{platform.system()} {platform.release()}",
            "Architecture": platform.machine(),
            "Processor": platform.processor(),
            "Python Version": platform.python_version(),
            "Hostname": socket.gethostname()
        }
        for k, v in info.items():
            logger.log(f"{k}: {v}")

        # Get local Interface info
        try:
            # Simple wrapper to get local IP (socket hack to find route)
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            local_ip = s.getsockname()[0]
            s.close()
            logger.log(f"Local IP (Preferred): {local_ip}", color=PlatformHelper.COLORS['CYAN'])
        except:
             logger.log("Could not determine local IP.", level="WARNING")

        # Display Full IP Config
        logger.log("\n--- Full Network Configuration ---", color=PlatformHelper.COLORS['BLUE'])
        if PlatformHelper.OS_NAME == "Windows":
             NetworkOps.run_command(["ipconfig", "/all"], "IP Config")
        else:
             # Linux/Mac
             if os.path.exists("/usr/sbin/ip"):
                 NetworkOps.run_command(["ip", "a"], "IP Address Info")
                 NetworkOps.run_command(["ip", "route"], "IP Route Info")
             else:
                 NetworkOps.run_command(["ifconfig"], "Interface Config")
                 NetworkOps.run_command(["netstat", "-rn"], "Routing Table")

# ==============================================================================
# WiFiOps Class
# ==============================================================================
class WiFiOps:
    @staticmethod
    def get_saved_profiles():
        """
        Lists saved WiFi profiles.
        """
        if PlatformHelper.OS_NAME == "Windows":
             NetworkOps.run_command(["netsh", "wlan", "show", "profiles"], "List WiFi Profiles")
        elif PlatformHelper.OS_NAME == "Linux":
             # Try nmcli
             NetworkOps.run_command(["nmcli", "connection", "show"], "List WiFi Connections (nmcli)")
        elif PlatformHelper.OS_NAME == "Darwin":
             # Mac
             logger.log("Listing Known Networks on macOS (may require admin)...")
             # This command lists all preferred networks
             NetworkOps.run_command(["networksetup", "-listpreferredwirelessnetworks", "en0"], "List WiFi Networks")

    @staticmethod
    def get_wifi_password(profile_name):
        """
        Attempts to retrieve the password for a given profile.
        """
        if PlatformHelper.OS_NAME == "Windows":
             cmd = ["netsh", "wlan", "show", "profile", f"name={profile_name}", "key=clear"]
             NetworkOps.run_command(cmd, f"Get Password for {profile_name}")
        elif PlatformHelper.OS_NAME == "Linux":
             logger.log("On Linux, WiFi passwords are typically stored in /etc/NetworkManager/system-connections/", color=PlatformHelper.COLORS['YELLOW'])
             logger.log(f"Run: sudo cat /etc/NetworkManager/system-connections/{profile_name}.nmconnection", color=PlatformHelper.COLORS['CYAN'])
        elif PlatformHelper.OS_NAME == "Darwin":
             logger.log("On macOS, retrieving passwords requires Keychain access.", color=PlatformHelper.COLORS['YELLOW'])
             cmd = ["security", "find-generic-password", "-wa", profile_name]
             logger.log(f"Running: {' '.join(cmd)}")
             NetworkOps.run_command(cmd, "Keychain Lookup")

    @staticmethod
    def release_renew_ip():
        if PlatformHelper.OS_NAME == "Windows":
             NetworkOps.run_command(["ipconfig", "/release"], "Release IP")
             NetworkOps.run_command(["ipconfig", "/renew"], "Renew IP")
        else:
             # Linux/Mac usually requires sudo dhclient -r && sudo dhclient
             logger.log("Release/Renew on Linux/Mac requires root privileges.", color=PlatformHelper.COLORS['YELLOW'])
             cmd = "sudo dhclient -r && sudo dhclient"
             logger.log(f"Please run: {cmd}", color=PlatformHelper.COLORS['CYAN'])
             # We can try to run it, but it might fail without sudo
             # subprocess.run(cmd, shell=True)

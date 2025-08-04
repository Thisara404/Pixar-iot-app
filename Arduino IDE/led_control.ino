#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>

const char* ssid = "Dialog_4G_531";     // Replace with your WiFi name
const char* password = "A164905D"; // Replace with your WiFi password
const int LED_PIN = 5; // D1 (GPIO5)

ESP8266WebServer server(80);
bool ledState = false;

// HTML page stored in PROGMEM to save RAM
const char MAIN_page[] PROGMEM = R"=====(
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NodeMCU LED Control</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 400px;
            width: 100%;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        h1 {
            color: #333;
            margin-bottom: 30px;
            font-size: 2.2em;
            font-weight: 600;
        }

        .led-display {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            margin: 30px auto;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1em;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 2px;
            transition: all 0.3s ease;
            border: 4px solid #ddd;
            position: relative;
            overflow: hidden;
        }

        .led-display.on {
            background: radial-gradient(circle, #4CAF50, #45a049);
            color: white;
            border-color: #4CAF50;
            box-shadow: 0 0 30px rgba(76, 175, 80, 0.6);
            animation: pulse 2s infinite;
        }

        .led-display.off {
            background: linear-gradient(135deg, #f5f5f5, #e0e0e0);
            color: #666;
            border-color: #ccc;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 30px rgba(76, 175, 80, 0.6); }
            50% { box-shadow: 0 0 50px rgba(76, 175, 80, 0.8); }
            100% { box-shadow: 0 0 30px rgba(76, 175, 80, 0.6); }
        }

        .status-text {
            font-size: 1.3em;
            margin: 20px 0;
            font-weight: 500;
            color: #555;
        }

        .controls {
            display: flex;
            gap: 15px;
            margin: 30px 0;
            flex-wrap: wrap;
            justify-content: center;
        }

        .btn {
            padding: 15px 30px;
            border: none;
            border-radius: 50px;
            font-size: 1.1em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 1px;
            position: relative;
            overflow: hidden;
            min-width: 120px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
        }

        .btn:active {
            transform: translateY(0);
        }

        .btn-on {
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
        }

        .btn-on:hover {
            background: linear-gradient(135deg, #45a049, #3d8b40);
        }

        .btn-off {
            background: linear-gradient(135deg, #f44336, #d32f2f);
            color: white;
        }

        .btn-off:hover {
            background: linear-gradient(135deg, #d32f2f, #c62828);
        }

        .btn-status {
            background: linear-gradient(135deg, #2196F3, #1976D2);
            color: white;
        }

        .btn-status:hover {
            background: linear-gradient(135deg, #1976D2, #1565C0);
        }

        .connection-status {
            margin-top: 20px;
            padding: 10px;
            border-radius: 10px;
            font-size: 0.9em;
            font-weight: 500;
        }

        .connection-status.connected {
            background: rgba(76, 175, 80, 0.1);
            color: #2E7D32;
            border: 1px solid rgba(76, 175, 80, 0.3);
        }

        .connection-status.disconnected {
            background: rgba(244, 67, 54, 0.1);
            color: #C62828;
            border: 1px solid rgba(244, 67, 54, 0.3);
        }

        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #3498db;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-left: 10px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .message {
            margin-top: 15px;
            padding: 10px;
            border-radius: 8px;
            font-size: 0.9em;
            transition: all 0.3s ease;
        }

        .message.success {
            background: rgba(76, 175, 80, 0.1);
            color: #2E7D32;
            border: 1px solid rgba(76, 175, 80, 0.3);
        }

        .message.error {
            background: rgba(244, 67, 54, 0.1);
            color: #C62828;
            border: 1px solid rgba(244, 67, 54, 0.3);
        }

        @media (max-width: 480px) {
            .container {
                padding: 30px 20px;
            }
            
            .controls {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔌 NodeMCU LED Control</h1>
        
        <div class="led-display off" id="ledDisplay">
            OFF
        </div>
        
        <div class="status-text" id="statusText">
            LED is currently OFF
        </div>
        
        <div class="controls">
            <button class="btn btn-on" id="btnOn" onclick="controlLED('on')">
                ⚡ Turn ON
            </button>
            <button class="btn btn-off" id="btnOff" onclick="controlLED('off')">
                🔴 Turn OFF
            </button>
            <button class="btn btn-status" id="btnStatus" onclick="checkStatus()">
                📊 Check Status
            </button>
        </div>
        
        <div class="connection-status connected" id="connectionStatus">
            🟢 Connected to NodeMCU
        </div>
        
        <div class="message" id="message" style="display: none;"></div>
    </div>

    <script>
        let isConnected = true;
        
        // Check initial status when page loads
        window.onload = function() {
            checkStatus();
        };
        
        async function controlLED(action) {
            const button = action === 'on' ? document.getElementById('btnOn') : document.getElementById('btnOff');
            const originalText = button.innerHTML;
            
            // Show loading state
            button.innerHTML = originalText + '<span class="loading"></span>';
            button.disabled = true;
            
            try {
                const response = await fetch(`/led/${action}`, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',
                    }
                });
                
                if (response.ok) {
                    const data = await response.json();
                    updateLEDDisplay(data.led_state);
                    showMessage(data.message, 'success');
                    updateConnectionStatus(true);
                } else {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
            } catch (error) {
                console.error('Error:', error);
                showMessage('Failed to control LED. Check connection.', 'error');
                updateConnectionStatus(false);
            } finally {
                // Restore button
                button.innerHTML = originalText;
                button.disabled = false;
            }
        }
        
        async function checkStatus() {
            const button = document.getElementById('btnStatus');
            const originalText = button.innerHTML;
            
            // Show loading state
            button.innerHTML = originalText + '<span class="loading"></span>';
            button.disabled = true;
            
            try {
                const response = await fetch('/status', {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',
                    }
                });
                
                if (response.ok) {
                    const data = await response.json();
                    updateLEDDisplay(data.led_state);
                    showMessage(data.message, 'success');
                    updateConnectionStatus(true);
                } else {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
            } catch (error) {
                console.error('Error:', error);
                showMessage('Failed to get status. Check connection.', 'error');
                updateConnectionStatus(false);
            } finally {
                // Restore button
                button.innerHTML = originalText;
                button.disabled = false;
            }
        }
        
        function updateLEDDisplay(isOn) {
            const ledDisplay = document.getElementById('ledDisplay');
            const statusText = document.getElementById('statusText');
            
            if (isOn) {
                ledDisplay.className = 'led-display on';
                ledDisplay.textContent = 'ON';
                statusText.textContent = 'LED is currently ON';
            } else {
                ledDisplay.className = 'led-display off';
                ledDisplay.textContent = 'OFF';
                statusText.textContent = 'LED is currently OFF';
            }
        }
        
        function updateConnectionStatus(connected) {
            const statusElement = document.getElementById('connectionStatus');
            isConnected = connected;
            
            if (connected) {
                statusElement.className = 'connection-status connected';
                statusElement.innerHTML = '🟢 Connected to NodeMCU';
            } else {
                statusElement.className = 'connection-status disconnected';
                statusElement.innerHTML = '🔴 Connection Lost';
            }
        }
        
        function showMessage(text, type) {
            const messageElement = document.getElementById('message');
            messageElement.textContent = text;
            messageElement.className = `message ${type}`;
            messageElement.style.display = 'block';
            
            // Auto-hide message after 3 seconds
            setTimeout(() => {
                messageElement.style.display = 'none';
            }, 3000);
        }
        
        // Auto-refresh status every 10 seconds
        setInterval(() => {
            if (isConnected) {
                checkStatus();
            }
        }, 10000);
    </script>
</body>
</html>
)=====";

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW); // Start with LED OFF
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println();
  Serial.print("Connected! IP address: ");
  Serial.println(WiFi.localIP());
  
  // Define server routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/led/on", HTTP_GET, handleLedOn);
  server.on("/led/off", HTTP_GET, handleLedOff);
  server.on("/status", HTTP_GET, handleStatus);
  
  // Enable CORS for cross-origin requests
  server.enableCORS(true);
  
  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
}

void handleRoot() {
  String s = MAIN_page; // Read HTML contents
  server.send(200, "text/html", s); // Send web page
}

void handleLedOn() {
  digitalWrite(LED_PIN, HIGH);
  ledState = true;
  Serial.println("LED turned ON");
  
  // Send JSON response
  server.sendHeader("Access-Control-Allow-Origin", "*");
  String json = "{\"status\":\"success\",\"led_state\":true,\"message\":\"LED turned ON successfully\"}";
  server.send(200, "application/json", json);
}

void handleLedOff() {
  digitalWrite(LED_PIN, LOW);
  ledState = false;
  Serial.println("LED turned OFF");
  
  // Send JSON response
  server.sendHeader("Access-Control-Allow-Origin", "*");
  String json = "{\"status\":\"success\",\"led_state\":false,\"message\":\"LED turned OFF successfully\"}";
  server.send(200, "application/json", json);
}

void handleStatus() {
  // Return current LED state as JSON
  server.sendHeader("Access-Control-Allow-Origin", "*");
  String json = "{\"status\":\"success\",\"led_state\":" + String(ledState ? "true" : "false") + ",\"message\":\"Current LED status retrieved\"}";
  server.send(200, "application/json", json);
}
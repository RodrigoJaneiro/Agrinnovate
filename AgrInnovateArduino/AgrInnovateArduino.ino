#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <WiFiUdp.h>
#include <NTPClient.h>
#include <TimeLib.h>
#include <Wire.h>
#include <Adafruit_Si7021.h>
#include "esp_sleep.h"

// Define WiFi credentials
#define WIFI_SSID "NOS-8E95"
#define WIFI_PASSWORD "494ZRCKW"

// Define Firebase API Key, Project ID, and user credentials
#define API_KEY "AIzaSyCO4suwcbPgmSYyVmecMgpm9NZUhDV-J9U"
#define FIREBASE_PROJECT_ID "agrinnovate-d31ea"
#define USER_EMAIL "rodrigomtjaneiro@gmail.com"
#define USER_PASSWORD "Rodrigo1234"

// Define Firebase Data object, Firebase authentication, and configuration
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Configurações do NTP para obter a data e hora atuais
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 3600, 60000); // Fuso horário GMT+1

// Sensor and pin definitions
#define si7021Addr 0x40
#define pinoSDA 21
#define pinoSCL 22
#define sensorSoloPin 32
#define LDR_Pin 34
#define LED_PIN 26  // Define o pino do LED

#define uS_TO_S_FACTOR 1000000  // Conversão de segundos para microsegundos
#define TIME_TO_SLEEP  300      // Tempo de sono em segundos (5 minutos)

TwoWire myWire = TwoWire(0);
Adafruit_Si7021 sensor(&myWire);

float temperaturaAr, humidadeAr;
const int AirValue = 3115;
const int WaterValue = 1460;
int intervals = (AirValue - WaterValue) / 3;
int soilMoistureValue = 0;
const int SOLO_HUMIDO_MAX = 2600;
const int LDR_THRESHOLD = 900;

// Declare idStr as a global variable
char idStr[17];
String umidadeSoloStatus;

void setup() {
  // Initialize serial communication for debugging
  Serial.begin(115200);

  // Initialize I2C communication for the sensor
  myWire.begin(pinoSDA, pinoSCL);
  if (!sensor.begin()) {
    Serial.println("Não foi possível encontrar o sensor Si7021. Verifique as conexões!");
    while (1);
  }

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  // Print Firebase client version
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  // Assign the API key
  config.api_key = API_KEY;

  // Assign the user sign-in credentials
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  // Assign the callback function for the long-running token generation task
  config.token_status_callback = tokenStatusCallback;  // see addons/TokenHelper.h

  // Begin Firebase with configuration and authentication
  Firebase.begin(&config, &auth);

  // Reconnect to Wi-Fi if necessary
  Firebase.reconnectWiFi(true);

  // Get the unique ID of the ESP32
  uint64_t chipid = ESP.getEfuseMac();
  sprintf(idStr, "%04X%08X", (uint16_t)(chipid >> 32), (uint32_t)chipid);
  Serial.print("ID único do ESP32: ");
  Serial.println(idStr);

  // Inicializando o NTP para obter a data e hora
  timeClient.begin();
  while (!timeClient.update()) {
    timeClient.forceUpdate();
  }

  // Define the LED pin as output
  pinMode(LED_PIN, OUTPUT);

  // Configurar o tempo de sono profundo
  esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);
}

void loop() {
  // Atualizar sensores e enviar dados para o Firestore
  atualizarSensores();

  // Entrar em modo de sono profundo
  Serial.println("Entrando em modo de sono profundo por 5 minutos...");
  esp_deep_sleep_start();
}

void atualizarSensores() {
  // Read sensor values
  float humidity = sensor.readHumidity();
  float temperature = sensor.readTemperature();
  int soilMoistureValue = analogRead(sensorSoloPin);
  int LDR_Val = analogRead(LDR_Pin);

  temperaturaAr = round(temperature);
  humidadeAr = round(humidity);

  if (soilMoistureValue > WaterValue && soilMoistureValue < (WaterValue + intervals)) {
    umidadeSoloStatus = "Solo Muito húmido";
  } else if (soilMoistureValue > (WaterValue + intervals) && soilMoistureValue < (AirValue - intervals)) {
    umidadeSoloStatus = "Solo Húmido";
  } else if (soilMoistureValue < AirValue && soilMoistureValue > (AirValue - intervals)) {
    umidadeSoloStatus = "Solo Seco";
  }

  // Get the current time
  long epochTime = timeClient.getEpochTime();
  setTime(epochTime); // Ajusta a função time() com o horário atual

  // Format the date and time as a string in "dd-MM-yyyy HH:mm:ss" format
  String formattedDate = String(day()) + "-" + String(month()) + "-" + String(year()) + " " + String(hour()) + ":" + String(minute()) + ":" + String(second());

  // Define the path to the Firestore document with a unique identifier
  String documentPath = "dados/" + String(epochTime); // Use the current timestamp as the document ID

  // Create a FirebaseJson object for storing data
  FirebaseJson content;

  // Set the fields in the FirebaseJson object
  content.set("fields/humidadeAr/integerValue", humidadeAr); // Define o campo 'humidadeAr'
  content.set("fields/humidadeSolo/stringValue", umidadeSoloStatus); // Define o campo 'humidadeSolo'
  content.set("fields/temperatura/integerValue", temperaturaAr); // Define o campo 'temperatura'
  content.set("fields/luminosidade/integerValue", LDR_Val); // Define o campo 'luminosidade'
  content.set("fields/maquina/stringValue", idStr); // Define o campo 'maquina'
  content.set("fields/dataDados/stringValue", formattedDate); // Define o campo 'dataDados' como string

  Serial.print("Update/Add Sensor Data, Serial Number, and Date... ");

  // Use the patchDocument method to update the fields in the Firestore document
  if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw(), "humidadeAr,humidadeSolo,temperatura,luminosidade,maquina,dataDados", "")) {
    Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
  } else {
    Serial.println(fbdo.errorReason());
  }

  // Controle do LED com base na temperatura
  if (temperaturaAr < 15 || temperaturaAr > 20 || soilMoistureValue > SOLO_HUMIDO_MAX) {
    digitalWrite(LED_PIN, HIGH);  // Acende o LED
  } else {
    digitalWrite(LED_PIN, LOW);   // Apaga o LED
  }
}

#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <WiFiUdp.h>
#include <NTPClient.h>
#include <TimeLib.h>
#include <Wire.h>

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
#define WIND_SPD_PIN 35
#define RAIN_PIN     25
#define WIND_DIR_PIN 14

volatile unsigned long timeSinceLastTick = 0;
bool hasTicked = false;
volatile unsigned long lastTick = 0;

#define S_IN_DAY   86400
#define S_IN_HR     3600
#define NO_RAIN_SAMPLES 2000
volatile long rainTickList[NO_RAIN_SAMPLES];
volatile int rainTickIndex = 0;
volatile int rainTicks = 0;
int rainLastDay = 0;
int rainLastHour = 0;
long secsClock = 0;

String windDir = "";
float windSpeed = 0.0;

const char* idStr = "7157EB2DE6B4";

#define uS_TO_S_FACTOR 1000000
#define TIME_TO_SLEEP 300

void setup() {
  Serial.begin(115200);
  delay(10);

  pinMode(WIND_SPD_PIN, INPUT);
  attachInterrupt(digitalPinToInterrupt(WIND_SPD_PIN), windTick, RISING);

  pinMode(RAIN_PIN, INPUT);
  attachInterrupt(digitalPinToInterrupt(RAIN_PIN), rainTick, RISING);
  
  for (int i = 0; i < NO_RAIN_SAMPLES; i++) rainTickList[i] = 0;

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");

  // Initialize Firebase
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.token_status_callback = tokenStatusCallback;  // see addons/TokenHelper.h
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Inicializando o NTP para obter a data e hora
  timeClient.begin();
  while (!timeClient.update()) {
    timeClient.forceUpdate();
  }

  esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);
}

void loop() {
  delay(1);

  static unsigned long outLoopTimer = 0;
  static unsigned long clockTimer = 0;
  static unsigned long tempMSClock = 0;

  tempMSClock += millis() - clockTimer;
  clockTimer = millis();
  while (tempMSClock >= 1000) {
    secsClock++;
    tempMSClock -= 1000;
  }

  if (millis() - outLoopTimer >= 2000) {
    outLoopTimer = millis();

    Serial.print("\nTimestamp: ");
    Serial.println(secsClock);

    if (!hasTicked) {
      windSpeed = 0;
    } else {
      if (timeSinceLastTick != 0) {
        windSpeed = 1000.0 / timeSinceLastTick;
        hasTicked = false;
      }
    }
    Serial.print("Windspeed: ");
    Serial.print(windSpeed * 2.4);
    Serial.println(" km/h");

    Serial.print("Wind dir: ");
    windDirCalc(analogRead(WIND_DIR_PIN));
    Serial.print("  ");
    Serial.println(windDir);

    Serial.print("Rainfall to date: ");
    Serial.println(float(rainTicks) * 0.2794, 3);

    // Send data to Firestore
    enviarDadosFirestore(round(windSpeed * 2.4), round(rainTicks * 0.2794), windDir);

    Serial.println("sono profundo");
    esp_deep_sleep_start();
  }
}

void windTick(void) {
  timeSinceLastTick = millis() - lastTick;
  lastTick = millis();
  hasTicked = true;
}

void rainTick(void) {
  rainTickList[rainTickIndex++] = secsClock;
  if (rainTickIndex == NO_RAIN_SAMPLES) rainTickIndex = 0;
  rainTicks++;
}

void windDirCalc(int vin) {
  if (vin < 150) windDir = "202.5";
  else if (vin < 300) windDir = "180";
  else if (vin < 400) windDir = "247.5";
  else if (vin < 600) windDir = "225";
  else if (vin < 900) windDir = "292.5";
  else if (vin < 1100) windDir = "270";
  else if (vin < 1500) windDir = "112.5";
  else if (vin < 1700) windDir = "135";
  else if (vin < 2250) windDir = "337.5";
  else if (vin < 2350) windDir = "315";
  else if (vin < 2700) windDir = "67.5";
  else if (vin < 3000) windDir = "90";
  else if (vin < 3200) windDir = "22.5";
  else if (vin < 3400) windDir = "45";
  else if (vin < 4000) windDir = "0";
  else windDir = "0";
}

void enviarDadosFirestore(int windSpeed, int rainfall, String windDir) {
  // Get the current time
  long epochTime = timeClient.getEpochTime();
  setTime(epochTime); // Ajusta a função time() com o horário atual

  // Format the date and time as a string in "dd-MM-yyyy HH:mm:ss" format
  String formattedDate = String(day()) + "-" + String(month()) + "-" + String(year()) + " " + String(hour()) + ":" + String(minute()) + ":" + String(second());

  // Define the path to the Firestore document with a unique identifier
  String documentPath = "dadosEstacao/" + String(epochTime); // Use the current timestamp as the document ID

  // Create a FirebaseJson object for storing data
  FirebaseJson content;

  // Set the fields in the FirebaseJson object
  content.set("fields/velocidadeVento/integerValue", windSpeed); // Define o campo 'velocidadeVento'
  content.set("fields/direcaoVento/stringValue", windDir); // Define o campo 'direcaoVento'
  content.set("fields/intensidadeChuva/integerValue", rainfall); // Define o campo 'intensidadeChuva'
  content.set("fields/maquina/stringValue", idStr); // Define o campo 'maquina'
  content.set("fields/dataDados/stringValue", formattedDate); // Define o campo 'dataDados' como string

  Serial.print("Update/Add Sensor Data, Serial Number, and Date... ");

  // Use the patchDocument method to update the fields in the Firestore document
  if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw(), "velocidadeVento,direcaoVento,intensidadeChuva,maquina,dataDados", "")) {
    Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
  } else {
    Serial.println(fbdo.errorReason());
  }
}
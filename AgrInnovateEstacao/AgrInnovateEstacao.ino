#include "soc/timer_group_struct.h"
#include "soc/timer_group_reg.h"
#include <SPI.h>
#include <WiFi.h>
#include <FirebaseESP32.h>

#define FIREBASE_HOST "https://teste1-90680-default-rtdb.europe-west1.firebasedatabase.app/"
#define FIREBASE_AUTH "AIzaSyCL-pSVAdf1s7n1zsfuU6LeS3Jx2qFMQxY"

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

FirebaseData firebaseData;
hw_timer_t *timer = NULL;

void IRAM_ATTR resetModule() {
  ets_printf("(watchdog) reiniciar\n");
  ESP.restart();
}

void setup() {
  Serial.begin(115200);
  delay(10);

  timer = timerBegin(0, 80, true);
  timerAttachInterrupt(timer, &resetModule, true);
  timerAlarmWrite(timer, 60000000, true);
  timerAlarmEnable(timer);

  pinMode(WIND_SPD_PIN, INPUT);
  attachInterrupt(digitalPinToInterrupt(WIND_SPD_PIN), windTick, RISING);

  pinMode(RAIN_PIN, INPUT);
  attachInterrupt(digitalPinToInterrupt(RAIN_PIN), rainTick, RISING);
  
  for (int i = 0; i < NO_RAIN_SAMPLES; i++) rainTickList[i] = 0;

  // Connect to WiFi
  WiFi.begin("NOS-8E95", "494ZRCKW");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");

  // Initialize Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
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

    // Send data to Firebase
    Firebase.setFloat(firebaseData, "Weather/WindSpeed", windSpeed * 2.4);
    Firebase.setString(firebaseData, "Weather/WindDirection", windDir);
    Firebase.setFloat(firebaseData, "Weather/Rainfall", rainTicks * 0.2794);

    delay(10000);
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

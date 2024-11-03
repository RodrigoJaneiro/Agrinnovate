#include "soc/timer_group_struct.h"
#include "soc/timer_group_reg.h"
#include <SPI.h>
#include <RH_RF95.h>
#include <RHReliableDatagram.h>
#include "Adafruit_Si7021.h"
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <WiFiUdp.h>
#include <NTPClient.h>
#include <TimeLib.h>

#define TINY_GSM_MODEM_SIM7000

// Set serial for debug console (to the Serial Monitor, default speed 115200)
#define SerialMon Serial

// Your WiFi connection credentials, if applicable
const char wifiSSID[] = "YourSSID";
const char wifiPass[] = "YourWiFiPass";

//Hardware pin definitions
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#define WIND_SPD_PIN 35
#define RAIN_PIN     25
#define WIND_DIR_PIN 14
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// Variables and constants used in calculating the windspeed.
volatile unsigned long timeSinceLastTick = 0;
bool hasTicked = false;
volatile unsigned long lastTick = 0;

// Variables and constants used in tracking rainfall
#define S_IN_DAY   86400
#define S_IN_HR     3600
#define NO_RAIN_SAMPLES 2000
volatile long rainTickList[NO_RAIN_SAMPLES];
volatile int rainTickIndex = 0;
volatile int rainTicks = 0;
int rainLastDay = 0;
int rainLastHour = 0;
int rainLastHourStart = 0;
int rainLastDayStart = 0;
long secsClock = 0;

String windDir = "";
float windSpeed = 0.0;
int weatherCount = 0;

int id = 0;
int i_mqtt = 0;
unsigned long lastDataAttempt = 3600000;
unsigned long lastReceiveAttempt = 10000;
unsigned long lastAttemptAttempt = 500;
unsigned long lastReconnectAttempt = 0;
unsigned long lastResendAttempt = 0;
unsigned long lastResetAttempt = 0;
unsigned long lastAttempt = 0;
unsigned long lastAttempt_espera = 0;
unsigned long lastAttemptResend = 0;
unsigned long lastPingAttempt = 0;
unsigned long lastWeatherAttempt = 0;
bool switchLed = true;

bool tokenConfirmed = false;

String fila_de_espera = "";
String fila_de_espera_mqtt = "";
int retry = 0;
String data_broker = "";

uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];

hw_timer_t *timer = NULL; //faz o controle do temporizador (interrupção por tempo)

//função que o temporizador irá chamar, para reiniciar o ESP32
void IRAM_ATTR resetModule() {
  Serial.println("(watchdog) reiniciar\n"); //imprime no log
  ESP.restart(); //reinicia o chip
}

void setup() {
  // Set console baud rate
  SerialMon.begin(115200);
  delay(10);

  timer = timerBegin(0, 80, true); //timerID 0, div 80
  //timer, callback, interrupção de borda
  timerAttachInterrupt(timer, &resetModule);
  //timer, tempo (us), repetição
  timerAlarmWrite(timer, 60000000, true);
  timerAlarmEnable(timer); //habilita a interrupção

  // !!!!!!!!!!!
  // Set your reset, enable, power pins here
  // !!!!!!!!!!!

  SerialMon.println("Wait...");

 
  // Wind speed sensor setup. The windspeed is calculated according to the number
  //  of ticks per second. Timestamps are captured in the interrupt, and then converted
  //  into mph. 
  pinMode(WIND_SPD_PIN, INPUT);     // Wind speed sensor
  attachInterrupt(digitalPinToInterrupt(WIND_SPD_PIN), windTick, RISING);

  // Rain sesnor setup. Rainfall is tracked by ticks per second, and timestamps of
  //  ticks are tracked so rainfall can be "aged" (i.e., rain per hour, per day, etc)
  pinMode(RAIN_PIN, INPUT);     // Rain sensor
  attachInterrupt(digitalPinToInterrupt(RAIN_PIN), rainTick, RISING);
  // Zero out the timestamp array.
  for (int i = 0; i < NO_RAIN_SAMPLES; i++) rainTickList[i] = 0;
}

void loop() {
  delay(1);

  static unsigned long outLoopTimer = 0;
  static unsigned long wundergroundUpdateTimer = 0;
  static unsigned long clockTimer = 0;
  static unsigned long tempMSClock = 0;

  // Create a seconds clock based on the millis() count. We use this
  //  to track rainfall by the second. We've done this because the millis()
  //  count overflows eventually, in a way that makes tracking time stamps
  //  very difficult.
  tempMSClock += millis() - clockTimer;
  clockTimer = millis();
  while (tempMSClock >= 1000) {
    secsClock++;
    tempMSClock -= 1000;
  }

  // This is a once-per-second timer that calculates and prints off various
  //  values from the sensors attached to the system.
  if (millis() - outLoopTimer >= 2000){
    outLoopTimer = millis();

    SerialMon.print("\nTimestamp: ");
    SerialMon.println(secsClock);

    // Windspeed calculation, in mph. timeSinceLastTick gets updated by an
    //  interrupt when ticks come in from the wind speed sensor.
    if (!hasTicked){
      windSpeed = 0;
    } else {
      if (timeSinceLastTick != 0){
        windSpeed = 1000.0/timeSinceLastTick;
        hasTicked = false;
      }
    }
    SerialMon.print("Windspeed: ");
    SerialMon.print(windSpeed*2.4);
    SerialMon.println(" km/h");

    // Calculate the wind direction and display it as a string.
    SerialMon.print("Wind dir: ");
    windDirCalc(analogRead(WIND_DIR_PIN));
    SerialMon.print("  ");
    SerialMon.println(windDir);

    // Calculate and display rainfall totals.
    SerialMon.print("Rainfall last hour: ");
    SerialMon.println(float(rainLastHour)*0.2794, 3);
    SerialMon.print("Rainfall last day: ");
    SerialMon.println(float(rainLastDay)*0.2794, 3);
    SerialMon.print("Rainfall to date: ");
    SerialMon.println(float(rainTicks)*0.2794, 3);
  
    // Calculate the amount of rain in the last day and hour.
    rainLastHour = 0;
    rainLastDay = 0;
    // If there are any captured rain sensor ticks...
    if (rainTicks > 0){
      // Start at the end of the list. rainTickIndex will always be one greater
      //  than the number of captured samples.
      int i = rainTickIndex-1;

      // Iterate over the list and count up the number of samples that have been
      //  captured with time stamps in the last hour.
      while ((rainTickList[i] >= secsClock - S_IN_HR) && rainTickList[i] != 0){
        i--;
        if (i < 0) i = NO_RAIN_SAMPLES-1;
        rainLastHour++;
      }

      // Repeat the process, this time over days.
      i = rainTickIndex-1;
      while ((rainTickList[i] >= secsClock - S_IN_DAY) && rainTickList[i] != 0){
        i--;
        if (i < 0) i = NO_RAIN_SAMPLES-1;
        rainLastDay++;
      }
      rainLastDayStart = i;
    }
  }

  
}

String getValue(String data, char separator, int index) {
  int found = 0;
  int strIndex[] = { 0, -1 };
  int maxIndex = data.length() - 1;

  for (int i = 0; i <= maxIndex && found <= index; i++) {
    if (data.charAt(i) == separator || i == maxIndex) {
      found++;
      strIndex[0] = strIndex[1] + 1;
      strIndex[1] = (i == maxIndex) ? i + 1 : i;
    }
  }
  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}


// Keep track of when the last tick came in on the wind sensor.
void windTick(void){
  timeSinceLastTick = millis() - lastTick;
  lastTick = millis();
  hasTicked = true;
}

// Capture timestamp of when the rain sensor got tripped.
void rainTick(void){
  rainTickList[rainTickIndex++] = secsClock;
  if (rainTickIndex == NO_RAIN_SAMPLES) rainTickIndex = 0;
  rainTicks++;
}

// For the purposes of this calculation, 0deg is when the wind vane
//  is pointed at the anemometer. The angle increases in a clockwise
//  manner from there.
void windDirCalc(int vin){
  if      (vin < 150) windDir="202.5";
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

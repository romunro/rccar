#include <SoftwareSerial.h>
#include "easytlv.c"

SoftwareSerial Bluetooth(8,7); // RX | TX

int speakerOut = 9;
int drivepin1 = 4;
int drivepin2 = 5;
int drivePWR  = 11;

int steerpin1 = 2;
int steerpin2 = 3;
int steerPWR  = 10; 
const long minCommandInterval = 3000;

void setup() {
  Serial.begin(9600);
  Bluetooth.begin(19200);//9600 if Baud rate has gone to default again.
  pinMode(4, OUTPUT);
  digitalWrite(4, HIGH);

  pinMode(drivePWR, OUTPUT);
  pinMode(steerPWR, OUTPUT);
  
  pinMode(drivepin1, OUTPUT);
  pinMode(drivepin2, OUTPUT);
  pinMode(steerpin1, OUTPUT);
  pinMode(steerpin2, OUTPUT);

  BLESetup();
  
  Serial.println("ready");
}

///BLE utility functions
void BLESetup() {
  delay(300);
  ATCommand("AT");
  ATCommand("AT+RFPM=4");
  ATCommand("AT+UART=19200");//230400
  ATCommand("AT+NAME=RemoteCar");
  Serial.println("BLE setup");
}
unsigned long lastCommandMillis = 0;

void loop()  {
  if (lastCommandMillis != 0 && millis() - lastCommandMillis >= minCommandInterval) {
    //Serial.println("Haven't received anything for too long");
    //onNeutral();
    lastCommandMillis = 0;
  }
  recvBLE();
  sendIt();
}

uint32_t power = 0;
uint32_t steer = 0;

void sendIt() {
  if(power == 0 && steer == 0){
    onNeutral();
    return;
  }
  
  if(power >= 255){
    onForward(power - 255);
  }else{
    onBackwards(map(power, 0, 255, 255, 0));
  }
    
  if(steer >= 255){
    onLeft(steer - 255);
  }else{
    onRight(map(steer, 0, 255, 255, 0));
  }
}
  
void onForward(uint32_t power) {
  analogWrite(drivePWR, power);
  digitalWrite(drivepin1, HIGH);
  digitalWrite(drivepin2, LOW);
//  Serial.print("Forward: ");
//  Serial.println(power);
}

void onBackwards(uint32_t power) {
  analogWrite(drivePWR, power);
  digitalWrite(drivepin1, LOW);
  digitalWrite(drivepin2, HIGH);
  //Serial.print("Backward: ");
  //Serial.println(power);
}

void onLeft(uint32_t power) {
  analogWrite(steerPWR, power);
  digitalWrite(steerpin1, HIGH);
  digitalWrite(steerpin2, LOW);
//  Serial.print("Left: ");
//  Serial.println(power);
}

void onRight(uint32_t power) {
  analogWrite(steerPWR, power);
  digitalWrite(steerpin1, LOW);
  digitalWrite(steerpin2, HIGH);
//  Serial.print("Right: ");
//  Serial.println(power);
}

void onNeutral() {
  power = 0;
  steer = 0;
  analogWrite(steerPWR, 0);
  analogWrite(drivePWR, 0);
  digitalWrite(steerpin1, LOW);
  digitalWrite(steerpin2, LOW);
  digitalWrite(drivepin1, LOW); 
  digitalWrite(drivepin2, LOW);
  //Serial.println("Neutral");
} 


char c=' ';
char buffer[100];
int bufferIndex = 0;

void recvBLE()  {
  if(!Bluetooth.available()) {
    return;
  }
  c = Bluetooth.read();
  lastCommandMillis = millis();
  
  if(c == '\n') {
    recvData();
    bufferIndex = 0;
    return;
  }
  buffer[bufferIndex] = c;
  bufferIndex++;
}

void recvData() {
  ETLVToken t[2];
  int nTok = sizeof(t)/sizeof(t[0]);
  int err = etlv_parse(t, &nTok, buffer, bufferIndex+1);
  if(err != -125) {//-125 means success
    //Serial.print("Received bad packet");
    return;
  }
  
  // Cast the numbers to uint32_t's and correct endianness
  int32_t newSteer = *(int32_t *)t[0].val;
  int32_t newPower = *(int32_t *)t[1].val;
  
  if(newPower > 510) {
    //Serial.println("too high: ");
    return;
  }
  
  if(newSteer > 510) {
    //Serial.println("too high: ");
    return;
  }

  steer = newSteer;
  power = newPower;

//  Serial.print("power: ");
//  Serial.println(power);
//  Serial.print("steer: ");
//  Serial.println(steer);
}

void ATCommand(const char* command) {
  Bluetooth.print(command);
  delay(100);
}

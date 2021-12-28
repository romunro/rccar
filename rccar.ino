#include <SoftwareSerial.h>
SoftwareSerial Bluetooth(2,3); // RX | TX

int speakerOut = 5;

char c=' ';
void setup() {
  Serial.begin(9600);
  Serial.println("ready");
  Bluetooth.begin(9600);
  pinMode(4, OUTPUT);
  digitalWrite(4, HIGH);

  Bluetooth.println("AT");

  tone(speakerOut, 400, 500);
}

void loop() 
{
  
  if(Bluetooth.available())
  {
    c=Bluetooth.read();
    Serial.write(c);
  }
  if(Serial.available())
  {
    c=Serial.read();
    Bluetooth.write(c);
    Serial.print(c);
  }
}

////  Basic serial communication sketch using AltSoftSerial (ASS).
////  Uses hardware serial to talk to the host computer and ASS for communication with the Bluetooth module
////
////  When a command is entered in the serial monitor on the computer
////  the Arduino will relay it to the Bluetooth module and display the result in the serial monitor.
////
////  Pins
////  BT VCC to Arduino 5V out.
////  BT GND to GND
////  Arduino D8 ASS RX - BT TX no need voltage divider
////  Arduino D9 ASS TX - BT TX through a voltage divider
////
//int motor1pin1 = 2;
//int motor1pin2 = 3;
//int ENA_pin = 9;
//int motor2pin1 = 4;
//int motor2pin2 = 5;
//
//int speakerOut = 5;
////#include <AltSoftSerial.h>
////AltSoftSerial BTSerial;
//
//#include <SoftwareSerial.h>
//SoftwareSerial BTSerial = SoftwareSerial(10, 11); // RX | TX
//
//char c = ' ';
//boolean NL = true;
//
//void setup()
//{
//  Serial.begin(9600);
//  Serial.print("Sketch:   ");   Serial.println(__FILE__);
//  Serial.print("Uploaded: ");   Serial.println(__DATE__);
//  Serial.println(" ");
//
//  pinMode(3, OUTPUT);
//  digitalWrite(3, HIGH);
//  
//  BTSerial.begin(9600);
//  Serial.println("BTserial started at 9600");
//  
//
//
//  sendATcommand("AT" , 2000);
//  sendATcommand("AT+ECHARGE=1" , 2000);
//  sendATcommand("AT+CGPSPWR=1" , 2000);
//
//  // If using an HC-05 in AT command mode the baud rate is likely to be 38400
//  // Comment out the above 2 lines and uncomment the following 2 lines.
//  // BTSerial.begin(38400);
//  // Serial.println("BTserial started at 38400");
//  tone(speakerOut,200,500);
//  Serial.println("");
//
//  //motor driver setup
//  pinMode(motor1pin1, OUTPUT);
//  pinMode(motor1pin2, OUTPUT);
//  pinMode(ENA_pin, OUTPUT);
//  pinMode(motor2pin1, OUTPUT);
//  pinMode(motor2pin2, OUTPUT);
//}
//
//void loop() {
//
//  // Read from the Bluetooth module and send to the Arduino Serial Monitor
//  if (BTSerial.available()) {
//    
//    c = BTSerial.read();
//    Serial.print("<");
//    Serial.println(c);
//    
//    if (c > 5) {
//      tone(speakerOut, 400, 500);
//      analogWrite(ENA_pin, 255);
//      digitalWrite(motor1pin1, HIGH); //forward
//      digitalWrite(motor1pin2, LOW);
//      delay(3000);
//      analogWrite(ENA_pin, 0);
//    }
//  }
//
//
//  // Read from the Serial Monitor and send to the Bluetooth module
//  if (Serial.available()) {
//    c = Serial.read();
//    BTSerial.write(c);
//
//    // Echo the user input to the main window. The ">" character indicates the user entered text.
//    if (NL) {
//      Serial.print(">");
//      NL = false;
//    }
//    Serial.write(c);
//    if (c == 10) {
//      NL = true;
//    }
//  }
//
//}
//
//
//
//String sendATcommand(const char *toSend, unsigned long milliseconds) {
//  String result;
//  Serial.print("Sending: ");
//  Serial.println(toSend);
//  BTSerial.println(toSend);
//  unsigned long startTime = millis();
//  Serial.print("Received: ");
//  while (millis() - startTime < milliseconds) {
//    if (BTSerial.available()) {
//      char c = BTSerial.read();
//      Serial.write(c);
//      result += c;  // append to the result string
//    }
//  }
//Serial.println();  // new line after timeout.
//return result;
//}

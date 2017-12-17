#include <SoftwareSerial.h>
#include <Servo.h>

SoftwareSerial BTSerial(2, 3); // 
Servo myservo;
const int ledCount = 10; // LED 바그래프에 내장된 LED 갯수를 선언합니다.

int ledPins[] = { 
  2, 3, 4, 5, 6, 7, 8, 9, 10, 11 };   
 // LED 바그래프의 각각의 LED와 연결된 핀번호를 배열로 선언합니다.
int pos = 0; 

void setup() {
  myservo.attach(9);
 
  BTSerial.begin(9600);
  Serial.begin(9600);
}

void loop() {  
  if(BTSerial.available()){  // 블루투스 통신이 가능하면
    byte data = BTSerial.read();
    Serial.println(data);

    
    // 블루투스에서 값을 받아옵니다.
    myservo.write(data);              // tell servo to go to position in variable 'pos'
    delay(15); 
  }
}

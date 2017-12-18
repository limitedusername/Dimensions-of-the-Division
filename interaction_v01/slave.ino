#include <Wire.h>

#include <Servo.h>

// 자신의 슬레이브 주소를 설정해 줍니다.(슬레이브 주소에 맞게 수정해야 합니다.)
#define SLAVE 5
Servo myservo[2] = {}; // 서보와 연결된 핀번호를 배열로 선언 
int pos = 0;   
// 카운터
byte count = 0; 
char temp;

void setup() {
  // Wire 라이브러리 초기화
  // 슬레이브로 참여하기 위해서는 주소를 지정해야 한다.
  Wire.begin(SLAVE);
  Wire.onReceive(receiveFromMaster);
  // 마스터의 데이터 전송 요구가 있을 때 처리할 함수 등록
  Wire.onRequest(sendToMaster);
  pinMode(13, OUTPUT);
  Serial.begin(9600);
  myservo[0].attach(9);
  myservo[1].attach(11);
}

void loop () { 
  // 요청이 들어오면 13번 LED를 0.5초간 켜줍니다.
  if (temp == 'o') { 
    play();
    circle();
  } else if (temp == 'e') { // e를 받으면 전 모터 일정 각도에서 멈춤
    motorStop();
  }

  delay(100);
}

void receiveFromMaster(int bytes) {
  char ch[2];
  for (int i = 0 ; i < bytes ; i++) {
    // 수신 버퍼 읽기
    ch[i] = Wire.read(); 
  }
  temp = ch[0];
}

void circle() {
  for (pos = 0; pos <= 360; pos += 1) { // goes from 0 degrees to 360 degrees
    // in steps of 1 degree
    for(int i = 0; i <= 1; i += 1) {
      myservo[i].write(pos);           // tell servo to go to position in variable 'pos'
      delay(15);                       // waits 15ms for the servo to reach the position
    }
  }
  for (pos = 360; pos >= 0; pos -= 1) { // goes from 360 degrees to 0 degrees
    for(int i = 0; i <= 1; i += 1) {
      myservo[i].write(pos);           // tell servo to go to position in variable 'pos'
      delay(15);                       // waits 15ms for the servo to reach the position
    }
  }
}

void motorStop() {
  for(int i = 0; i <= 1; i += 1) {
    myservo[i].write(180);           // tell servo to go to position 180 degrees
    delay(15);                       // waits 15ms for the servo to reach the position
  }
}

void play() { 
  digitalWrite(13, HIGH);
  delay(500);
  digitalWrite(13, LOW);
  temp = 0;
}

void sendToMaster() {
  // 자신의 슬레이브 주소를 담은 메세지를 마스터에게 보냅니다. 슬레이브 주소에 맞게 수정해야 합니다.
  Wire.write("5 Arduino ");
}

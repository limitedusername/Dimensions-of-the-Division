

/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */
 
import processing.serial.*;
import java.awt.*;
import java.awt.event.KeyEvent;
import SimpleOpenNI.*;

Serial myPort;
PVector tempPos = new PVector();

SimpleOpenNI  context;
color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};
PVector com = new PVector();   
PVector com2d = new PVector();     

void setup()
{
  println(Serial.list());

  //String portName = Serial.list()[3];
  //myPort = new Serial(this, portName, 9600);

  size(640, 480);

  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  background(200, 0, 0);

  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();
}

void draw()
{
  // 카메라를 띄웁니다.
  context.update();

  image(context.userImage(), 0, 0);

  // 사람이 인식이 되면 목록에 추가합니다..
  int[] userList = context.getUsers();

  // 인식된 사람 수만큼 스켈레톤을 그려줍니다. 
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);      
    }      

    if (context.getCoM(userList[i], com))
    {
      context.convertRealWorldToProjective(com, com2d);
      stroke(100, 255, 0);
      strokeWeight(2);
      beginShape(LINES);
      vertex(com2d.x, com2d.y - 5);
      vertex(com2d.x, com2d.y + 5);

      vertex(com2d.x - 5, com2d.y);
      vertex(com2d.x + 5, com2d.y);
      endShape();

      fill(0, 255, 100);
      text(Integer.toString(userList[i]), com2d.x, com2d.y);
    }
  }
}

// 스켈레톤을 그리는 함수(인식된 사람마다 각각 스켈레톤을 그립니다.)
void drawSkeleton(int userId)
{
  try {
    // PVector를 선언해서 오른손의 관절을 저장해 둡니다.
   PVector jointRight = new PVector();
   context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, jointRight);
    
  // PVector에 관절을 넣으면 해당 관절의 x, y, z값을 받아 올수 있습니다.
  // y값(높이)를 이용해 오른손의 높이를 측정하여 일정이상 높이위로 올렸을 경우
  // x값(좌우)를 받아 바그래프의 LED 수의 맞게(10개) 값을 재분배 하여 블루투스를 통해 아두이노로 전송합니다.
  // PVector의 좌표 값들은 float값이므로 값 재분배를 한뒤 INT값으로 바꿔 줍니다.
  if(jointRight.y > 100){
    float temp = map(jointRight.x, -400, 400, 0, 10); // PVector의 X값 재분배
    int imp = (int)temp; // INT로 변환
    println(imp);
    myPort.write(imp); // 블루투스를 통해 아두이노로 전송
  }
 
  }
  catch(Exception e) {
  }

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  // 프로세싱을 실행 시킨 화면에 각 관절을 그려줍니다.
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
// 인식된 사람의 userno을 지정한 후 스켈레톤을 그려줍니다.
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
// 인식된 사람이 화면에서 벗어 낫을 경우
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  

// 출처 : OpenNI 예제소스 User를 이용하여 KocoaFab에서 필요에 맞게 수정했습니다.


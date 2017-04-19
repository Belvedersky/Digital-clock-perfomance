#include <CapacitiveSensor.h>
#include <Boards.h>
#include <Firmata.h>

CapacitiveSensor touch1 = CapacitiveSensor(12,3);
CapacitiveSensor touch2 = CapacitiveSensor(12,5);
CapacitiveSensor touch3 = CapacitiveSensor(12,6);
CapacitiveSensor touch4 = CapacitiveSensor(12,8);
CapacitiveSensor touch5 = CapacitiveSensor(12,9);
CapacitiveSensor touch6 = CapacitiveSensor(12,10);

void setup(){
touch1.set_CS_AutocaL_Millis(0xFFFFFFFF);
Firmata.begin(57600);
}

void loop(){
long apple1 = touch1.capacitiveSensor(30);
long apple2 = touch2.capacitiveSensor(30);
long apple3 = touch3.capacitiveSensor(30);
long apple4 = touch4.capacitiveSensor(30);
long apple5 = touch5.capacitiveSensor(30);
long orange = touch6.capacitiveSensor(30);

Firmata.sendAnalog(4,apple1);
Firmata.sendAnalog(5,apple2);
Firmata.sendAnalog(6,apple3);
Firmata.sendAnalog(7,apple4);
Firmata.sendAnalog(8,apple5);
Firmata.sendAnalog(9,orange);
delay(150);
}

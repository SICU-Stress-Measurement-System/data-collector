// Read and print data points until 1000 data points are reached.

long cap = 100000;
long num = 0;
long startTime;
boolean reported = false;

void setup() {
  Serial.begin(115200);
  startTime = millis();
}

void loop() {
  int value = analogRead(A0);
  num++;
  
  if (num <= cap) {
    Serial.println(value);
  } //else if (!reported) {
    //report();
  }
//}

//void report() {
  //long endTime = millis();
  //long duration = endTime - startTime;
 // float sec = duration / 1000.0;

 // Serial.print("Finsihed in ");
 // Serial.print(sec);
 // Serial.println(" seconds.");
  
 // reported = true;
//}


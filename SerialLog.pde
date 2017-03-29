import processing.serial.*;

Serial serial;
PrintWriter out;

void setup() {
  serial = new Serial(this, "COM3", 115200);
  out = createWriter("data.txt");
}

void draw() {
  if (serial.available() > 0) {
    int data = serial.read();
    out.println(data);
  }
}

void keyPressed() {
  out.flush();
  out.close();
  exit();
}
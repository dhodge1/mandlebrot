import java.util.Date;

// Controls location of zoom
float xmin = -3;
float ymin = -1.25;
 // Controls zoom level
float w = 4;
float h = 2.5;
int windowWidth = 1200;
int windowHeight = 800;
float xmax = xmin + w;
float ymax = ymin + h;
float infinityBoundary = 8.0;
int maxIterations = 200;
float zoomFactor = 2.0;
int colorOffset = 0;
float redOffset = 25.5;
float greenOffset = -25.5;
float blueOffset = 0;
color cycleColor = color(redOffset, greenOffset, blueOffset);
int magnificationLevel = 1;

void setup() {
  size(windowWidth, windowHeight);
  background(255);
  
  loadPixels();
  mandelbrot();
}
  
void mandelbrot() {
 //colorMode(HSB, 1.0);
  
  xmax = xmin + w;
  ymax = ymin + h; 
  
 // Calculate amount we increment x,y for each pixel
  float dx = (xmax - xmin) / (width);
  float dy = (ymax - ymin) / (height);
  
 // Start y
  float y = ymin;
  for (int j = 0; j < height; j++) {
 // Start x
    float x = xmin;
      for (int i = 0; i < width; i++) {
  
 // Now we test, as we iterate z = z^2 + c does z tend towards infinity?
 // c = x + yi
        float a = x;
        float b = y;
        int n;
          for (n = 0; n < maxIterations; n++) {
            float aa = a * a;
            float bb = b * b;
            b = (2.0 * a * b) + y;
            a = aa - bb + x;
 // See if the point has moved past infinity
            if (aa + bb > infinityBoundary) {
              break; 
            }
          }
 // Color the pixel based on how long it took to go to infinity
 // (or whether it stayed inside the set the whole time).
          rainbow(i, j, n);
 //rgbColors(i, j, x, y, a, b, n); // use in HSB Mode
 //colorPixel(i, j, n);
          x += dx;
      }
      y += dy;
  }
  updatePixels();
}

void rgbColors(int i, int j, float startX, float startY, float endX, float endY, int n) {
  float angle = PVector.angleBetween(new PVector(startX, startY), new PVector(endX, endY)) / 2;
 //float distance = PVector.distanceBetween(new PVector(startX, startY), new PVector(endX, endY)) / 2;
  float degrees = degrees(angle) / 90.0 % 1.0;
  pixels[i+j*width] = color(degrees % 1.0, n/100.0 % 1.0, angle % 1.0);
}

void rainbow(int i, int j, int n) {
  int scalesDelta = 30;
  int pctColor;
  int red = 0, green = 0, blue = 0;
  if (n <= 10) {
    pctColor = (int)(n / 20.0 * 255);
    red = 255 - pctColor;
    green = 255;
    blue = 0; red = 0; green = 0;
  }
  else if (n <= 20) {
    pctColor = (int)((n - 10) / 10.0 * 255);
    red = 255; red = 255 - pctColor;
    green = pctColor; green = 0;
    blue = 0;
  }
  else if (n <= 30) {
    pctColor = (int)(((n - 20) / 10.0 * 255));
   if (pctColor > 255) pctColor = 255;
    red = 0;
    green = 255 - pctColor;
    blue = pctColor;
    red = pctColor; green = 0; blue = 0;
   }
   else {
    pctColor = (int)((n - 30) * 2);
    if (pctColor > 255)
    pctColor = 255;
    red = 0;
    green = pctColor;
    blue = 255;
    red = green = blue = pctColor;
  }
  if (n == maxIterations) {
    red = green = blue = 0;
  }
  pixels[i+j*width] = color(red, green, blue);
}

void colorPixel(int i, int j, int n) {
 // We color each pixel based on how long it takes to get to infinity
 // If we never got there, let's pick the color black
 if (n == maxIterations) {
  pixels[i+j*width] = color(0);
 }
 else {
   n = n * 16 % 255;
   int red = 0, blue = 0, green = 0;
   if (n > 140) {
   red = n;
   green = n / 2;
   blue = n / 4;
 }
 else if (n > 80) {
   blue = n;
   red = n / 2;
   green = n / 4;
 }
 else if (n > 40) {
   red = n / 2;
   green = n / 2;
   blue = n / 4;
 }
 else {
   green = n;
   blue = n / 2;
   red = n / 4;
 }
 pixels[i+j*width] = color(red, green, blue);
 }
}

void draw() {
 if (mousePressed && mouseButton == LEFT) {
   // Position clicked spot at center of new drawing
   xmin = xmin + (mouseX / (float)windowWidth * w) - (w / 2);
   ymin = ymin + (mouseY / (float)windowHeight * h) - (h / 2);
   // Zoom in
   w /= zoomFactor;
   h /= zoomFactor;
   xmin = xmin + w / zoomFactor;
   ymin = ymin + h / zoomFactor;
   magnificationLevel++;
   mandelbrot();
 }
 if (mousePressed && mouseButton == RIGHT) {
   // Position clicked spot at center of new drawing
   xmin = xmin + (mouseX / (float)windowWidth * w) - (w / 2);
   ymin = ymin + (mouseY / (float)windowHeight * h) - (h / 2);
   // Zoom in
   w *= zoomFactor;
   h *= zoomFactor;
   xmin = xmin - w / (zoomFactor * 2);
   ymin = ymin - h / (zoomFactor * 2);
   magnificationLevel--;
   mandelbrot();
 }
 if (keyPressed && ((keyCode == UP || keyCode == DOWN))) {
   for (int j = 0; j < height; j++) {
     for (int i = 0; i < width; i++) {
       color pixelColor = get(i, j);
       if (keyCode == DOWN) {
         cycleColor = -cycleColor;
         colorOffset--;
       }
       else
       colorOffset++;
       pixels[i+j*width] = pixelColor + cycleColor;
       }
     }
  updatePixels();
 }

}

String mydate(int offset)
{
  Date d = new Date();
  long timestamp = d.getTime() + (86400000 * offset);
  String date = new java.text.SimpleDateFormat("yyyyMMdd").format(timestamp);
  return date;
}

void keyPressed() {
   if (key == ' ')
   save("l-" + magnificationLevel + "-" + mydate(0) + "-" + hour() + minute() + second()+".jpg");
}

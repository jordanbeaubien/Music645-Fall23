/*-------------------------------------*\ 
| MUSIC 645 - Practice Assignment 07A   |
| Programmed by: Jordan Beaubien        |
| Instructor: Scott Smallwood           |
\*-------------------------------------*/


/* Constants */
int canvas_wide = 500;
int canvas_tall = 500;
int FULL_RED = 255;
int FULL_GRN = 255;
int FULL_BLU = 255;

/* Fluid Values */
int grey_conversion = 0;
int conversion_alignment = 1;
int offset = grey_conversion * conversion_alignment;
long now = 0;
long lastNow = 0;
long interval = 17;

/* Sett-Up */
void settings() {
  size(canvas_wide, canvas_tall); 
}

void setup() {
 background(150);
}


/* Animate */
void draw() {
 now = millis();
 if (now - lastNow > interval) {
   
   /* RED */ drawCircle(0.5, FULL_RED - int((grey_conversion / 0.5)), 0, 0);
   /* GRN */ drawCircle(1.5, 0, FULL_GRN - int((grey_conversion / 6.0)), 0);
   /* BLU */ drawCircle(2.5, 0, 0, FULL_BLU - int((grey_conversion / 1.1)));
   /* TOT */ drawAntiCircle(1, 0, FULL_RED - grey_conversion, FULL_GRN - grey_conversion, FULL_BLU - grey_conversion);
   /* NEG */ drawAntiCircle(5, 255, grey_conversion, grey_conversion, grey_conversion);
   
   lastNow = now;
   
   // continuous transition pf grey conversion E[0,255] from one extreme to the other 
   grey_conversion = (grey_conversion + conversion_alignment);
   if (grey_conversion >= 255) {
     conversion_alignment = conversion_alignment * -1;
   }
   if (grey_conversion < 0) {
     conversion_alignment = conversion_alignment * -1;
   }
 }
}


/* Processes */
void drawCircle(float position, int R, int G, int B) {
 noStroke();
 fill(R, G, B);
 circle((canvas_wide / 3) * position, (canvas_tall / 3) * position, (canvas_wide / 2));
}

void drawAntiCircle(float position, int stroke, int R, int G, int B) {
 int circleX = int((canvas_wide / 6) *  position);
 int circleY = int((canvas_tall / 2));
 stroke(stroke);
 fill(R, G, B);
 circle(circleX, circleY, (canvas_wide / 8));
}

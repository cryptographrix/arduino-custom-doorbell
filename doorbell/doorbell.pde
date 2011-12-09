// extension of debounce library for use as a doorbell system
// 
// buttonPin = the pin the appropriate doorbell button is on
// doorbellPin = the pin the appropriate doorbell hardware
//                (the box inside the apartment) is on
// lastButtonState = the last state the associated button was in
// lastDebounceTime = the last time buttonPin has been in lastButtonState

// bells is a nested array of:
// buttonPin doorbellPin lastButtonState lastDebounceTime dingDonged

int heldDownMillis = 1000;    // How long between the "ding" and the "dong"

int bells[4][5] = {
    { 3, 6, LOW, 0, 0 },  // 0 - Chan's
    { 4, 7, LOW, 0, 0 },  // 1 - Nick's
    { 5, 8, LOW, 0, 0 },  // 2 - Basement
    { 9, 6, LOW, 0, 0 }  // 3 - Placeholder for "ring all"
};

// the following variables are long's because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long debounceDelay = 50;    // the debounce time; increase if the output flickers

void setup() {
  int i, j;

  // Handles 0..2 inputs/outputs
  for (i=0; i<3; i++) {
          pinMode(bells[i][0],INPUT);
          pinMode(bells[i][1],OUTPUT);
  }
  
  // handles "ring all" input pin
  pinMode(bells[3][0],INPUT);
}

void loop() {
  // Handles first 3 doorbells
  for (int j=0; j<3; j++) {
      BellLoop(j);
      
      if (bells[j][4] = 1) {
        bells[j][4] = DingDong(bells[j][1]);
      }
  }
  
  // Handles the wildcard doorbell
  int doorbells[3] = { 6,7,8 };
  BellLoop(3);

  if (bells[3][4] = 1) {
    for (int l=0; l<3; l++) {
      bells[3][4] = DingDong(doorbells[l]);
    }
  }
}

void BellLoop (int k) {
  // BellLoop takes bells array member id
  // We do /not/ ring the bells in this function, as that is handled
  // on a per-inputpin basis.
  int buttonPin = bells[k][0];          // button in on this pin
  int lastButtonState = bells[k][2];    // Will be HIGH or LOW
  long lastDebounceTime = bells[k][3];  // see above for why this is a long

  // read the state of the switch into a local variable:
  int reading = digitalRead(buttonPin);

  // If the switch changed, due to noise or pressing:
  if (reading != lastButtonState) {
     // reset the debouncing timer
     bells[k][3] = millis();
  } 
  
  if ((millis() - lastDebounceTime) > debounceDelay) {
     // whatever the reading is at, it's been there for longer
     // than the debounce delay, so take it as the actual current state:
     bells[k][4] = 1;
  }

  // save the reading.  Next time through the loop,
  // it'll be the lastButtonState:
  bells[k][2] = reading;
}

int DingDong (int pin) {
      digitalWrite(pin, HIGH);
      delay(heldDownMillis);
      digitalWrite(pin, LOW);
      
      return 0;
}

// buttonPin - int - the pin the appropriate doorbell button is on
// doorbellPin - int - the pin the appropriate doorbell hardware
//                (the box inside the apartment) is on
// lastButtonState - LOW/HIGH - the last state the associated button was in
// lastDebounceTime - long - the last time buttonPin has been in lastButtonState
// dingDong - boolean - once outside of the loops, should we dingDong?
//
// Bugs:
//  - This will need to be modified to work with a lighted bell.  Did I mention
//      we accidentally got lighted bells?  That means a slight circuit change,
//      as well as a logic change.
//
// Fixed:
//  - This will ring the bells twice: when someone presses and when they release
//      I have to test a fix for this.

long debounceDelay = 50;    // the debounce time; increase if the output flickers
int heldDownMillis = 1000;    // How long between the "ding" and the "dong"

// bells is a nested array of:
// buttonPin doorbellPin lastButtonState lastDebounceTime dingDong
int bells[4][5] = {
    { 3, 6, LOW, 0, 0 },  // 0 - First Floor
    { 4, 7, LOW, 0, 0 },  // 1 - Second Floor
    { 5, 8, LOW, 0, 0 },  // 2 - Basement
    { 9, 6, LOW, 0, 0 }  // 3 - Placeholder for "ring all"
};

int numBells = 3;  // number of doorbells.  NOT number of array members.
//  This presumes that you are using a wildcard doorbell.
//  This is also (currently) used as the last array member of bells[4][5]

// --------- setup/loop ----------

void setup() {
  int i;

  // Handles 0..2 inputs/outputs
  for (i=0; i<numBells; i++) {
          pinMode(bells[i][0],INPUT);
          pinMode(bells[i][1],OUTPUT);
  }
  
  // handles "ring all" input pin
  pinMode(bells[numBells][0],INPUT);
}

void loop() {
  // Handles first 3 doorbells
  for (int j=0; j<numBells; j++) {
      BellLoop(j);
      
      if ((bells[j][4] = 1) && (bells[j][2] == HIGH)) {
        // This will only occur when state has
        // just changed to high
        bells[j][4] = DingDong(j);
      }
  }
  
  // Handles the wildcard doorbell
  // This is horrible because I use
  // numBells to assume last array member.
  // But this is great because of that.
  // THANKS NICK!
  BellLoop(numBells);

  if ((bells[numBells][4] = 1) && (bells[4][2] == HIGH)) {
    // This will only occur when state has
    // just changed to high
    for (int l=0; l<numBells; l++) {
      bells[3][4] = DingDong(l);
    }
  }
  
}

// -------- functions ----------

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

int DingDong (int bellsArrayMember) {
      int pin = bells[bellsArrayMember][1];
      ding(pin);
      delay(heldDownMillis);
      dong(pin);
      
      return 0;
}

void ding (int pin) {
  // Think of this function as "onButtonPress"
   digitalWrite(pin, HIGH);
}

void dong (int pin) {
  // Think of this function as "onButtonRelease"
   digitalWrite(pin, LOW);
}

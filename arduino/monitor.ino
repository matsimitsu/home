/* Electricity */
int el_input_pin = 0;  //define a pin for Photo resistor
int el_led = 11;     //define a pin for LED
int el_state = LOW; // no movement start
int el_input_val = 0;

void setup() {
    pinMode( el_led, OUTPUT );
    pinMode( el_input_pin, INPUT );

   Serial.begin(9600);  //Begin serial communcation
}

void loop() {
    /* Electricity */
    el_input_val = analogRead(el_input_pin);
    if (el_input_val > 100 && el_state == LOW) {
      /* Peak detected */
      el_state = HIGH;
      digitalWrite (el_led, HIGH);
      Serial.println ("{\"e\": 1}");
    } else if (el_input_val < 100 && el_state == HIGH) {
      el_state = LOW;
      digitalWrite (el_led, LOW);
    }
}

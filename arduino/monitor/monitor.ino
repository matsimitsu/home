/* Electricity */
const int el_input_pin = A0;  //define a pin for Photo resistor
const int el_led = 11;     //define a pin for LED
int el_state = LOW; // no movement start
int el_input_val = 0;

/* Gas */
const int gas_input_pin = 5;
const int gas_led = 12;
int gas_state = LOW;
int gas_input_val = 1;

/* Water */
const int water_input_pin = A1;
const int water_led = 13;
int water_state = LOW;
int water_input_val = 0;
int last_water_val = 0;

void setup() {
    /* E */
    pinMode( el_led, OUTPUT );
    pinMode( el_input_pin, INPUT );

    /* G */
    pinMode( gas_led, OUTPUT );
    pinMode( gas_input_pin, INPUT );
    digitalWrite(gas_input_pin, HIGH); // turn on input pin's pull-up resistor

    /* W */
    pinMode( water_led, OUTPUT);
    pinMode (water_input_pin, INPUT);
    digitalWrite(water_input_pin, LOW); // turn on input pin's pull-up resistor

   Serial.begin(9600);  //Begin serial communcation
}

void loop() {
    /* Electricity */
    el_input_val = analogRead(el_input_pin);
    if (el_input_val < 500 && el_state == LOW) {
      /* Peak detected */
      el_state = HIGH;
      digitalWrite (el_led, HIGH);
      Serial.println ("e");
    } else if (el_input_val > 500 && el_state == HIGH) {
      el_state = LOW;
      digitalWrite (el_led, LOW);
    }

    /* Gas */
    gas_input_val = digitalRead(gas_input_pin);
    if (gas_input_val == 0 && gas_state == LOW) {
      gas_state = HIGH;
      digitalWrite (gas_led, HIGH);
      Serial.println ("g");
    } else if (gas_input_val == 1 && gas_state == HIGH) {
       gas_state = LOW;
       digitalWrite (gas_led, LOW);
    }

    /* Water */

    water_input_val = analogRead(water_input_pin);
//    Serial.println(water_input_val);
    if (water_input_val < 22 && water_state == LOW) {
          Serial.println(water_input_val);
    Serial.println(last_water_val);

      water_state = HIGH;
      digitalWrite (water_led, HIGH);
      Serial.println ("w");
    } else if (water_input_val > 28 && water_state == HIGH) {
      water_state = LOW;
      digitalWrite( water_led, LOW );
            Serial.println ("w");
          Serial.println(water_input_val);
    Serial.println(last_water_val);

    }
    last_water_val = water_input_val;
}



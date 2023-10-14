/*-------------------------------------*\ 
| MUSIC 645 - Practice Assignment 05    |
| Programmed by: Jordan Beaubien        |
| Instructor: Scott Smallwood           |
\*-------------------------------------*/

/* 
 *  Task: Instrument with Keyboard Control
 *  Create a simple instrument that you can perform with.  
 *    > Note: you do NOT need to be a musician! Be creative 
 *      and think outside of the box.  
 *
 *  For full credit, ensure:
 *    ✓ That you are able to easily start/stop the instrument's 
 *      sound with your keyboard or some other device
 *    ✓ Use your mouse, trackpad, or some other device to create 
 *      a continuous control parameter (similar to what we did 
 *      in class Tuesday, Oct. 3)
 *
 *           -----------------------   
 *           | CONTROL THE MACHINE |          
 *      ----------------------------------  
 *      | 1 2 3 4 5 6 7 |  scale quality |   
 *      |      - +      | LFO AttackTime |   
 *      |      [ ]      | LFO AttackTime |   
 *      |      R T      |  Transpose     |   
 *      |       G       | Reset Values   |   
 *      |       Q       |     Bail out   |   
 *      | Z X C V B N M |     notes      |   
 *      ---------------------------------- 
 */


/*  
 *****  INITIALIZE VALUES  *****>
 *****  INITIALIZE VALUES  *****>
 *****  INITIALIZE VALUES  *****>
 */

/* Number of voices for instrument. */
7 => int voicesMax;
36 => int keyCentre; // C[-2]
false => int modulating;
false => int qualityChanging;
1 => int keyQuality; // ionian is default
22 => int maxKeys; // number of active computer keys

/* Stop trigger for each voice. */
Event stopNoteTrigger[voicesMax];

/* Available keyboard signals. */
[90, 88, 67, 86, 66, 78, 77, /* Z,X,C,V,B,N,M <- Melody */
 71, /* G <- Reset Synth */
 82, 84, /* R,T <- Modulate key */
 45, 61, /* -,= <- attackTime of LPF */
 91, 93, /* [,] <- releaseTime of LF */
 81, /* Q <- Quit Program */
 49, 50, 51, 52, 53, 54, 55] /* 1thur7 is scale quality */
 @=> int keysValid[];

/* Array of one/off controls for each available button. */
int notesOn[maxKeys];

/* If notesOn[i] is 1, notesOnVoiceID[i] is the active voiceID for the note. */
int notesOnVoiceID[maxKeys];

/* Track how many voices are sounding. */
0 => int voicesActive;

/* Scales <- number of semitones per pitch. */
[0, 2, 4, 5, 7, 9, 11] @=> int ionian[];
[0, 2, 3, 5, 7, 9, 10] @=> int dorian[];
[0, 1, 3, 5, 7, 8, 10] @=> int phyrigian[];
[0, 2, 4, 6, 7, 9, 11] @=> int lydian[];
[0, 2, 4, 5, 7, 9, 10] @=> int mixolydian[];
[0, 2, 3, 5, 7, 8, 10] @=> int aeolian[];
[0, 1, 3, 5, 6, 8, 10] @=> int locrian[];
[ionian, dorian, phyrigian, lydian,
 mixolydian, aeolian, locrian] @=> int notes[][];

/* Scale qualities. */
["ionian    ", "dorian    ", "phrygian  ", "lydian    ",
 "mixolydian", "aeolian   ", "locrian   "] @=> string qualites[];

/* Patch. */
SawOsc tooth[voicesMax]; // saw tooth wave noise maker
LPF saliva[voicesMax]; // highfreq cut off
ADSR mouth[voicesMax]; // envelope for saw wave
ADSR spit[voicesMax]; // envelope for LPF

/* Patchbay. */
for (0 => int i; i < voicesMax; i++) {
  tooth[i] => saliva[i] => mouth[i] => dac;
  spit[i] => blackhole;
  0.999 / voicesMax => tooth[i].gain;
  (10::ms, 2000::ms, .5, 2000::ms) => mouth[i].set;
  (10::ms, 700::ms, .3, 2000::ms) => spit[i].set;
}


/*  
 *********  FUNCTIONS  *********>
 *********  FUNCTIONS  *********>
 *********  FUNCTIONS  *********>
 */

/* Reset to original configurable values. */
fun void refreshSynth() {
  /* Refresh to original LFO attack and release times. */
  for (0 => int i; i < voicesMax; i++) {
    (10::ms, 700::ms, .3, 2000::ms) => spit[i].set;
  }
  1 => keyQuality; // ionian (major)
  36 => keyCentre; // C[-2]
}

/* Adapted from Scott Smallwood: keysquare_poly.ck 
   Get keys and store triggers in array */
fun void lookForKeyPresses() {

    Hid kb; // keyboard object
    HidMsg kbmsg; // messages from keyboard
    if (!kb.openKeyboard(0)) {
      me.exit();
    } // quit if keyboard fails
    
    /* Keyboard is active. */
    while (true) {
        kb => now; // waiting for message
        while (kb.recv(kbmsg)) { // while any key is press
            for (0 => int i; i < keysValid.size(); i++) {
                /* Is a desired key being pressed? */
                if ((kbmsg.ascii == keysValid[i]) && kbmsg.isButtonDown()) {
                  1 => notesOn[i]; } // turn desired key to on.
                  // <<< "UP" + kbmsg.ascii >>>;
                if ((kbmsg.ascii == keysValid[i]) && kbmsg.isButtonUp()) {
                  0 => notesOn[i]; } // turn desired key to off.
                  // <<< "DOWN" + kbmsg.ascii >>>;
            }
        }
    }
}

/* Adapted from Scott Smallwood: keysquare_poly.ck 
   Play a single note with a single voice.
   - voiceIndex -> which voice to use
   - pitch -> which note to play           */
fun void playNote(int voiceIndex, int pitch) {
    //launch a separate spork for moving filter envelope
    spork ~ triggerFilter(voiceIndex);
    
    /* Set which note to play. */
    Std.mtof(notes[keyQuality - 1][pitch] + keyCentre) => tooth[voiceIndex].freq;
    
    /* Attack envelopes. */
    mouth[voiceIndex].keyOn(1); // Saw envelope on
    spit[voiceIndex].keyOn(1); // LPF enevelope on
    
    /* Await signal to release note. */
    stopNoteTrigger[voiceIndex] => now;
    
    /* Release envelopes. */
    mouth[voiceIndex].keyOff(1); // Saw envelope off
    spit[voiceIndex].keyOff(1); // LPF enevelope off
    
    /* Wait for release to complete. */
    mouth[voiceIndex].releaseTime() => now;
}

/* Adapted from Scott Smallwood: keysquare_poly.ck 
   Trigger LFO for triggered note.
   Quits when playNote quits.
   - voiceIndex -> which voice to use   */
fun void triggerFilter(int voiceIndex) {
    while (true) {
        /* Set frequency value of LPF[voiceIndex]. */
        Std.mtof(Math.pow(spit[voiceIndex].value(), 2) * 128) => float midiFrequency;
        midiFrequency => saliva[voiceIndex].freq;
        1::samp=>now;
    }
}

/* Modulate the key centre by +/- semitones. */
fun void modulate(int offset) {
  /* For precise offsetting. */
  true => modulating;

  /* Update with offset */
  keyCentre + offset => keyCentre;

  /* Delay for double-press. */
  100::ms => now;

  /* Allow modulation again. */
  false => modulating;
}

/* Adjust attack time of LFO. */
fun void adjustAttackLFO(int offset) {
  for (0 => int i; i < voicesMax; i++) {
    spit[i].attackTime(spit[i].attackTime() + (10::ms * offset));
    /* Max is 5 seconds attack time. */
    if (spit[i].attackTime() > 5::second) {
      spit[i].attackTime(5::second);
    }
  }
}

/* Adjust attack time of LFO. */
fun void adjustReleaseLFO(int offset) {
  for (0 => int i; i < voicesMax; i++) {
    spit[i].releaseTime(spit[i].releaseTime() + (10::ms * offset));
    /* Max is 5 seconds release time. */
    if (spit[i].releaseTime() > 5::second) {
      spit[i].releaseTime(5::second);
    }
  }
}

/* Sets the keys to a mode of the major scale. */
fun void setQuality(int qualityIndex) {
  /* For precise offsetting. */
  true => qualityChanging;

  /* Update quality. */
  qualityIndex => keyQuality;

  /* Delay for double-press. */
  100::ms => now;

  /* Allow modulation again. */
  false => qualityChanging;
}

/* Visual interface for users reference. */
fun void displayScreen() {

  for (0 => int i; i < 25; i++) {
    <<< " ", " " >>>; // whitespace to simulate screen refreshing
  }
  <<< "       -----------------------", " " >>>;
  <<< "       | CONTROL THE MACHINE |       ", " " >>>;
  <<< "-------------------------------------", " " >>>;
  <<< "|  1 2 3 4 5 6 7  |   scale quality |", " " >>>;
  <<< "|       - +       |  LFO AttackTime |", " " >>>;
  <<< "|       [ ]       |  LFO AttackTime |", " " >>>;
  <<< "|       R T       |   Transpose     |", " " >>>;
  <<< "|        G        |  Reset Values   |", " " >>>;
  <<< "|        Q        |      Bail out   |", " " >>>;
  <<< "|  Z X C V B N M  |      notes      |", " " >>>;
  <<< "-------------------------------------", " " >>>;
  <<< " ", " " >>>;
  <<< "       offset of zero is C[-2] ", " " >>>;
  <<< "-------------------------------------", " " >>>;
  <<< "| VALUES |  Z-X-C-V-B-N-M  |  UNITZ |", " " >>>;
  <<< "-------------------------------------", " " >>>;
  <<< "| LFO Attack   :", spit[0].attackTime() / 44100, "  seconds |" >>>;
  <<< "| LFO Release  :", spit[0].releaseTime() / 44100, "  seconds |" >>>;
  <<< "| voicesActive :", voicesActive, "                 |" >>>;
  if ((keyCentre - 36) < 0) { // make up for "-" character in spacing
    <<< "| Key Offset   :", keyCentre - 36,"      semitones |" >>>;
  } else { 
  <<< "| Key Offset   :", keyCentre - 36, "       semitones |" >>>;
  }
  <<< "| Key Quality  :", qualites[keyQuality - 1], "        | ">>>;
  <<< "-------------------------------------", " " >>>;
}

/* Sporked function to continuously refresh the values. */
fun void refreshScreen() {
  while (true) {
    displayScreen();
    50::ms => now;
  }
}

/*  
 ********  SYNTHESIZING  *******>
 ********  SYNTHESIZING  *******>
 ********  SYNTHESIZING  *******>
 */

/* Activate listening device. */
spork ~ lookForKeyPresses();
spork ~ refreshScreen();

/* Sound on notes, call broadcast to end off notes. */
while (true) {
  
  /* For each possible note. */
  for (0 => int i; i < notes[0].cap(); i++) {

    /* If note is pressed and has not played. */
    if (notesOn[i] && !(notesOnVoiceID[i])) {

        /* Play note and record which voice. */
        spork ~ playNote((voicesActive % voicesMax), i);

        /* Log which voice is being played. */
        (voicesActive % voicesMax) + 1 => notesOnVoiceID[i];

        /* Increment voices active. */
        voicesActive++;
    }
    /* If note is playing and has been released. */
    if (!(notesOn[i]) && notesOnVoiceID[i]) {
      
      /* Trigger release of note. */
      stopNoteTrigger[notesOnVoiceID[i] - 1].broadcast();

      /* Refresh voiceID for previously unreleased note. */
      0 => notesOnVoiceID[i];
      
      /* Decrement voices active. */
        voicesActive--;
    }
  }
  
  /* "G" resets values to initial settings. */
  if (notesOn[7]) {
    spork ~ refreshSynth();
  }

  /* "R" modulates synth down one semitone. */
  if (notesOn[8] && !(modulating)) {
    spork ~ modulate(-1); }
  /* "T" modulates synth up one semitone. */
  if (notesOn[9] && !(modulating)) {
    spork ~ modulate(1); }

  /* "-" reduces LFO attack time. NO NEGATIVE VALUES. */
  if (notesOn[10] && (spit[0].attackTime() >= 10::ms)) {
    spork ~ adjustAttackLFO(-1);
  }
  /* "=" increases LFO attack time. */
  if (notesOn[11] && (spit[0].attackTime() < 5::second)) {
    spork ~ adjustAttackLFO(1);
  }

  /* "[" reduces LFO release time. NO NEGATIVE VALUES. */
  if (notesOn[12] && (spit[0].releaseTime() >= 10::ms)) {
    spork ~ adjustReleaseLFO(-1);
  }
  /* "]" increases LFO release time. */
  if (notesOn[13] && (spit[0].releaseTime() < 5::second)) {
    spork ~ adjustReleaseLFO(1);
  }

  /* "Q" turns off the synth. */
  if (notesOn[14]) {
    Machine.removeAllShreds();
  }

  /* 1thru7 num keys will adjust the major-mode key quality. */
  for (15 => int i; i < keysValid.cap(); i++) {
    if(notesOn[i] && !(qualityChanging)) {
      spork ~ setQuality(i - 14);
    }
  }
  
  /* Minimize double presses. */
  10::ms => now;
}
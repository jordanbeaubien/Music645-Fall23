/*-------------------------------------*\ 
| MUSIC 645 - Practice Assignment 03    |
| Programmed by: Jordan Beaubien        |
| Instructor: Scott Smallwood           |
\*-------------------------------------*/

/* 
 *  Task: Random Audio File Player
 *    ✓ Use ChucK to create a KTM-like interface that randomly plays a
 *      soundfile in a directory, triggered from any key on your laptop 
 *      keyboard (Hint: use HID, SndBuf).
 *  Bonus:
 *    ✓ Play through all files before repeating
 *    ✓ Automatically scan folder for filenames, populate an array with
 *      the filenames, and use this to choose files.
 *
 *  Details:
 *    - This program takes in key presses and outputs a random sound from directory.
 *    - Sounds are taken from Native instrument Library "Blip & Blob"
 *    - The list of samples is automatically gathered and randomized
 *    - The sounds play from the end of the list to the start of the list
 *    - When all sounds have been played the list is shuffled and again, played
 *      end to front.
 *    - Only letter characters are allowed/active
 *    - 'q' key exits the program
 */


/* Make a randomized array of found soundfile filenames. */
me.dir() + "snd/" => string pathToSFX; 
FileIO dir_sfx;                     
dir_sfx.open(pathToSFX, FileIO.READ);
dir_sfx.dirList() @=> string sfx_filenames[];
sfx_filenames.cap() - 1 => int unplayedSounds; // to play each sound once before repeating
sfx_filenames.shuffle(); 
true => int canPlaySound; // this sampler is monophonic, set to false while sound plays 

/* Create event for playing a random sound. */
Event randomSound;

/* Function to prove that list is shuffled before sounds repeat. */
fun void printSoundFiles() {
  for (0 => int i; i < sfx_filenames.cap(); i++) {
    <<< sfx_filenames[i] >>>;
  }
}

/* Professor resource to check state of file list. */
// printSoundFiles();

/* This function gets input from the keyboard. */
fun void listenForKeyPresses() {

  /* Tell user that device is active. */
  <<< "listening to..." >>>;

  Hid manualInterface; // active keyboard
  HidMsg interfaceMessage; // messages of active keyboard
  0 => int device; // default device id
  if (!manualInterface.openKeyboard(device)) { // if device failes to load, quit
    me.exit();
  }

  /* Notify user which interface is in use. */
  <<< "Interface: " + manualInterface.name() + ", is ready" >>>;

  /* Ready for keypress. */
  while (true) {
    manualInterface => now;
    while (manualInterface.recv(interfaceMessage)) { // while a message recieved
      if (interfaceMessage.isButtonDown()) { // if is a button down message
        if ((interfaceMessage.ascii >= 65) && (interfaceMessage.ascii <= 90)) { // if is an alphabet char
          if ((interfaceMessage.ascii == 81)) { // q-key quits
            <<< "[Q] quits the program." >>>;
            Machine.clearVM(); // ensure full quit
          } else { // any alphabetical char that is not q
            // <<< interfaceMessage.ascii, "sounds like", sfx_filenames[unplayedSounds] >>>;
            randomSound.broadcast();
          }
        }
      }
    }
  }
}

/* This function plays the sounds. */
fun void playRandomSound() {

  false => canPlaySound; // program is in progress and monophonic
  SndBuf sound => dac; // create sound device

  /* When all sounds have been played, reset the list. */
  if (unplayedSounds == 0) {
    sfx_filenames.cap() - 1 => unplayedSounds; // reset counter
    sfx_filenames.shuffle(); // shuffle the deck of sounds to replay
    
    /* Professor resource to check state of file list. */
    // printSoundFiles();
  }

  /* Play the sound. */
  pathToSFX + sfx_filenames[unplayedSounds] => sound.read;
  1::second => now;
  unplayedSounds--; // prepare next sound for next key press
    <<< "\n" >>>;
    <<< "[READY FOR INPUT]" >>>;

  true => canPlaySound; // sound finished, ready for next key
}


/* Start up interface to listen for key presses. */
spork ~ listenForKeyPresses();

/* Play a random sound when an alphabetical character is pressed. */
while (true) {
  randomSound => now; // wait for letter key to be pressed on keyboard
  if (canPlaySound) { // monophonic noisemaker: one at a time, if no sound playing
    spork ~ playRandomSound(); 
  } else {
      <<< "[BUSY]" >>>;
  }
}
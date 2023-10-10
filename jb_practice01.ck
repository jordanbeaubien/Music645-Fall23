/*----------------------------------------------------------------*\ 
| MUSIC 645 - Practice Assignment 01                               |
| Programmed by: Jordan Beaubien                                   |
| Instructor: Scott Smallwood                                      |
| Song Used: Super Mario Bros. Theme                               |
|   -> Written by Koji Kondo                                       |
| Score Source: https://musescore.com/user/27687306/scores/4913846 |
\*----------------------------------------------------------------*/

/* 
 *  Task:
 *    - Review basic concepts: Variables, Loops, Conditional Statements, and Functions.
 *    - Create a program the exercises each of these concepts at least once.
 *    - Use ChucK, and/or use a language you already know
 *    - Turn in a text file in whatever language you are using
 */


/*  
 * TUNE. 
 */

/* Initialize data structure. */
class marioMelody { // [bar][pulse]; pulse == greatest subdivision. 8 => 1/8th note
  int introNotePitches[2][8];
  int introNoteDurations[2][8];
  int mainNotePitches[4][8];
  int mainNoteDurations[4][8];
  int outroNotePitches[3][8];
  int outroNoteDurations[3][8];
}

/* Initialize unit generator. */
SinOsc melody => ADSR env1 => dac;
0.8 => melody.gain;
1::second * 0.8 => dur beat;
(1::ms, beat / 16, 0, 1::ms) => env1.set;

/* Play a pitch. */
fun void playNote(int pitch, int duration) {
  Std.mtof(pitch + 24) => melody.freq;
  1 => env1.keyOn;
  beat / duration => now; // if duration == 8, then beat/duration is an eighth note
}

/* Play a bar. */
fun void playBar(int barsOfNotes[][], int lengthOfNotes[][]) {
  for (0 => int i; i < barsOfNotes.cap(); i++) {                      // for each bar,
    for (0 => int j; j < barsOfNotes[i].cap(); j++) {                 // for each note,
      if (barsOfNotes[i][j]) {                                        // if is a note: play it
        playNote(barsOfNotes[i][j], lengthOfNotes[i][j]);
      } else {                                                        // else is a rest, of silence
        beat / lengthOfNotes[i][j] => now;
      }
    }
  }
}


/*  
 * REHEARSE. 
 */

/* Initialize melody object. */
marioMelody mainTheme;
int repeats;

/* Write intro-melody. */
[52, 52,  0, 52, 0, 48, 52] @=> mainTheme.introNotePitches[0];         // bar 00 pitches
[ 8,  8,  8,  8, 8,  8,  4] @=> mainTheme.introNoteDurations[0];       // bar 00 durations
[55,  0, 43,  0] @=> mainTheme.introNotePitches[1];                    // bar 01 
[ 4,  4,  4,  4] @=> mainTheme.introNoteDurations[1];                  // ...

/* Write main-melody. */
[48,  0, 43,  0, 40] @=> mainTheme.mainNotePitches[0];                 // bar 02
[ 4,  8,  4,  8,  4] @=> mainTheme.mainNoteDurations[0];
[ 0, 45, 47, 46, 45] @=> mainTheme.mainNotePitches[1];                 // bar 03
[ 8,  4,  4,  8,  4] @=> mainTheme.mainNoteDurations[1];
[43, 52, 55, 57, 53, 55] @=> mainTheme.mainNotePitches[2];             // bar 04
[(16/3), (16/3), (16/3), 4, 8, 8] @=> mainTheme.mainNoteDurations[2];  // (16/3) for 1/4 triplets 
[ 0, 52, 48, 50, 47,  0] @=> mainTheme.mainNotePitches[3];             // bar 05
[ 8,  4,  8,  8,  4,  8]  @=> mainTheme.mainNoteDurations[3];

/* Write outro-melody. */
[48,  0, 43,  0, 40] @=> mainTheme.outroNotePitches[0];                // bar 06
[ 4,  8,  4,  8,  4] @=> mainTheme.outroNoteDurations[0];               
[45, 47, 44, 46, 44] @=> mainTheme.outroNotePitches[1];                // bar 07
[(16/3), (16/3), (16/3), (16/3), (16/3), (16/3)] @=> mainTheme.outroNoteDurations[1]; 
[40, 38, 40] @=> mainTheme.outroNotePitches[2];                        // bar 08
[ 8,  8, (8/3) + 1] @=> mainTheme.outroNoteDurations[2]; 


/*  
 * PERFORM. 
 */

<<< "It's a-me, Mario!!" >>>;

/* Perform intro-melody. */
playBar(mainTheme.introNotePitches, mainTheme.introNoteDurations);

/* Perform main-melody. */
for (2 => repeats; repeats > 0; repeats--) {
  playBar(mainTheme.mainNotePitches, mainTheme.mainNoteDurations);
}

/* Perform outro-melody. */
playBar(mainTheme.outroNotePitches, mainTheme.outroNoteDurations);

<<< "(raucous applause)" >>>;


/*  
 * EXIT. 
 */
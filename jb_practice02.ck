/*-------------------------------------------------------------------------*\ 
| MUSIC 645 - Practice Assignment 02 (Basic Exercise in Timing)             |
| Programmed by: Jordan Beaubien                                            |
| Instructor: Scott Smallwood                                               |
| Samples: From Native Instruments, Battery 4                               |
| Tutorial: https://chuck.cs.princeton.edu/doc/examples/basic/sndbuf.ck     |
\*-------------------------------------------------------------------------*/

/* 
 *  Task: 
 *    - Use ChucK to make a timed clicker. Make this as complicated as you'd like.
 *    - If you use another language, show how you would do this in that languege.
 */


/* Verify a file was successfully opened. */
fun void verifyPipe(FileIO file, string sample) {
  if (!file.good()) {
    cherr <= "can't open file: " <= sample <= "for reading..." <= IO.newline();
    me.exit(); }
}

/* Path to samples. */
me.dir() + "BatteryKick707.wav" => string sampleKick;
me.dir() + "BatterySnare707.wav" => string sampleSnare;
me.dir() + "BatteryClosedHH707.wav" => string sampleHHat;
me.dir() + "BatteryCrash707.wav" => string sampleCrash;

/* Verify sample files exist. */
FileIO kickDrum;
FileIO snareDrum;
FileIO HHat;
FileIO CymCrash;
kickDrum.open(sampleKick, IO.READ | IO.BINARY);
snareDrum.open(sampleSnare, IO.READ | IO.BINARY);
HHat.open(sampleHHat, IO.READ | IO.BINARY);
CymCrash.open(sampleCrash, IO.READ | IO.BINARY);
verifyPipe(kickDrum, sampleKick);
verifyPipe(snareDrum, sampleSnare);
verifyPipe(HHat, sampleHHat);
verifyPipe(CymCrash, sampleCrash);

/* Load samples in respective buffers. */
SndBuf kickBuffer => dac;
SndBuf snareBuffer => dac;
SndBuf HHatBuffer => dac;
SndBuf CrashBuffer => dac;

/* Mute samples for silent read and set volume. */
0.0 => kickBuffer.gain;
0.0 => snareBuffer.gain;
0.0 => HHatBuffer.gain;
0.0 => CrashBuffer.gain;
0 => HHatBuffer.pos;
sampleHHat => HHatBuffer.read;
sampleKick => kickBuffer.read;
sampleSnare => snareBuffer.read;
sampleCrash => CrashBuffer.read;
1::second / 2 => now; // ensure samples fully load before unmuted 
0.8 => kickBuffer.gain;
0.9 => snareBuffer.gain;
0.6 => HHatBuffer.gain;

/* Count in. */
0 => int count;
while (++count <= 4) {
  0 => HHatBuffer.pos;
  1::second / 2 => now;
}

/* Drum loop. */
0 => int bars;
while(++bars <= 4) {
  0 => kickBuffer.pos;      // 1
  0 => HHatBuffer.pos;
  1::second / 2 => now;

  0 => HHatBuffer.pos;      // 2
  1::second / 2 => now;

  0 => snareBuffer.pos;     // 3
  0 => HHatBuffer.pos;
  1::second / 2 => now;

  0 => HHatBuffer.pos;      // 4
  1::second / 2 => now;
}

/* End. */
0.6 => CrashBuffer.gain;
0 => kickBuffer.pos;
0 => CrashBuffer.pos;
1::second * 1.5 => now;

/* Verify no load errors. */
<<< "We Made It" >>>;
{{
  **************************************************************
  * Button.spin  v 1.00                                        *
  * Copyright: Kyle Crane  - 2009                              *
  * Built up from the PELabs example code.  It can produce     *
  * the following:                                             *
  *                                                            *
  * -Time a button was held down. (ChkBtnHoldTime)             *
  * -If a button was pressed, held for a moment and            *
  *    released. (ChkBtnPulse)                                 *
  * -If a button was pressed, held for at least some time      *
  *    period.  (ChkBtnHold)                                   *
  *                                                            *
  * This is a forground object and is intended to be used      *
  * where a few buttons need to be checked and a               *
  * background scanning process is not required or desired.    *
  * The object assumes that the pins used are already set as   *
  * inputs.                                                    *
  *                                                            *
  * Future improvements include plans to allow for             *
  * mask-based use of the non-timed functions to check a group *
  * of buttons and report back a binary table value that shows *
  * the state of each instead of a single pin.                 *
  **************************************************************
}}

PUB ChkBtnHoldTime(pin, activeState, mSecDelay, mSecMax) : delta | time1, time2, mSec, waitTicks, maxTicks
{{
This function checks to see if a button is pressed and then times the press to determine how long the
button was held down.  It returns the time in milliseconds.  The time returned INCLUDES the requested
settle delay which must be at least 1ms.  If active state is not held for at least the settle delay
time then the fuction treats it as if no press occured.  It blocks execution until the the button is
released or mSecMax is reached if it is greater than 0.

Parameters:
  pin           - The I/O pin to watch for the button press.
  activeState   - The digital state that is considered a button press [0 or 1].
  mSecDelay     - The debounce or settle time to ignore transitions during, defaults to 1 millisecond.
  mSecMax       - The maximum time to allow the button to be held for.  After that time we force a return.
                  A zero here inidicates no timeout, the function will not return until the button is
                  released.  
}}
  if mSecDelay < 1                              'If the delay is less than 1 mSec then increase it to 1.
    mSecDelay := 1

  delta := 0
  mSec := clkfreq/1000                          'Number of clock ticks per millisecond.
  waitTicks := mSec * mSecDelay                 'Number of clock ticks for bounce settleing.
  maxTicks := mSec * mSecMax                    'Number of clock ticks for hold timeout.

  'If a timeout was requested:
  if maxTicks > 0
    time1 := cnt                                      'Record the start time.
    if ina[pin] == activeState                        'If the pin was on when we checked
      waitcnt(waitTicks + cnt)                        '  wait for the requested settle delay
      if ina[pin] <> activeState                      '  Is it still in the requested state?
        return                                        '    If not return while delta is 0
      else
        repeat until cnt > time1 + maxTicks           '  Otherwise loop until the timeout is reached
          if ina[pin] <> activeState                  '    If the button is released first
            time2 := cnt                              '      Record the time.
            delta := ((time2 - time1))/mSec           '      Calculate the delta in milliseconds.
            return                                    '      Return now.
            
        time2 := cnt                                  '       When the loop exits calculate the delta.
        delta := ((time2 - time1))/mSec
        return

  'If no timeout was requested:
  if maxTicks == 0
    time1 := cnt                                      'Record the start time.
    if ina[pin] == activeState                        'If the pin was on when we checked
      waitcnt(waitTicks + cnt)                        '  wait for the requested settle delay
      if ina[pin] <> activeState                      '  Is it still in the requested state?
        return                                        '    If not exit while delta = 0
      else                                              
        repeat until ina[pin] <> activeState          '    Repeat until the button is released.         
        time2 := cnt                                  '    When the loop exits calculate the delta.
        delta := ((time2 - time1))/mSec
        return

PUB ChkBtnPulse(pin, activeState, mSecDelay) : wasPressed | waitTicks, mSec
{{
This function will return true if the button is held active for the designated delay time and then released.
If this is called in a loop it will return a press only when the button has been pressed and released.  Other
execution is blocked while the button is held down so it will not pruduce addtional presses if the user is
holding the button down.

Parameters:
  Pin            - I/O pin to check
  activeState    - The digital state that is considered a button press
  mSecDelay      - The debounce or settle time in milliseconds for a valid press.

}}
  if mSecDelay < 1                              'If the delay is less than 1 millisecond increase it to 1
    mSecDelay := 1
    
  mSec := clkfreq/1000                          'Clock ticks per millisecond
  waitTicks := mSec * mSecDelay                 
  
  if ina[pin] == activeState                    'If the pin is in the desired state.
    waitcnt(waitTicks + cnt)                    'Wait the requested amount of settle time.
    if ina[pin] == activeState                  'Is it still in the desired state?                                          
      repeat while ina[pin] == activeState                          
      wasPressed := 1                           
      
  else
    wasPressed := 0                             'Transient as defined by the request so we won't count it.

PUB ChkBtnHold(pin, activeState, mSecDelay) : wasPressed | waitTicks, mSec
{{
This function will return true if the button is held high for the designated delay time.  It will then
return immediately if that condition is met.  If this is called in a loop it will return a press each
time it is called for as long as the button is held down.  Long delay values will block execution.

Parameters:
  pin            - I/O pin to check
  activeState    - The digital state that is considered a button press
  mSecDelay      - The debounce or settle time in milliseconds for a valid press.
  
}}
  if mSecDelay < 1                              'If the delay is less than 1 millisecond increase it to 1
    mSecDelay := 1
    
  mSec := clkfreq/1000                          'Clock ticks per millisecond.
  waitTicks := mSec * mSecDelay                 
  
  if ina[pin] == activeState                    'If the pin is in the desired state.
    waitcnt(waitTicks + cnt)                    'Wait the requested amount of settle time.
    if ina[pin] == activeState                  'Is it still in the desired state?                    
      wasPressed := 1                           
      
  else
    wasPressed := 0                             'Transient as defined by the request so we won't count it.

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}        
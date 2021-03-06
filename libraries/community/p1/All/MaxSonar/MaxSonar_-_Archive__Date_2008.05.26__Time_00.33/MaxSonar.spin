{{
***************************************
* Maxbotix MaxSonar Objec V1.1        *
* (C) 2008 Anon-Industries            *
* Author:  Harrison Jones             *
* Started: 05-24-2008                 *
***************************************

Interface to Maxbotix Sonar sensor and measure distance.
Connections should be as follows:
MaxBotix MaxSonar   ---         Propeller
GND                             GND
+5                              +5 or +3.3
Tx                              Pin(This pin is an INPUT)
Rx                              Another Pin(This pin is an OUTPUT)
An                              NC
PW                              NC
BW                              NC

USAGE:
CON
  SonarTx = 1 'or whatever pin you are using

VAR
  long SonarDist

OBJ
  Sonar : "MaxSonar"
PUB Main
  Sonar.Init(SonarTx) 'Initalizes the MaxSonar and saves SonarTx to memory.
  'Rest of your code

  SonarDist := Sonar.GetDist  'Gets distance in inches and feeds it into a variable.
  'Now do something with the distance
 
***************************************
* UPDATES                             *
***************************************
*v1.1 * MAY 25, 2008                  *
******                                *
* Updated code to support PWM input   *
***************************************

See MaxSonar_Demo.spin for demonstartion
}}
'Con
  '_clkmode = xtal1 + pll16x
  '_xinfreq = 5_000_000
  
Var
  byte serialByte
  byte serialPacket[3]
  byte packetIsInit
  byte usedPin
  byte sensorMethod

  long us
  
OBJ
  Com :  "FullDuplexSerial"
PUB Start(tx,pw,method)
{{Start(tx pin, pw pin, method}}
{{Methods:
0 - Serial Input
1 - PWM Input(Blocking)
}}
  if method == 0
    usedPin := tx
    Com.Start(usedPin,-1,%0011,9_600)
    us:=0
  else
    usedPin := pw
    us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us
  
PUB stop
  if sensorMethod == 0
    Com.stop
      
PUB getDist : distance
  if us == 0
    distance := getDistSerial
  else
    distance := getDistPWM
    
PRI getDistSerial : distance | done, i
  done := 0
   repeat until done == 1
    serialByte := Com.rx
    if serialByte == $52
      if packetIsInit == 1
        packetIsInit := 0 ''Restart the packet
        i := 0 ''Restart the counter
        ''Com2.str(String(13,"#ERR$",13))
      else
        packetIsInit := 1
        i := 0
    else
      if packetIsInit == 1 ''Packet is initalized and we have data, throw it in the pile
        if serialByte == $0D ''Packet is over, send out the data
          distance := (serialPacket[0] - 48) * 100 + (serialPacket[1] - 48) * 10 + (serialPacket[2] - 48)
          packetIsInit := 0
          done := 1
        else
          serialPacket[i] := serialByte
          i += 1
Pri getDistPWM : distance | done, i
  distance := Pulsin_uS(usedPin,1) / 147   

Pri PULSIN_uS (Pin, State) : Duration | ClkStart, clkStop, timeout
{{
  Reads duration of Pulse on pin defined for state, returns duration in 1uS resolution
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin_uS(5,1)
    BS2.Debug_Dec(x)
}}
 
   Duration := PULSIN_Clk(Pin, State) / us + 1             ' Use PulsinClk and calc for 1uS increments
    
Pri PULSIN_Clk(Pin, State) : Duration 
{{
  Reads duration of Pulse on pin defined for state, returns duration in 1/clkFreq increments - 12.5nS at 80MHz
  Note: Absence of pulse can cause cog lockup if watchdog is not used - See distributed example
    x := BS2.Pulsin_Clk(5,1)
    BS2.Debug_Dec(x)
}}

  DIRA[pin]~
  ctra := 0
  if state == 1
    ctra := (%11010 << 26 ) | (%001 << 23) | (0 << 9) | (PIN) ' set up counter, A level count
  else
    ctra := (%10101 << 26 ) | (%001 << 23) | (0 << 9) | (PIN) ' set up counter, !A level count
  frqa := 1
  waitpne(State << pin, |< Pin, 0)                         ' Wait for opposite state ready
  phsa:=0                                                  ' Clear count
  waitpeq(State << pin, |< Pin, 0)                         ' wait for pulse
  waitpne(State << pin, |< Pin, 0)                         ' Wait for pulse to end
  Duration := phsa                                         ' Return duration as counts
  ctra :=0                                                 ' stop counter

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
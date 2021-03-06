DAT programName byte "dwd_Ps2DemoV10", 0
CON
{{*********** Public Notes ********************
  
  By: Duane Degn
  Version 1.0 added to OBEX: May 3, 2012
  
  Program to demonstrate dwd_PS2ControllerV10.
  See notes in dwd_PS2ControllerV10.
  
  8 pin male connector  
  1 - data (brown)              to _Ps2DataPin     Pulled to 3.3V with 10K resistor
  2 - command (orange)          to _Ps2DataPin + 1
  3 - select (yellow)           to _Ps2DataPin + 2
  4 - clock (blue)              to _Ps2DataPin + 3
  5 - Vdd (red)                 3.3V
  6 - Vss (black)               ground
  7 - (green)                   nc
  8 - duo shock power (grey or purple)   nc

}}

CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

 
  _Ps2DataPin = 8 ' pins need to be in this order: DAT, CMD, SEL, CLK
  _Delay = 10_000 ' in microseconds

  _DebugBaud = 57600 

''     Parallax Serial Terminal
''    Control Character Constants
''─────────────────────────────────────
  CS = 16  ''CS: Clear Screen      
  CE = 11  ''CE: Clear to End of line     
  CB = 12  ''CB: Clear lines Below 

  HM =  1  ''HM: HoMe cursor       
  PC =  2  ''PC: Position Cursor in x,y          
  PX = 14  ''PX: Position cursor in X         
  PY = 15  ''PY: Position cursor in Y         

  NL = 13  ''NL: New Line        
  LF = 10  ''LF: Line Feed       
  ML =  3  ''ML: Move cursor Left          
  MR =  4  ''MR: Move cursor Right         
  MU =  5  ''MU: Move cursor Up          
  MD =  6  ''MD: Move cursor Down
  TB =  9  ''TB: TaB          
  BS =  8  ''BS: BackSpace          
           
  BP =  7  ''BP: BeeP speaker

  ' PlayStation 2 button enumeration (not used by program, here to show order data is stored in RAM)
  #0, _SquarePs2, _CrossPs2, _CirclePs2, _TrianglePs2, { 0 - 3
    } _R1Ps2, _L1Ps2, _R2Ps2, _L2Ps2, { 4 - 7
    } _LeftArrowPs2, _DownArrowPs2, _RightArrowPs2, _UpArrowPs2, { 8 - 11
    } _StartPs2, _RightJoystickPs2, _LeftJoystickPs2, _SelectPs2' 12 - 15

        
VAR
  
  ' Keep below in order and together.
  long psData[5], allDigitalButtons, debugLong
  ' Keep above in order and together.
  long menuTime, menuInterval, returnedValue, time0, time1

  word debugPtr, actionPtr 
 
  ' Keep below in order and together.
  byte rightX, rightY, leftX, leftY
  byte digitalButton[Ps2#_NumberOfControllerButtons]
  byte analogButton[Ps2#_NumberOfAnalogButtons], mode, dataSize
  ' Keep above in order and together.
  
OBJ
  
  Com : "FullDuplexSerial"     ' uses one cog
  Ps2 : "dwd_PS2ControllerV10"
  
PUB Setup | localIndex

  menuInterval := clkfreq * 4

  Com.Start(31, 30, 0, _DebugBaud)
  
  returnedValue := PS2.Start(_Ps2DataPin, 10_000, @PsData, @rightX)
  menuTime := cnt
      
  Com.str(@menuDisplay)  
  
  repeat
    result := Com.rxcheck
    if result == "a"
      Com.str(@analogMode)
      PS2.Analog
      PointToDebug
    if result == "d"
      Com.str(@digitalMode) 
      PS2.Digital
      PointToDebug
    if result == "b"
      Com.str(@buttonMode)
      PS2.AnalogButtons
      PointToDebug
    Com.tx(PY)     
    Com.tx(13)       
    result := 14
    repeat localIndex from 0 to 7     
      Com.tx(PX)     
      Com.tx(result)          
      Com.dec(digitalButton[localIndex])
      result += 5 

    Com.tx(PY)     
    Com.tx(18)       
    result := 14
    repeat localIndex from 8 to 15      
      Com.tx(PX)     
      Com.tx(result)          
      Com.dec(digitalButton[localIndex])
      result += 5

    Com.tx(PY)     
    Com.tx(14)      
    result := 12
    repeat localIndex from 0 to 7         
      Com.tx(PX)     
      Com.tx(result)          
      Pad(analogButton[localIndex])
      result += 5 
           
    Com.tx(PY)     
    Com.tx(19)      
    result := 12
    repeat localIndex from 8 to 11       
      Com.tx(PX)     
      Com.tx(result)          
      Pad(analogButton[localIndex])
      result += 5
        
    Com.tx(PY)     
    Com.tx(21)       
    Com.tx(PX)     
    Com.tx(9)       
    Com.hex(psData[0], 8)  
    Com.tx(",")       
    Com.tx("$")       
    Com.hex(psData[1], 8)  
    Com.tx(",")       
    Com.tx("$")       
    Com.hex(psData[2], 8)  
    Com.tx(",")       
    Com.tx("$")       
    Com.hex(psData[3], 8)  
    Com.tx(",")       
    Com.tx("$")       
    Com.hex(psData[4], 8)

    Com.tx(PY)     
    Com.tx(22)       
    Com.tx(PX)     
    Com.tx(17)       
    Com.bin(allDigitalButtons, 16)

    Com.tx(PY)     
    Com.tx(10)       
    Com.tx(PX)     
    Com.tx(17)       
    Pad(leftX)      

    Com.tx(PY)     
    Com.tx(10)       
    Com.tx(PX)     
    Com.tx(23)       
    Pad(leftY)      

    Com.tx(PY)     
    Com.tx(10)       
    Com.tx(PX)     
    Com.tx(34)       
    Pad(rightX)      

    Com.tx(PY)     
    Com.tx(10)       
    Com.tx(PX)     
    Com.tx(40)       
    Pad(rightY)      

    PointToMode
    Com.str(actionPtr)
    Com.str(debugPtr)
    DisplayInputTypes
    if cnt - menuTime > menuInterval ' Update screen frequently to start with
      menuTime += menuInterval       ' then only once in a while after it has
      if menuInterval < clkfreq * 20 ' been running for a while.
        menuInterval += clkfreq * 4     
      Com.str(@menuDisplay)
      Com.tx(PY)     
      Com.tx(26)       
      Com.tx(PX)     
      Com.tx(3)       
      Com.str(string("programName = "))
      Com.str(@programName)
      
    waitcnt(clkfreq / 4 + cnt)
    
PUB DisplayInputTypes   

    case dataSize
      $1:
        Com.str(@digitalButtonsOnly)
      $3:
        Com.str(@digitalButtonsAndJoysticks)
      $9:
        Com.str(@maxData)
      other:
        Com.str(@unknownData)
        Com.tx(32)       
        Com.tx(32)       
        Com.tx("$")     
        Com.hex(mode, 2)
        Com.tx(44)       
        Com.tx(32)       
        Com.tx("$")     
        Com.hex(dataSize, 2)

PUB PointToMode

    case mode
      $4:
        actionPtr := @digitalDisplay
      $7:
        actionPtr := @analogDisplay 
      $F:
        actionPtr := @configDisplay
      other:
        actionPtr := @unknownDisplay

PUB PointToDebug

  case debugLong
    Ps2#_StayDigital:
      debugPtr := @stayInDigital
    Ps2#_ToDigital:
      debugPtr := @toDigtial
    Ps2#_StayAnalog:
      debugPtr := @stayInAnalog
    Ps2#_ToAnalog:
      debugPtr := @toAnalog
    Ps2#_OnAnalogButtons:
      debugPtr := @onAnalogButtons
    Ps2#_OffAnalogButtons:
      debugPtr := @offAnalogButtons
     
PUB Pad(value)

  if value < 100
    Com.tx(32)
  if value < 10
    Com.tx(32)
  Com.dec(value)

DAT
                        
stayInDigital           byte PX, 23, PY, 23, "Stay in digital mode.", 0
toDigtial               byte PX, 23, PY, 23, "Switched to digital mode.", 0
stayInAnalog            byte PX, 23, PY, 23, "Stay in analog mode.", 0
toAnalog                byte PX, 23, PY, 23, "Switched to analog mode.",0
onAnalogButtons         byte PX, 23, PY, 23, "Turned on analog buttons.", 0
offAnalogButtons        byte PX, 23, PY, 23, "Turned off analog buttons.",0
menuDisplay             byte CS, " Press ", 34, "d", 34, " to enter digital mode."
                        byte 13, " Digital mode will turn off the analog buttons."
                        byte 13, " Press ", 34, "a", 34, " to enter analog mode."
                        byte 13, " Press ", 34, "b", 34, " to change to analog button mode."
                        byte 13, " If not all ready in analog mode this option will change"
                        byte 13, " the controller to analog mode." 
                        byte PX, 3, PY, 7, "Mode: Unknown"     
                        byte PX, 15, PY, 9, "   Left             Right  "
                        byte PX, 15, PY, 10,"x:XXX y:XXX      x:XXX y:XXX"
                        byte PX, 3, PY, 12,"Buttons:  Sq   X    O    Tri  R1   L1   R2   L2  "
                        byte PX, 3, PY, 13,"Digital:"
                        byte PX, 3, PY, 14,"Analog: "
                        byte PX, 3, PY, 17,"Buttons:  <    v    >    ^    St   JR   JL   Sel "
                        byte PX, 3, PY, 18,"Digital:"
                        byte PX, 3, PY, 19,"Analog: "
                        byte PX, 3, PY, 21,"Raw: $"
                        byte PX, 3, PY, 22,"All Buttons: %"
                        byte PX, 3, PY, 23, "Last debug message: "     
                        byte PX, 3, PY, 24, "Last action: ", 0    
                        
analogMode              byte PX, 16, PY, 24, "Switch to analog mode.  ", 0                       
digitalMode             byte PX, 16, PY, 24, "Switch to digital mode. ", 0                       
buttonMode              byte PX, 16, PY, 24, "Turn on analog buttons. ", 0                       
analogDisplay           byte PX, 9, PY, 7, "Analog                        ", 0                       
digitalDisplay          byte PX, 9, PY, 7, "Digital                       ", 0                       
configDisplay           byte PX, 9, PY, 7, "Config (this shouldn't happen)", 0                       
unknownDisplay          byte PX, 9, PY, 7, "Unknown                       ", 0
digitalButtonsOnly      byte PX, 35, PY, 7, "Only digital buttons in use.        ", 0 
digitalButtonsAndJoysticks byte PX, 35, PY, 7, "Digital buttons & joysticks in use.", 0
maxData                 byte PX, 35, PY, 7, "Joysticks and analog buttons in use.", 0
unknownData             byte PX, 35, PY, 7, "Unknown data in use.                ", 0

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
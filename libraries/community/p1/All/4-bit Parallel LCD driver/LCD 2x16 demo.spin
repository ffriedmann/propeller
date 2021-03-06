{{┌──────────────────────────────────────────┐
  │ Parallel LCD demo                        │   
  │ Author: Chris Gadd                       │   
  │ Copyright (c) 2013 Chris Gadd            │   
  │ See end of file for terms of use.        │   
  └──────────────────────────────────────────┘

  A short demonstration of my parallel LCD driver using a 2 x 16 display in 4-bit mode
   Full details in LCD driver object
  
}}                   
CON
_clkmode = xtal1 + pll16x                                               
_xinfreq = 5_000_000

'LCD pins
RS_pin   = 23                                           '  RS  - low for commands, high for text 
RW_pin   = 22                                           '  R/W - low for write, high for read    
E_pin    = 21                                           '  E   - clocks the data lines           
D4_pin   = 16                                           '  D4 through D7 must be connected to consecutive pins
'D5      = 17                                           '     with D4 on the low pin 
'D6      = 18
'D7      = 19
                                                                                                     
OBJ
  LCD : "LCD SPIN driver - 2x16"
  _LCD : "LCD PASM driver - 2x16"                        
  
DAT                     org
Top_line                byte      "This LCD driver supports scrolling text",0
Bottom_line             byte      "independently on each line.",0

PUB Main | i
  LCD.start(E_pin,RW_pin,RS_pin,D4_pin)

 LCD.str(string("Hello world!"))                        ' Clear screen and send text
 waitcnt(clkfreq * 2 + cnt)

   LCD.scroll_ind(@Top_line,1)                           ' Scroll a line across the top - no bottom line
   LCD.scroll_ind(@Bottom_line,2)                        ' Scroll a line across the bottom while keeping the top stationary

  waitcnt(clkfreq * 2 + cnt)
  LCD.clear
  LCD.str(string("also blinking"))
  LCD.blink(0)

    
DAT                     
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
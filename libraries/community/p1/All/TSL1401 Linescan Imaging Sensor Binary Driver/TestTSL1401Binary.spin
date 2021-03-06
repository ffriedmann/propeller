CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  AO = 0                   ' Camera Analog Output
  SI = 1                   ' Camera SI
  CLK = 2                  ' Camera clock
  LED = 3

OBJ
     Sio  : "FullDuplexSerialPlus"        
     Ls   : "TSL1401Binary"
VAR                                     '
  byte image[128]               ' image values
  long exp                      ' exposure time in milli seconds
Pub Main   | i
  Initialize
  exp := 100                                                 ' exp milliseconds
  repeat
    Ls.LedOn
    Ls.GetImage(@image, exp)                                 ' Get an image
    Ls.LedOff
    Sio.tx(0)
    Sio.str(@ruler1)                                         ' Print rulers
    Sio.tx(13)    
    Sio.str(@ruler2)
    Sio.tx(13)    
    repeat i from 0 to 127
      Sio.dec(image[i])                                      ' Print image
    Sio.tx(13)    
    Sio.tx(13)
    Sio.dec(Ls.CountPixels(0, 127, Ls#DRK, @image))          ' Count dark
    Sio.tx(9)
    Sio.dec(Ls.CountPixels(0, 127, Ls#BRT, @image))          ' Count light
    Sio.tx(13)
    Sio.dec(LS.FindPixel(0, 127, LS#DRK, LS#FWD, @image))    ' Find dark pixel forward
    Sio.tx(13)
    Sio.dec(LS.FindEdge(0, 127, LS#LTOD, LS#FWD, @image))    ' Find light to dark edge forward
    Sio.tx(9)
    Sio.Dec(Ls.FindEdge(0, 127, LS#LTOD, LS#BKWD, @image))   ' Find light to dark edge backward
    Sio.tx(13)
    Sio.Dec(Ls.FindEdge(0, 127, LS#DTOL, LS#FWD, @image))    ' Find dark to light edge forward
    Sio.tx(13)
    i := LS.FindLine(0, 127, LS#DRK, LS#FWD, @image)         ' Find dark line forward
    Sio.Dec(i >> 16)
    Sio.tx(9)
    Sio.Dec((i & $FF00) >> 8)
    Sio.tx(9)
    Sio.Dec(i & $FF)
    Sio.tx(13)
    i := LS.FindLine(0, 127, LS#DRK, LS#BKWD, @image)         ' Find dark line backward
    Sio.Dec(i >> 16)
    Sio.tx(9)
    Sio.Dec((i & $FF00) >> 8)
    Sio.tx(9)
    Sio.Dec(i & $FF)
    repeat until !Sio.rxcheck                                  ' wait for key from terminal
          
  
PUB Initialize
{{ Initialize the pins direction and state. Must be called once. }}
  Sio.start(31,30,0,115200)  ' Rx,Tx, Mode, Baud
  Ls.Init(AO, SI, CLK, LED)

DAT
        ruler1 byte "          1         2         3         4         5         6         7         8         9        10        11        12", 0
        ruler2 byte "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567", 0

{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │                                       
│                                                                                      │                                      
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │                                         
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}                  
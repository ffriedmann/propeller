''**************************************
''
''  LM9033A Demo Ver. 00.1
''
''  Timothy D. Swieter, E.I.
''  www.brilldea.com
''
''  Copyright (c) 2008 Timothy D. Swieter, E.I.
''  See end of file for terms of use.
''
''  Updated: November 20, 2008
''
''Description:
''      This program is a demo for the LM9033A Graphics LCD from Brilldea.
''      The LM9033A is a 128 x 96 pixel LCD.  The display is monochrome but
''      can display four different gray levels.
''
''Reference:
''      Brilldea's LM9033A Driver
''
''Revision Notes:
'' 0.1 Begin Coding
''
''**************************************
CON               'Constants to be located here
'***************************************                       

  '***************************************
  ' Processor Settings
  '***************************************
  _clkmode = xtal1 + pll16x     'Use the PLL to multiple the external clock by 16
  _xinfreq = 5_000_000          'An external clock of 5MHz. is used (80MHz. operation)

  '***************************************
  ' System Definitions     
  '***************************************

  _OUTPUT       = 1             'Sets pin to output in DIRA register
  _INPUT        = 0             'Sets pin to input in DIRA register  
  _HIGH         = 1             'High=ON=1=3.3v DC
  _ON           = 1
  _LOW          = 0             'Low=OFF=0=0v DC
  _OFF          = 0
  _ENABLE       = 1             'Enable (turn on) function/mode
  _DISABLE      = 0             'Disable (turn off) function/mode

  '***************************************
  ' I/O Definitions
  '***************************************
  
  'LM9033A LCD
  _LCD_cs       = 5             'LCD chip select
  _LCD_rst      = 4             'LCD reset
  _LCD_rs       = 3             'LCD register select
  _LCD_sc       = 2             'LCD serial clock
  _LCD_sd       = 1             'LCD serial data
  _LCD_bl       = 0             'LCD backlight, note this is inverted output, when on, BL is off because of PNP transistor.
  
  '***************************************
  ' GUI Definitions
  '***************************************

  'screen sizing constants for 128 x 96 display
  _xtiles       = 8                                     'Each time is 16 pixels x 16 pixels
  _ytiles       = 6                                     'Each tile requires 16 longs
  _screenSize   = (_xtiles * _ytiles * 16)              'Size needed for video memory array

  '***************************************
  ' Misc Definitions
  '***************************************

  'none


'**************************************
VAR               'Variables to be located here
'***************************************

  'LCD display memory arrays
  long  VIDEOmemory[_screenSize]
  long  LCDmemory[_screenSize]

  
'***************************************
OBJ               'Object declaration to be located here
'***************************************

  LCD   : "Brilldea-LM9033A Driver-Ver002.spin"         'Brilldea LCD driver
  Gr    : "graphics.spin"                               'Parallax graphics driver

'***************************************
PUB main | t0, i, k, numx, numchr 'The first PUB in the file is the first one executed
'***************************************


  '**************************************
  ' Initialize the hardware
  '**************************************

  'none                                
  
  '**************************************
  ' Initialize the variables
  '**************************************

  'Initialize variables for screen animations
  i := 1001
  k := 8776434                                                                                         

  '**************************************
  ' Start the processes in their cogs
  '**************************************

  'Start the LCD driver
  LCD.start(_LCD_cs, _LCD_rst, _LCD_rs, _LCD_sc, _LCD_sd, _LCD_bl)

  'Start the graphics driver with its own memory for double buffered
  'animation.  The graphics driver draws in VIDEOmemory.  It only copies
  'it to LCDmemory after it has completed drawing.  The LCD driver
  'can be used with a single buffer or a double buffer.
  gr.start
  gr.setup(_xtiles, _ytiles, 0, 0, @VIDEOmemory)
  
  '**************************************
  ' Begin
  '**************************************

  'First step is to initialize the LCD and set the LCD orientation
  'as well as the initial image (usually blank)
  LCD.reset
  LCD.initialize(1, @LCDmemory)

  'Infinite loop
  repeat

    'Set the backlight to stay off
    LCD.backlight(255)

    'Clear the video memory
    gr.clear

    'Display the logo text
    displayLogo

    'Copy video memory to LCD memory and update the display
    gr.copy(@LCDmemory)
    LCD.screenUpdate(0,@LCDmemory)

    'Wait for a second
    PauseMSec(1000)

'-------------------------------
    gr.color(3)
    gr.textmode(1,1,6,4)
    gr.width(0)
    gr.text(63,40,@TXTbl)

    'Copy video memory to LCD memory and update the display
    gr.copy(@LCDmemory)
    LCD.screenUpdate(0,@LCDmemory)

    repeat t0 from 255 to 0
      LCD.backlight(t0)
      PauseMSec(25)

    'vary the backlight
    repeat t0 from 0 to 255
      LCD.backlight(t0)
      PauseMSec(25)

    'Wait a moment
    PauseMSec(500)
'-------------------------------
    'Clear the video memory
    gr.clear

    'Display the logo text
    displayLogo
    
    gr.color(3)
    gr.textmode(1,1,6,4)
    gr.width(0)
    gr.text(63,40,@TXTcont)

    'Copy video memory to LCD memory and update the display
    gr.copy(@LCDmemory)
    LCD.screenUpdate(0,@LCDmemory)

    PauseMSec(500)

    'vary the contrast
    repeat t0 from 32 to 0
      LCD.contrast(t0)
      PauseMSec(100)
    
    'vary the contrast
    repeat t0 from 0 to 63
      LCD.contrast(t0)
      PauseMSec(100)

    'vary the contrast
    repeat t0 from 63 to 32
      LCD.contrast(t0)
      PauseMSec(100)

    'Wait a moment
    PauseMSec(500)
'-------------------------------
    'Clear the video memory
    gr.clear

    'Display the logo text
    displayLogo
    
    gr.color(3)
    gr.textmode(1,1,6,4)
    gr.width(0)
    gr.text(63,40,@TXTinv)

    'Copy video memory to LCD memory and update the display
    gr.copy(@LCDmemory)
    LCD.screenUpdate(0,@LCDmemory)

    'Inverse the display
    repeat 5
      LCD.displayInv(1)
      PauseMSec(1000)
      LCD.displayInv(0)
      PauseMSec(1000)

    'Wait a moment
    PauseMSec(500)
'-------------------------------
    'Clear the video memory
    gr.clear

    'Display the logo text
    displayLogo
    
    gr.color(3)
    gr.textmode(1,1,6,4)
    gr.width(0)
    gr.text(63,40,@TXTforce)

    'Copy video memory to LCD memory and update the display
    gr.copy(@LCDmemory)
    LCD.screenUpdate(0,@LCDmemory)

    'Display force
    repeat 5
      LCD.displayForce(1)
      PauseMSec(1000)
      LCD.displayForce(0)
      PauseMSec(1000)

    'Wait a moment
    PauseMSec(500)
    
'-------------------------------
    'Clear the video memory
    gr.clear

    'Display the logo text
    displayLogo
    
    gr.color(3)
    gr.textmode(1,1,6,4)
    gr.width(0)
    gr.text(63,40,@TXTgray)

    gr.color(0)        
    gr.box(0,0, 30, 32)

    gr.color(1)        
    gr.box(32,0, 30, 32)

    gr.color(2)        
    gr.box(64,0, 30, 32)

    gr.color(3)        
    gr.box(96,0, 30, 32)

    'Copy video memory to LCD memory and update the display
    gr.copy(@LCDmemory)
    LCD.screenUpdate(0,@LCDmemory)

    PauseMSec(2000)

    'Set gray level
    repeat t0 from 0 to 15
      LCD.setGrayLevel(1,t0)
      PauseMSec(400)

    LCD.setGrayLevel(1,5)

    'Set gray level
    repeat t0 from 0 to 15
      LCD.setGrayLevel(2,t0)
      PauseMSec(400)

    LCD.setGrayLevel(2,10)

    'Set gray level
    repeat t0 from 0 to 15
      LCD.setGrayLevel(3,t0)
      PauseMSec(400)

    LCD.setGrayLevel(3,15)


    'Wait a moment
    PauseMSec(5000)
'-------------------------------
    repeat 500

      gr.clear       

      'draw spinning triangles
      gr.colorwidth(3,0)
      repeat i from 1 to 8
        gr.vec(64, 64, (k & $7F) << 3 + i << 5, k << 6 + i << 8, @vecdef)

      'draw expanding pixel halo
      gr.colorwidth(2,k)
      gr.arc(48,32,80,30,-k<<5,$2000/9,9,0)

      'draw incrementing digit
      if not ++numx & 7
        numchr++
      if numchr < "0" or numchr > "9"
        numchr := "0"
      gr.textmode(8,8,6,5)
      gr.colorwidth(3,8)
      gr.text(64,50,@numchr)
      
      'draw small box with text
      gr.colorwidth(2,1)
      gr.box(0,0,128,12)
      gr.textmode(1,1,6,5)
      gr.colorwidth(1,0)
      gr.text(64,5,@TXTdual)
      
      'Copy video memory to LCD memory and update the display
      gr.copy(@LCDmemory)
      LCD.screenUpdate(0,@LCDmemory)

      k++

    repeat 500

      gr.clear       

      'draw spinning triangles
      gr.colorwidth(3,0)
      repeat i from 1 to 8
        gr.vec(64, 64, (k & $7F) << 3 + i << 5, k << 6 + i << 8, @vecdef)

      'draw expanding pixel halo
      gr.colorwidth(2,k)
      gr.arc(48,32,80,30,-k<<5,$2000/9,9,0)

      'draw incrementing digit
      if not ++numx & 7
        numchr++
      if numchr < "0" or numchr > "9"
        numchr := "0"
      gr.textmode(8,8,6,5)
      gr.colorwidth(3,8)
      gr.text(64,50,@numchr)

      'draw small box with text
      gr.colorwidth(2,1)
      gr.box(0,0,128,12)
      gr.textmode(1,1,6,5)
      gr.colorwidth(1,0)
      gr.text(64,5,@TXTsing)
      
      'Ensure the graphics are done be drawn
      'Then update the LCD direct from the memory being
      'drawn into by graphics.
      gr.finish
      LCD.screenUpdate(1,@VIDEOmemory)

      k++

'***************************************
PRI displayLogo
'***************************************

    'Setup a screen with the logo
    gr.color(3)
    gr.textmode(2,2,6,4)
    gr.width(0)
    gr.text(63,67,@TXTlogo)
    gr.width(0)
    gr.plot(5,73)
    gr.line(122,73)

    gr.textmode(1,1,6,4)
    gr.width(0)
    gr.text(63,58,@TXTdrv)
  

'***************************************
PRI pauseMSec(Duration)
'***************************************
'' Pause execution in milliseconds.
'' Duration = number of milliseconds to delay
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)
  

'***************************************
DAT
'***************************************

TXTlogo       byte      "Brilldea",0
TXTdrv        byte      "LM9033A Driver",0
TXTbl         byte      ".backlight function",0
TXTcont       byte      ".contrast function",0
TXTinv        byte      ".displayInv function",0
TXTforce      byte      ".displayForce funct",0
TXTgray       byte      ".setGrayLevel funct",0
TXTdual       byte      "DUAL Buffer/Parallel",0
TXTsing       byte      "SINGLE Buffer/Series",0

vecdef                  word    $4000+$2000/3*0         'triangle
                        word    50
                        word    $8000+$2000/3*1+1
                        word    50
                        word    $8000+$2000/3*2-1
                        word    50
                        word    $8000+$2000/3*0
                        word    50
                        word    0
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
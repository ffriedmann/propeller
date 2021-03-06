{{
***************************************
*        SOMO14D Demo V1.0            *
* Author:  Gary Campbell              *
* Copyright (c) 2012 Gary Campbell    *
* See end of file for terms of use.   *    
* Started: 06-26-2012                 *
***************************************

Demonstrates the 4dsystems SOMO-14D Embedded Audio Module.
See www.4dsystems.com.au for details.

Connection To Propeller is 4 pins...
          
        ┌──────────┐
        │ Propeller│
   ┌────┤P0(BUSY)  │      
   │┌───┤P1(DATA)  │       2GB microSD card
   ││┌──┤P2(CLK)   │       formatted FAT16
   │││┌─┤P3(RESET) │    
   ││││ └──────────┘  
   │││└──────────────┐
   │││  ┌─────────┐  │
   │││  ┤•┌ •├──┼──Optional AUDIO Out
   │││  ┤•│     │•├  │
   ││└──┤•│     │•├──┼──Speaker 8/16/32 Ohm 
   │└───┤•│     │•├──┼───┘        0.25W
   ┣────┤•└─────┘•├──┘
   │    ┤• SOMO  •├───┐
   │    ┤•  14D  •├─┐  VCC (3.3v nominal)
   │    └─────────┘ │   
   └─────┐  ┌──┻───┘
       470Ω      + 220uF/16V

--------------------------REVISION HISTORY--------------------------
 v1.1 - Updated mm/dd/yyyy to change ...bla, bla, bla
 
}}
CON

  _clkmode      = xtal1 + pll16x
  _clkfreq      = 80_000_000

  BUSYPin   = 0
  DATAPin   = 1
  CLKPin    = 2
  RESETPin  = 3

  NUMBER_OF_FILES    = 6    ' Play this many files
  NUMBER_OF_REPEATS  = 1    ' Play all files this many times

  ERROR_DISPLAY_DELAY_S = 2 ' Number of seconds to display an error message


OBJ

  SOMO       : "SOMO14D"
  Term       : "FullDuplexSerial"

VAR

  byte ProgramIsDone   ' lets the menu signal when user selects "EXIT"

PUB Main

  Term.Start(31, 30, 0, 9_600)
  SOMO.Init(BUSYPin, DATAPin, CLKPin, RESETPin)
  SOMO.ResetDevice

  waitcnt(clkfreq * 5 + cnt)   ' Wait for user to connect the serial terminal
  
  ProgramIsDone := False
  repeat until ProgramIsDone
    DisplayMenu
    GetMenuChoice
        
PRI WaitForFileToPlay

  if SOMO.GetBusy == 0
    Term.str(string("NOT Busy", 13))
    waitpeq(|< BUSYPin, |< BUSYPin, 0)
    Term.str(string("BUSY", 13))
    waitpeq(0, |< BUSYPin, 0)
    Term.str(string("NOT Busy", 13))
    result := TRUE
  else
    Term.str(string("BUSY and should not be... ERROR", 13))
    abort FALSE

PRI DisplayMenu

  Term.str(string(16,"SOMO-14D DEMONSTRATION PROGRAM",13))
  Term.str(string("---- M E N U ----",13))
  Term.str(string("0) Select File",13))
  Term.str(string("1) Reset", 13))
  Term.str(string("2) Stop",13))
  Term.str(string("3) Play/Pause",13))
  Term.str(string("4) Set Volume",13))
  Term.str(string("5) EXIT",13))
  Term.str(string("Enter your choice now: "))

PRI GetMenuChoice

  case GetSelection
    0: SelectFile
    1: SOMO.ResetDevice
    2: SOMO.Stop
    3: SOMO.PlayPauseToggle
    4: SelectVolume
    5:
      Term.str(string(13,"Good bye :-)", 13))
      SOMO.ResetDevice
      ProgramIsDone := True
    OTHER:
      Term.str(string("<< UNKNOWN SELECTION >>"))
      ErrorDisplayDelay

PRI SelectFile | FileNo

  Term.str(string("Enter a file number (0,1,2,3,4,5)... "))
  FileNo := GetSelection
  case FileNo
    0..5: SOMO.PlayAudioFile(FileNo)
    OTHER:
      Term.str(string("<< INVALID FILE NUMBER >>"))
      ErrorDisplayDelay

PRI SelectVolume | Level

  Term.str(string("Enter a volume (0,1,2,3,4,5,6,7)... "))
  Level := GetSelection
  case Level
    0..7: SOMO.SetVolume(Level)
    OTHER:
      Term.str(string("<< INVALID VOLUME LEVEL >>"))
      ErrorDisplayDelay

PRI GetSelection | Choice

  Choice := Term.rx
  Term.str(string(13))
  if (Choice => ("0")) and (Choice =< ("9"))
    Choice -= "0"
  else
    Choice := -1
  return(Choice)

PRI ErrorDisplayDelay

  waitcnt(clkfreq * ERROR_DISPLAY_DELAY_S + cnt)

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
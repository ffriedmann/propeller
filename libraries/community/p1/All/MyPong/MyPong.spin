{{

┌──────────────────────────────────────────┐
│ MyPong V1.0                              │
│ Author: <Jim Salvino>                    │               
│ Copyright (c) 2009 Jim Salvino           │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

Simple pong game demo using the TV_Text_Half_Height object

The user interface consists of two push buttons, one for
each hand. The left hand push button is connected to pin 26.
The right hand push button is connected to pin 27. The push
buttons are wired up such that normally open is a logic 1 and
normally colsed is a logic 0.

}}


CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

VAR
  byte  sp_x
  byte  sp_y
  
  byte  bp_x
  byte  bp_y
  byte  bp_dir
  
  long  delta_x
  long  delta_y
  
  byte  hitctr
  
OBJ

  text : "TV_Text_Half_Height"
  

PUB start

  ' set pins 27 & 26 to inputs
  DIRA[27]~
  DIRA[26]~
    
  text.start(12,0,1,40,24)

  ' initial ball direction   
  bp_dir := 1
  
 repeat
       
    hitctr := 0
  
    ' setup initial positions
    sp_x := 17
    sp_y := 20

    bp_x := 17
    bp_y := 10
    
    drawfield   
    drawstick(sp_x, sp_y)
    drawball(bp_x, bp_y)
  
    ' wait until either button is pushed
    repeat until INA[27] == 0 OR INA[26] == 0
        
    repeat
      
      if INA[26] == 0
        clear(sp_x, sp_y)
        sp_x := sp_x - 1 #> 0 
        drawstick(sp_x, sp_y)
      
      if INA[27] == 0
        clear(sp_x, sp_y)
        sp_x := sp_x + 1 <# 34
        drawstick(sp_x, sp_y)
      
      clear(bp_x, bp_y)
    
    ' bp_dir 1 = upward, right (inc x, dec y)
    ' bp_dir 2 = upward, left (dec x, dec y)
    ' bp_dir 3 = downward, right (inc x, inc y)
    ' bp_dir 4 = downward, left (dec x, inc y)
      case bp_dir
        1:
          bp_x++
          bp_y--
        2:
          bp_x--
          bp_y--
        3:
          bp_x++
          bp_y++
        4:
          bp_x--
          bp_y++
         
      if bp_x == 0
        if bp_dir == 2
          bp_dir := 1
        if bp_dir == 4
          bp_dir := 3
        
      if bp_x == 34
        if bp_dir == 1
          bp_dir := 2
        if bp_dir == 3
          bp_dir := 4
        
      if bp_y == 0
        if bp_dir == 1
          bp_dir := 3
        if bp_dir == 2
          bp_dir := 4
        
      if bp_y == 20

        delta_x := ||(bp_x - sp_x)
        delta_y := ||(bp_y - sp_y)
        
        if delta_x =< 1 AND delta_y =< 1
          if ++hitctr == 5
            quit                      
          if bp_dir == 4
             bp_dir := 2
          if bp_dir == 3
             bp_dir := 1
        else
           quit
                                             
      drawball(bp_x, bp_y)
    
      waitcnt(cnt + 4_000_000)

    text.out($0A)
    text.out(13)
    text.out($0B)
    text.out(10)
    
    if hitctr == 5
      text.str(string("You  WIN!"))
    else  
      text.str(string("You LOSE!"))
  
    waitcnt(cnt + 160_000_000)
  
   
          
  
PRI drawstick(pos_x, pos_y)

  ' draw the stick at a certain x,y coordinate
  text.out($0A)
  text.out(pos_x)
  text.out($0B)
  text.out(pos_y)
  text.out($0E)
  
PRI drawball(pos_x, pos_y)

  ' draw the ball at a certain x,y coordinate
  text.out($0A)
  text.out(pos_x)
  text.out($0B)
  text.out(pos_y)
  text.out($0F)
    
PRI clear(pos_x, pos_y)

  ' clear this x,y coordinate with a space or with field char
  text.out($0A)
  text.out(pos_x)
  text.out($0B)
  text.out(pos_y)
  if pos_y == 0
    text.out($90)
  elseif pos_x == 0 OR pos_x == 34
    text.out($91)
  else  
    text.out($20)
   
PRI drawfield | i

  ' clear the screen
  text.out($00)
  
  ' draw the playing field 
  repeat i from 1 to 33
    text.out($0A)
    text.out(i)
    text.out($0B)
    text.out($00)
    text.out($90)
 
  repeat i from 1 to 20
    text.out($0A)
    text.out($00)
    text.out($0B)
    text.out(i)
    text.out($91)
 
  repeat i from 1 to 20
    text.out($0A)
    text.out($22)  
    text.out($0B)
    text.out(i)
    text.out($91)
    
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
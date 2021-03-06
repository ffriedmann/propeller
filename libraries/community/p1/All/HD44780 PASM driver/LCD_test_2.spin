con
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000

  LCDBasePin    = 8
  LEDOnPin      = 255

{{
HOW TO USE:
===========
Attach a 16x2 display to the propeller and change the base pin constant above accordingly.
If you have connected the backlight for example to a FET that switches on the backlight,
then you can use LEDOnPin to switch it on, otherwise keep the value and no pin will
be switched on.


For understanding the CMD_INSTR, please find a list of display instructions in the driver.
}}

obj
  LCD: "BenkyLCDdriver"
  PWM: "PWM_32_v2"          ' this was used to fade the backlight
  
var
  long counter
  long onoff
  long maxT

dat
  scrbuf1 byte " "[16],0   
  scrbuf2 byte " "[16],0   

pub main | i
  ' if LEDOnPin is a valid pin number, set to output a 1 (enable LED) 
  if LEDOnPin < 31
    outa[ LEDOnPin ] := 1 
    dira[ LEDOnPin ] := 1

  onoff := 0

  LCD.start( LCDBasePin,0 )

  maxT:=LCD.getMax

  ' Init some special characters
  LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
  LCD.exec( LCD#CMD_SETCHAR, @char1 )  ' Power plug
  LCD.exec( LCD#CMD_SETCHAR, @char2 )  ' Rails

{{
  FadeIn
  printTestTitle( string("Show all chars") )
  repeat
    LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
    LCD.exec( LCD#CMD_SETCHAR, @char1 )  ' Power plug
    LCD.exec( LCD#CMD_SETCHAR, @char1+8 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+16 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+24 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+32 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+40 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+48 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+56 )  ' Rails
    LCD.exec( LCD#CMD_INSTR, %10000000 ) ' this sets the 'cursor' position
    LCD.exec( LCD#CMD_PRINT, @inter1 )
    LCD.exec( LCD#CMD_INSTR, %10000000 ) ' this sets the 'cursor' position
    waitcnt( clkfreq/30+cnt )   
    LCD.exec( LCD#CMD_PRINT, @leerst )
    LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
    LCD.exec( LCD#CMD_SETCHAR, @char1+64 )  ' Power plug
    LCD.exec( LCD#CMD_SETCHAR, @char1+72 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+80 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+88 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+96 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+104 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+112 )  ' Rails
    LCD.exec( LCD#CMD_SETCHAR, @char1+120 )  ' Rails
    LCD.exec( LCD#CMD_INSTR, %10000000 + $40 ) ' this sets the 'cursor' position
    LCD.exec( LCD#CMD_PRINT, @inter1 )
    waitcnt( clkfreq/30+cnt )   
    LCD.exec( LCD#CMD_INSTR, %10000000 + $40 ) ' this sets the 'cursor' position
    LCD.exec( LCD#CMD_PRINT, @leerst )
}}    
{{

  LCD.exec( LCD#CMD_INSTR, %10000000 ) ' this sets the 'cursor' position
  LCD.exec( LCD#CMD_SETBLINK, $1<<24 + $20<<16 + 1<<8 + 2 ) 
}}
{{
  LCD.exec( LCD#CMD_INSTR, %10000000 ) ' this sets the 'cursor' position
  LCD.exec( LCD#CMD_SETLEN, 16<<16 + 16 )
'  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1 + string("                0123456789012345") )
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE2 + $40<<16 + string("0123456789012345                ") )

  waitcnt( clkfreq*10+cnt )
  repeat i from 10000 to 1000000 step 1000
    LCD.exec( LCD#CMD_SETRATE, i )
    waitcnt( clkfreq+cnt ) 
}}
    
repeat
  hex( LCD.getAdrNSize, 8 )
  hex( maxT, 8 )
  ' show the size and address of the PASM driver
  printTestTitle( string("PASM size/adr") )
  LCD.exec( LCD#CMD_INSTR, %10000000 + $40) ' this sets the 'cursor' position
  LCD.exec( LCD#CMD_PRINT, @text3 )   

  if onoff==0
    FadeIn
    onoff:=1
  waitcnt( clkfreq*5+cnt )


  ' show all characters of the display
  printTestTitle( string("Show all chars") )
  i:=0
  repeat until i == 256
    if (i//32) == 0
      LCD.exec( LCD#CMD_INSTR, %10000000 ) ' this sets the 'cursor' position
    if (i//32) == 16
      LCD.exec( LCD#CMD_INSTR, %10000000 + $40) ' this sets the 'cursor' position
    LCD.exec( LCD#CMD_WRITE, i )
    if (i//32) == 31
      waitcnt( clkfreq*5+cnt)
    i++
{{
  printTestTitle( string("Scrolling     ") )
  ' This code creates a scrolling headline
  LCD.exec( LCD#CMD_SETRATE, 300000 )  ' make it a bit faster 
  LCD.exec( LCD#CMD_INSTR, %10000000 ) ' set display RAM to line 1
  LCD.exec( LCD#CMD_PRINT, @text6 )    ' output the framing characters of headline
  LCD.exec( LCD#CMD_SETLEN, 1<<16 + 10 )       ' set the size of the scrolling area
  '                          select line     offset  text-buffer
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1 + 3<<16 + @longt )
  waitcnt( clkfreq*30+cnt )
  LCD.exec( LCD#CMD_SETRATE, 1000000 ) 
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1  ) ' stop the scrolling line

  printTestTitle( string("blnk scrl shft") )
  ' This writes "4 lines" on a 4x16 row display. For a 2x16 display it's
  ' like having 2 independent screens
  LCD.exec( LCD#CMD_INSTR, %10000000 ) ' set display RAM address to 0 ( line 1 )
  LCD.exec( LCD#CMD_PRINT, @text )     ' and write the first text
  LCD.exec( LCD#CMD_INSTR, ( %10000000 + $40 ) ) ' set display RAM to line 2
  LCD.exec( LCD#CMD_PRINT, @text2 )
  LCD.exec( LCD#CMD_INSTR, %10000000 + 16 ) ' set display RAM to hidden part of line 1
  LCD.exec( LCD#CMD_PRINT, @text4 )
  LCD.exec( LCD#CMD_INSTR, ( %10000000 + $40 +16 ) ) ' ... hidden part line 2
  LCD.exec( LCD#CMD_PRINT, @text5 )

  ' activate 2 blinking characters
  LCD.exec( LCD#CMD_INSTR, %10000000 + $4e ) ' set the position
  '                           char1    char2     slot   blink-rate
  LCD.exec( LCD#CMD_SETBLINK, $0<<24 + $20<<16 + 0<<8 + 5 ) 
  LCD.exec( LCD#CMD_INSTR, %10000000 + $4f )
  LCD.exec( LCD#CMD_SETBLINK, $1<<24 + $20<<16 + 1<<8 + 2 ) 
  waitcnt( clkfreq*30+cnt )

  ' change the general blink-rate
  LCD.exec( LCD#CMD_SETRATE, 500000 ) 
  waitcnt( clkfreq*30+cnt )
  ' LCD.exec( LCD#CMD_SETRATE, 1000000 ) 

  ' in this loop the display is shifted to the hidden part (2x16 display)
  ' for other displays this looks weird
  repeat 2

    ' this part prints the hexadecimal number
    repeat 100
      waitcnt(cnt+clkfreq/20)
      LCD.exec( LCD#CMD_INSTR, ( %10000000 + $45 ) )
      LCD.exec( LCD#CMD_PRINT, @text3 )
      hex( counter++, 8 )
     
    ' shift to the left
    ' please note that you don't have to take care of the blinking
    ' characters. These stay at the 1st screen
    LCD.exec( LCD#CMD_SHIFT, 16 )
     
    ' this part prints the hexadecimal number
    repeat 100
      waitcnt(cnt+clkfreq/20)
      LCD.exec( LCD#CMD_INSTR, ( %10000000 + $55 ) )
      LCD.exec( LCD#CMD_PRINT, @text3 )
      hex( counter++, 8 )
     
    ' shift to the left
    LCD.exec( LCD#CMD_SHIFT, %10000000 + 16 )
}}
  printTestTitle( string("Alter text   ") )
  LCD.exec( LCD#CMD_SETRATE, 10_000_000 ) 
  LCD.exec( LCD#CMD_SETLEN, 16<<16 + 16 )
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1 + @alt )
  waitcnt( clkfreq*50+cnt )
  LCD.exec( LCD#CMD_SETRATE, 1000000 ) 

  ' Here we have 2 lines that scroll automatically ... could be as long as HUB RAM ;o)
  LCD.exec( LCD#CMD_SETLEN, 1<<16 + 16 )
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1 + @longt )
  ' choose this one for 2nd row of a 2x16 display
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE2 + $40<<16 + string("Bla bla Blubber di blubb da ding dada dadum horido blubberdiblubb! ") )
  ' choose this one for 1st row of second screen if it's a 2x16
  ' you can also see that the blinking characters still blink
  'LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE2 + $10<<16 + string("Bla bla Blubber di blubb da ding dada dadum horido blubberdiblubb! ") )
  waitcnt( clkfreq*30+cnt )
{{
  ' here we switch the screens again. As you can see the texts still scroll on both screens.
  repeat 2

    ' this part prints the hexadecimal number
    repeat 100
      waitcnt(cnt+clkfreq/20)
      LCD.exec( LCD#CMD_INSTR, ( %10000000 + $45 ) )
      LCD.exec( LCD#CMD_PRINT, @text3 )
      hex( counter++, 8 )
     
    ' shift to the left
    ' please note that you don't have to take care of the blinking
    ' characters. These stay at the 1st screen
    LCD.exec( LCD#CMD_SHIFT, 16 )
     
    ' this part prints the hexadecimal number
    repeat 100
      waitcnt(cnt+clkfreq/20)
      LCD.exec( LCD#CMD_INSTR, ( %10000000 + $55 ) )
      LCD.exec( LCD#CMD_PRINT, @text3 )
      hex( counter++, 8 )
     
    ' shift to the left
    LCD.exec( LCD#CMD_SHIFT, %10000000 + 16 )
}}
  ' stop scrolling lines
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1  )
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE2  )
  ' as you don't know where you stopped the string, you should overwrite
  LCD.exec( LCD#CMD_INSTR, %10000000 + $40 ) ' set display RAM to line 2
  LCD.exec( LCD#CMD_PRINT, @text2 )
  LCD.exec( LCD#CMD_INSTR, %10000000 ) ' set display RAM address to 0 ( line 1 )
  LCD.exec( LCD#CMD_PRINT, @text )     ' and write the first text
{{
  waitcnt( clkfreq*30+cnt )

  ' stop blinking character 1 ... won't delete whatever currently is displayed   
  LCD.exec( LCD#CMD_SETBLINK, 0<<8  )
  ' so you should take care that the character is fine
  LCD.exec( LCD#CMD_INSTR, %10000000 + $4e )
  LCD.exec( LCD#CMD_WRITE, 0 )
  waitcnt( clkfreq*5+cnt )

  ' and stop blinking char 2 
  LCD.exec( LCD#CMD_SETBLINK, 1<<8  )
  LCD.exec( LCD#CMD_INSTR, %10000000 + $4f )
  LCD.exec( LCD#CMD_WRITE, 1 )
}}
  printTestTitle( string("Progress bar  ") )
  ' show a progress-bar
  ' 10*5 = 50 => 100%
  LCD.exec( LCD#CMD_INSTR, %10000000 + $40) ' set display RAM to line 1
  repeat 16
    LCD.exec( LCD#CMD_WRITE, 32 )

  repeat 10  
    repeat i from 0 to 100
      printBar( i )
      waitcnt( clkfreq/500+cnt )    
    repeat i from 100 to 0
      printBar( i )
      'waitcnt( clkfreq/10+cnt )    
  LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
  LCD.exec( LCD#CMD_SETCHAR, @char1 )  ' Power plug   

  printTestTitle( string("as Screenbuf  ") )
  LCD.exec( LCD#CMD_SETRATE, 5000 ) 
  LCD.exec( LCD#CMD_SETLEN, 16 )       ' set the size of the scrolling area
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1 + @scrbuf1 )
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE2 + $40<<16 + @scrbuf2 )
  repeat i from 0 to 15
    scrbuf1[i]:="a"+ (tnum//26)
    scrbuf2[15-i]:="z" - (tnum//26)
    waitcnt( clkfreq+cnt )
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE1 )
  LCD.exec( LCD#CMD_SETLINE, LCD#PAR_LINE2 )
  LCD.exec( LCD#CMD_SETRATE, 1000000 )

  maxT:=LCD.getMax
  hex( maxT, 8 )
  ' show the size and address of the PASM driver
  printTestTitle( string("PASM size/adr") )
  LCD.exec( LCD#CMD_INSTR, %10000000 + $40) ' this sets the 'cursor' position
  LCD.exec( LCD#CMD_PRINT, @text3 )   
  waitcnt( clkfreq*5+cnt)

  FadeOut
  onoff:=0
  waitcnt( clkfreq*5+cnt ) 
{{
  printTestTitle( string("Done!!        ") )
  repeat
    waitcnt(cnt+clkfreq/20)
    LCD.exec( LCD#CMD_INSTR, ( %10000000 + $45 ) )
    LCD.exec( LCD#CMD_PRINT, @text3 )
    hex( counter++, 8 )
}}

pub FadeIn | DutyCycle
  PWM.Start                     '' Initialize PWM cog
  
  repeat DutyCycle from 0 to 100
    PWM.Duty(4,DutyCycle,5000) '' Ramp Duty cycle up from 0 to 100                        
    repeat ((1000001-DutyCycle*DutyCycle*DutyCycle)/100)

  outa[4]:=1
  PWM.Stop
   
pub FadeOut | DutyCycle
  PWM.Start                     '' Initialize PWM cog

  outa[4]:=0
  
  repeat DutyCycle from 100 to 0
    PWM.Duty(4,DutyCycle,5000) '' Ramp Duty cycle up from 0 to 100                        
    repeat (10000-DutyCycle*50)

  PWM.Stop

PUB printTestTitle( s )
  tnum++
  LCD.exec( LCD#CMD_INSTR, %10000000 )
  printDec( tnum )
  LCD.exec( LCD#CMD_WRITE, ":" ) 
  LCD.exec( LCD#CMD_PRINT, s )
  LCD.exec( LCD#CMD_INSTR, %10000000 + $40)
  LCD.exec( LCD#CMD_PRINT, @leer )
  waitcnt( clkfreq*3 + cnt ) 

dat
  tnum byte 0
    
PUB printDec( val ) | i
  i:=10
  if val>0
    repeat while val<>0
      i--
      num[i]:="0"+val//10
      val:=val/10
  else
    LCD.exec( LCD#CMD_WRITE, "0" )

  LCD.exec( LCD#CMD_PRINT, @num+i )
  
dat
num byte 0[11]  
    
PUB printBar( percentage ) | full, empty, part, pos
  pos:=0
  LCD.exec( LCD#CMD_INSTR, %10000000 + $40 )
  full := percentage/10
  repeat full
    LCD.exec( LCD#CMD_WRITE, 255 )
    pos++

  part := (percentage//10)>>1
  case part
    0:
      LCD.exec( LCD#CMD_WRITE, 32 )
    1:
      LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
      LCD.exec( LCD#CMD_SETCHAR, @bar1 )  ' Power plug
      
      LCD.exec( LCD#CMD_INSTR, %10000000 + $40 + pos )
      LCD.exec( LCD#CMD_WRITE, 0 )
    2:
      LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
      LCD.exec( LCD#CMD_SETCHAR, @bar2 )  ' Power plug
      
      LCD.exec( LCD#CMD_INSTR, %10000000 + $40 + pos )
      LCD.exec( LCD#CMD_WRITE, 0 )
    3:
      LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
      LCD.exec( LCD#CMD_SETCHAR, @bar3 )  ' Power plug
      
      LCD.exec( LCD#CMD_INSTR, %10000000 + $40 + pos )
      LCD.exec( LCD#CMD_WRITE, 0 )
    4:
      LCD.exec( LCD#CMD_INSTR, %01000000 ) ' set the character RAM address to 0
      LCD.exec( LCD#CMD_SETCHAR, @bar4 )  ' Power plug
      
      LCD.exec( LCD#CMD_INSTR, %10000000 + $40 + pos )
      LCD.exec( LCD#CMD_WRITE, 0 )
    
  empty := ((100-percentage) / 10 - 1) #>0
  repeat empty
    LCD.exec( LCD#CMD_WRITE, 32 )

  LCD.exec( LCD#CMD_INSTR, %10000000 + $4b )
  LCD.exec( LCD#CMD_PRINT, string("   "))
  if percentage==100
    LCD.exec( LCD#CMD_INSTR, %10000000 + $4b )
  else
    if  percentage<10
      LCD.exec( LCD#CMD_INSTR, %10000000 + $4d )
    else
      LCD.exec( LCD#CMD_INSTR, %10000000 + $4c )

  printDec( percentage )
  LCD.exec( LCD#CMD_WRITE, "%" )
     
PUB hex(value, digits) | blubb

  value <<= (8 - digits) << 2
  repeat blubb from 0 to digits-1
    byte[@text3+blubb]:=lookupz((value <-= 4) & $F : "0".."9", "A".."F")

dat
{{
mainmenu word @mm_entry1, @mm_entry2, @mm_entry3, @mm_entry4, @mm_entry5, @mm_entry6, 0
 
submenu1 word @s1_entry1, @s1_entry2, 0
submenu2 word @s2_entry1, @s2_entry2, @s2_entry3, 0

subsub1_1 word @s1_2_entry1, @s1_2_entry2, 0
 
mm_entry1  word @submenu1
           byte "mm entry 1 text",0
mm_entry2  word @submenu2
           byte "mm entry 2 text",0
mm_entry3  word 0
           byte "mm entry 3 text",0
mm_entry4  word 0
           byte "mm entry 4 text",0
mm_entry5  word 0
           byte "mm entry 5 text",0
mm_entry6  word 0
           byte "mm entry 6 text",0

s1_entry1  word 0
           byte "s1 entry 1 text",0
s1_entry2  word @subsub1_1
           byte "s1 entry 2 text",0
 
s2_entry1  word 0
           byte "s2 entry 1 text",0
s2_entry2  word 0
           byte "s2 entry 2 text",0
s2_entry3  word 0
           byte "s2 entry 3 text",0

s1_2_entry1 word 0
           byte "one more level1",0
s1_2_entry2 word 0
           byte "one more level2",0
}}

alt   byte "This is a demo  for alternating text, which is  pretty cool, as the function wasbuild for someth different ;o)  ",0
leer  byte "                ",0,0,0,0
text  byte "Benky's iBooster",0,0,0,0
text4 byte "Screen2 iBooster",0,0,0,0
text2 byte "Demo !!!        ",0,0,0,0
text5 byte "10mA          5V",0,0,0,0
text6 byte "==            ==",0,0,0,0
text3 byte "00000000",0,0,0,0
longt byte "This is a long text-row, which shall be printed on the small display. ",0
char1 byte $00, $0a, $0a, $1f, $11, $11, $0e, $00
char2 byte $0a, $1f, $0a, $1f, $0a, $1f, $0a, $00
bar1  byte $10, $10, $10, $10, $10, $10, $10, $10
bar2  byte $18, $18, $18, $18, $18, $18, $18, $18
bar3  byte $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c
bar4  byte $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e
{{
barA  byte $1a, $16, $17, $0c, $0f, $1c, $1c, $1c
barB  byte $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1c

barC  byte $1c, $1b, $1c, $1c, $1c, $1c, $1c, $1c
barD  byte $1c, $1c, $1d, $1c, $1c, $1c, $1c, $1c
barE  byte $1c, $1c, $1c, $1f, $1c, $1c, $1c, $1c
barF  byte $1c, $1c, $1c, $1c, $10, $1c, $1c, $1c
barG  byte $1c, $1c, $1c, $1c, $1c, $11, $1c, $1c
barH  byte $1c, $1c, $1c, $1c, $1c, $1c, $12, $1c
barI  byte $1c, $1c, $1c, $1c, $1c, $1c, $1c, $14
barJ  byte $1c, $1c, $1c, $17, $1c, $1c, $1c, $1c

inter1 byte 1,1,2,3,4,5,6,7,0
leerst byte "        ",0
}}
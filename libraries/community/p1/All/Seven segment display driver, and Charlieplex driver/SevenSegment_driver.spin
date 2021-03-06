{{┌─────────────────────────────────────┐
  │ Seven-segment display driver        │
  │ Author: Chris Gadd                  │
  │ Copyright (c) 2014 Chris Gadd       │
  │ See end of file for terms of use.   │
  └─────────────────────────────────────┘

  PUB methods
    Start(low_digit_pin, low_segment_pin, digits, digits_level, segments_level)
      The common pins for each digit need to be in a contiguous block in ascending order (lowest digit on lowest pin)
      The pins for each segment need in a contiguous block of eight pins, but the order can be rearranged by editing the lookup table for the patterns
      This driver can support any number of digits
      Digits_level and Segments_level are set high or low depending on the output required to light the display 

         ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
         │ Common-cathode                    Common-anode                        Also used for transistor-driven displays:                                               │
         │  Digits low, segments high         Digits high, segments low                                                                                                  │
         │                                                                       Common-cathode                 Common-anode                 Common-cathode              │
         │                                                                        Digits high, segments high     Digits low, segments low     Digits high, segments low  │
         │      Anodes ───┳──┳──┳──┐          Display 1 ───────────┐                                                                                               │
         │                  ┌┴┐┌┴┐┌┴┐┌┴┐                                 │         Anodes ────┐                                                                   │
         │                  │8││8││8││8│         Display 2 ────────┐  │                      ┌┴┐                             │                        │             │
         │                  └┬┘└┬┘└┬┘└┬┘                              │  │                      │8│               Display ──┻           Anodes ──┻             │
         │   Display 4 ───┘  │  │  │          Display 3 ─────┐  │  │                      └┬┘                             ┌┴┐                       ┌┴┐            │
         │                      │  │  │                            │  │  │         Display──┳                              │8│                       │8│            │
         │   Display 3 ──────┘  │  │          Display 4 ──┐  │  │  │                      │                              └┬┘                       └┬┘            │
         │                         │  │                        ┌┴┐┌┴┐┌┴┐┌┴┐                                     Cathodes────┘           Display──┳             │
         │   Display 2 ─────────┘  │                        │8││8││8││8│                                                                               │             │
         │                            │                        └┬┘└┬┘└┬┘└┬┘                                                                                            │
         │   Display 1 ────────────┘          Cathodes  ──┻──┻──┻──┘                                                                                               │
         │   (low pin)                                                                                                                                                   │
         └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    Stop                : stops the driver
    Display(StringPtr)  : address of a string to display, valid characters are "0" through "9", decimal ".", minus "-", and space " "
                           any other characters will result in unexpected operation - does not perform range checking
                          Display(string("123.456"))
    Display_off         : Turns the display off but keeps the settings
    Justify(left/right) : Display digits from the left or the right edge of the display, does not drop high digits
                           "123" right justified on a 6-digit display shows "___123" / "123456789" shows "123456"
    Blink(true/false)   : Blinks the entire display at a 2Hz rate - uses ctra to determine the blink rate
    Strobe(true/false)  : Strobes the segments in each digit, reduces power requirement but also results in a dimmer display
                           Useful if connecting the common display pin to a prop pin
                            Connected directly, the prop pin might have to source/sink current for eight digits
                            With strobe, only ever has to source/sink a single segment at a time
    Dec(value)          : Converts a number to a string and displays it
    DecF(value,divider,places) : Displays a divided value to the specified number of places
                                  DecF(12345,100,2) displays 123.45

                           1 1 1 1 1 2 2 2 2                                  
      G F c A B            F G A B c c F A B                                  
    ┌─┴─┴─┴─┴─┴─┐        ┌─┴─┴─┴─┴─┴─┴─┴─┴─┴─┐               
    │ ──A──     │        │ ──A──      ──A──  │               
    ││     │    │        ││     │    │     │ │               
    │F     B    │        │F     B    F     B │               
    ││     │    │        ││     │    │     │ │               
    │ ──G──     │        │ ──G──      ──G──  │               
    ││     │    │        ││     │    │     │ │               
    │E     C ┌─┐│        │E     C    E     C │               
    ││     │ dp││        ││     │    │     │ │               
    │ ──D──  └─┘│        │ ──D── d    ──D── d│                                
    └─┬─┬─┬─┬─┬─┘        └─┬─┬─┬─┬─┬─┬─┬─┬─┬─┘                                
      E D c C dp           E D C d E D G C d                                  
                           1 1 1 1 2 2 2 2 2
                           
}}                                                                                   
CON                                                   
  _clkmode = xtal1 + pll16x                                                   
  _xinfreq = 5_000_000

CON
  left = 0
  right = 1
  low = 0
  high = 1
  
VAR

  word  StrAdd
  word  TabAdd
  byte  _display_digits
  byte  _digits_offset
  byte  _segments_offset
  byte  _command
  byte  local_string[32]                                
  byte  idx
  byte  cog

PUB Demo

  Start(8,16,6,high,high)                               ' Digits starting on pin 8                                               
                                                        ' Segments starting on pin 16                                            
                                                        ' 6 digits                                                               
                                                        ' common high                                                            
                                                        ' segments high                                                          
                                                                                                                                 
  strobe(false)                                         ' lights each segment individually, reduces power but also dims display  
                                                                                
  repeat 
    justify(right)
    blink(false)
    Display(string("123"))                              ' display 123 right-justified
    waitcnt(cnt + clkfreq * 4)
    justify(left)
    blink(true)
    Display(string("9.8.7."))                           ' display "9.8.7." left-justified and blinking
    waitcnt(cnt + clkfreq * 4)
    blink(false)
    justify(right)
    Dec(-2468)                                          ' display the number -2468
    waitcnt(cnt + clkfreq * 4)
    Decf(12345,100,2)                                   ' display 12345 divided by 100 to two decimal places
    waitcnt(cnt + clkfreq * 4)

PUB Start(low_digit_pin,low_segment_pin,_digits,digits_level,segments_level) : okay 

  stop
  TabAdd := @Lookup_Table
  _display_digits := _digits
  _digits_offset := low_digit_pin
  _segments_offset := low_segment_pin

  _command := (digits_level & 1) << 1 | segments_level & 1
  
  okay := cog := cognew(@entry,@StrAdd) + 1
  waitcnt(cnt + clkfreq / 10000)                                                ' needs a slight delay for the PASM routine to read the contents of _command

PUB stop
  if cog
    cogstop(cog~ - 1)

PUB Display(stringAdd)
  
  StrAdd := stringAdd
  _command |= %1000_0000

PUB Display_off
{
  Blanks the display, keeps the other parameters (justify, blink, strobe) intact
}
  _command := _command & !%1000_0000

PUB Justify(dir)
{
  Display digits from the left or right edge of the display, does not drop high digits
  "123" right justified on a 6-digit display shows "___123" / "123456789" shows "123456"
}
  _command := _command & !1 | dir & 1

PUB Blink(state)
{
  Blinks the display at a 2Hz rate
}
  _command := _command & !%10 | state & 1 << 1

PUB Strobe(state)
{
  Strobes the segments in each digit, reduces power requirement but also results in a dimmer display
}
  _command := _command & !%100 | state & 1 << 2

PUB Dec(value) | i, x

  idx := 0
                                                                                
  x := value == NEGX                                                            ' Check for max negative
  if value < 0                                                                  
    value := ||(value+x)                                                        ' If negative, make positive; adjust for max negative
    Append("-")                                                                 '  and output sign

  i := 1_000_000_000                                                            ' Initialize divisor

  repeat 10                                                                     ' Loop for 10 digits
    if value => i                                                               
      Append(value / i + "0" + x*(i == 1))                                      ' If non-zero digit, output digit; adjust for max negative
      value //= i                                                               '  and digit from value
      result~~                                                                  '  flag non-zero found                                               
    elseif result or i == 1                                                                                                  
      Append("0")                                                               ' If zero digit (or only digit) output it                            
    i /= 10                                                                     ' Update divisor

  Display(@local_string)                         

PUB DecF(value,divider,places) | i, x
{
  DecF(1234,100,3) displays "12.340"
}

  idx := 0

  if value < 0
    || value                                            ' If negative, make positive
    append("-")                                         ' and output sign
' else
'   fds.tx(" ")                                         
  
  i := 1_000_000_000                                    ' Initialize divisor
  x := value / divider

  repeat 10                                             ' Loop for 10 digits
    if x => i                                                                   
      append(x / i + "0")                               ' If non-zero digit, output digit
      x //= i                                           ' and remove digit from value
      result~~                                          ' flag non-zero found
    elseif result or i == 1
      append("0")                                       ' If zero digit (or only digit) output it
    i /= 10                                             ' Update divisor

  append(".")

  i := 1
  repeat places
    i *= 10
    
  x := value * i / divider                             
  x //= i                                               ' limit maximum value
  i /= 10
    
  repeat places
    append(x / i + "0")
    x //= i
    i /= 10

  Display(@local_string)

PRI Append(char)

  Local_string[idx++] := char
  
DAT                     org       
Lookup_Table                      'BAFG_dCDE           
:Zero                   byte      %1110_0111                                    ' The bit patterns can be re-ordered
:One                    byte      %1000_0100                                    '  to coincide more easily with IO pins
:Two                    byte      %1101_0011                                    '  (segment E on low pin, B on high pin)
:Three                  byte      %1101_0110                                    ' pins must be contiguous, due to needing                                          
:Four                   byte      %1011_0100                                    '  to fit the pattern in a byte                                                    
:Five                   byte      %0111_0110                                                                                                                       
:Six                    byte      %0011_0111                                                                                                                       
:Seven                  byte      %1100_0100                                    
:Eight                  byte      %1111_0111           
:Nine                   byte      %1111_0100
:blank                  byte      %0000_0000                                   
:dot                    byte      %0000_1000
:minus                  byte      %0001_0000

DAT                     org   
entry
                        mov       t1,par
                        mov       string_address,t1
                        add       t1,#2
                        rdword    table_address,t1
                        add       t1,#2
                        rdbyte    digits,t1                                     ' Read the number of digits
                        add       t1,#1
                        rdbyte    digits_offset,t1
                        mov       $,$                         wc,nr             ' Set carry
                        mov       digits_mask,#0
                        rcl       digits_mask,digits                            ' Set a bit in mask for each digit
                        shl       digits_mask,digits_offset                     ' Shift the mask to the low digit pin
                        add       t1,#1
                        rdbyte    segments_offset,t1
                        mov       segments_mask,#$FF                            ' Set a bit in mask for each segment
                        shl       segments_mask,segments_offset                 ' Shift the mask to the low segment pin
                        add       t1,#1
                        mov       command,t1
                        rdbyte    levels,command                                ' command contains the segment and digit levels on startup
                        mov       pattern_address,table_address                 ' Lookup the :dot pattern to use as a 
                        add       pattern_address,#11                           '  mask for the decimal point
                        rdbyte    dp_mask,pattern_address
                        or        dira,digits_mask
                        or        dira,segments_mask
                        movi      ctra,#%0_11111_000                            ' Uses the counter to blink the display    
                        mov       frqa,_2Hz                                     '  on demand at a 2Hz rate
'......................................................................................................................
wait_for_command
                        rdbyte    t1,command
                        test      t1,#%1000_0000              wc                ' test display flag
          if_nc         test      levels,#%10                 wz
          if_nc         muxz      outa,digits_mask
          if_nc         jmp       #wait_for_command
                        test      t1,#%0000_0010              wc                ' test blink flag
          if_nc         jmp       #:no_blink
                        mov       t3,phsa
                        rcl       t3,#1                       wc
          if_c          test      levels,#%10                 wz                ' test the digits bit
          if_c          muxz      outa,digits_mask
          if_c          jmp       #wait_for_command
:no_blink 
                        mov       digit_counter,digits
                        mov       digit_mask,#1
                        shl       digit_mask,digits_offset
                        test      t1,#%0000_0001              wc                ' test justify flag
          if_nc         jmp       #:left_justify
:right_justify                                                                  
                        rdword    t2,string_address
                        mov       digit_counter,#0
:loop                                                                           
                        rdbyte    t3,t2                       wz                ' determine the string length by looping
          if_z          jmp       #display_string                               '  until the null-termination is found
                        add       t2,#1                                         ' address the next byte in the string
                        cmp       t3,#"."                     wz                ' ignore decimal points
          if_e          jmp       #:loop
                        add       digit_counter,#1                              ' increment a counter for each byte in the string
                        jmp       #:loop
:left_justify
                        mov       digit_counter,digits                          ' for left justify, start at the highest digit 
display_string
                        max       digit_counter,digits                          ' in case right_justify counts more bytes than there are digits 
                        shl       digit_mask,digit_counter                      '  preserves the high bytes
                        shr       digit_mask,#1                                 ' digits is 1-based, shift needs to be 0-based
                        rdword    t2,string_address
:loop
                        rdbyte    t3,t2                       wz           
          if_z          jmp       #wait_for_command
                        sub       t3,#"0"
                        cmp       t3,_blank                   wz
          if_e          mov       t3,#10
                        cmp       t3,_dot                     wz
          if_e          mov       t3,#11
                        cmp       t3,_minus                   wz
          if_e          mov       t3,#12
                        call      #display_digit
                        shr       digit_mask,#1
                        djnz      digit_counter,#:loop
                        jmp       #wait_for_command
'----------------------------------------------------------------------------------------------------------------------
display_digit
                        mov       pattern_address,table_address                 ' Find the bit pattern
                        add       pattern_address,t3                            ' t3 contains 0 - 10
                        rdbyte    pattern,pattern_address

                        add       t2,#1                                         ' Check the next byte in the string to 
                        rdbyte    t3,t2                                         '  determine if the decimal point is lit
                        cmp       t3,#"."                     wz
          if_e          add       t2,#1                                         
          if_e          or        pattern,dp_mask
                        shl       pattern,segments_offset                       ' Move the pattern to the segment pins
                        test      t1,#%0000_0100              wc                ' Test strobe flag
          if_c          jmp       #strobe_segments
                        or        pattern,digit_mask
                        test      levels,#%10                 wc                ' Test the digits bit
          if_nc         xor       pattern,digits_mask
                        test      levels,#%01                 wc                ' Test the segments bit
          if_nc         xor       pattern,segments_mask
                        mov       outa,pattern                                  ' Update the pins
                        mov       t3,delay_80us                                 ' persistence delay
                        djnz      t3,#$                        
                        jmp       display_digit_ret                             ' no # needed for jmp to ret
'......................................................................................................................
strobe_segments
                        mov       segment_counter,#8                            
                        neg       segment_mask,#$02                             ' segment mask = $FFFE
                        rol       segment_mask,segments_offset                  ' rotate the 0-bit to the segments offset
:loop
                        mov       t3,pattern                                    ' copy the segments pattern
                        andn      t3,segment_mask                               ' mask all but one segment
                        or        t3,digit_mask                                 
                        test      levels,#%10                 wc                ' Test the digits bit
          if_nc         xor       t3,digits_mask
                        test      levels,#%01                 wc                ' Test the segments bit
          if_nc         xor       t3,segments_mask                        
                        mov       outa,t3                                       ' Update the pins
                        mov       t3,delay_10us                                 ' persistence delay
                        djnz      t3,#$
                        rol       segment_mask,#1
                        djnz      segment_counter,#:loop
display_digit_ret       ret
'======================================================================================================================
_blank                  long      " " - "0"                                     ' constants for comparing bytes in the string
_dot                    long      "." - "0"
_minus                  long      "-" - "0"
delay_80us              long      _xinfreq * 16 / 4 / 12_500
delay_10us              long      _xinfreq * 16 / 4 / 100_000
_2Hz                    long      107

levels                  res       1                                             ' b1 = digits hi/low, b0 = segments hi/low
string_address          res       1
table_address           res       1                                             ' address of lookup_table
pattern_address         res       1                                             ' address of a specific pattern in the lookup table
digits_mask             res       1                                             ' mask for all digits
digit_mask              res       1                                             ' mask for a single digit - used for strobing digits
digits_offset           res       1                                             ' low pin of digits
segments_mask           res       1                                             ' mask for all segments
segment_mask            res       1                                             ' mask for a single segment - used for strobing segments
segments_offset         res       1                                             ' low pin of segments
dp_mask                 res       1                                             ' bit mask for the decimal point
command                 res       1                                             
digits                  res       1                                             ' contains the number of digits in the display
pattern                 res       1                                             ' contains a pattern from the lookup table
digit_counter           res       1                                             
segment_counter         res       1
t1                      res       1
t2                      res       1
t3                      res       1

                        fit

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
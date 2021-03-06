{{
Circuit:

   +5V
       ADC0808           Propeller I/O Pins
    │ ┌──────────┐   1kΩ(all) 
    ┣─┤Vcc     D7├────── P0
    └─┤Vref+    .│
      │         .│
      │        D0├────── P7
      │IN0     OE├──────── P12
      │.      EOC├────── P11
      │.    START├──────── P27
      │IN7   MUXA├──────── P8
      │      MUXB├──────── P9
      │      MUXC├──────── P10
    ┌─┤Vref-  ALE├──────── P26
    ┣─┤GND    CLK├──────── P13
    │ └──────────┘
    
}}            

CON

  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x

OBJ

  debug:        "FullDuplexSerial"
  ADC:          "ADC0808driver"
   
VAR

  byte data[8]
  
PUB main | input, T, dT
{{
Takes inputs every 0.1 sec and prints them using PST terminal
}}

  ctra[30..26] := %00100               'Set ctra for "NCO single-ended"
  ctra[5..0] := 13                     'Set APIN to P13
  frqa := 53687091                     '1MHz
  dira[13]~~                           'pin 13 set to output

  debug.start(31, 30, 0, 57600)        'start debugger process
  ADC.startConversion                  'start conversion process

  dT := clkfreq/10                     'timing parameters
  T  := cnt                            
  
  repeat                               'infinite loop
    Debug.tx(Debug#CLS)                'clear output string
                                       'get all 8 bytes of data
    ADC.get(@data[0],@data[1],@data[2],@data[3],@data[4],@data[5],@data[6],@data[7])
    displaystuff                       'print the data

    T += dT                            'wait .1 sec
    waitcnt(T)          

PUB displaystuff | input
''prints out lines like this:
''Input #1: 01101001

  repeat input from 0 to 7             'for(input=0;input<7;input++)
    Debug.Str(String("Input #"))       'print out label
    Debug.dec(input)                   'print out input
    debug.str(String(": "))            'print out label
    Debug.bin(data[input],8)           'print out byte of data
    Debug.tx($0D)                      'carraige return
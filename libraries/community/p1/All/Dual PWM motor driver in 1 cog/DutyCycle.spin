''File:DutyCycle.spin


CON
  'some values arbitrarily set PWMFrequency=400Hz maxintvalue=12(max for 8 bit bidirectional input)


  MULTIPLIER    = 198            'Constant value based on desired PWM frequency and the maximum value of the input integer  MULTIPLIER=(1/maxintvalue)*(1/PWMFrequency)*SCALE 
  CTIME         = 25000          'CTIME=(1/(PWMFrequency))* SCALE
  SCALE         = 10_000_000     'Scale value to avoid floating point needs to be large enough to shift the multiplier term to a useful integer value
  MOTORAPIN     = 6              'pin output A
  MOTORBPIN     = 7              'pin output B


VAR

  byte  cog
  byte  dutyha
  byte  dutyla
  byte  dutyhb
  byte  dutylb
  byte  diff
  long  stack[15]             


PUB Start(dutya, dutyb) : success
  ''dutya and dutyb are an integer value from 0 to 127 where 0 is 0V DC and 127 is 3.3V DC and the intermediate values are variable duty cycles
  ''runs in one cog
  Stop
  success := (cog := cognew(setdutym(dutya, dutyb), @stack) + 1)

PUB Stop

  if cog
    cogstop(cog~ - 1)

PUB setdutym(dutya, dutyb)

  dira[MOTORAPIN..MOTORBPIN]~~

  
  dutyha:= SCALE/(MULTIPLIER * dutya)
  dutyla:= SCALE/(CTIME - SCALE/dutyha)

  dutyhb:= SCALE/(MULTIPLIER * dutyb)
  dutylb:= SCALE/(CTIME - SCALE/dutyhb)


  if dutyha == dutyhb
    diff:=SCALE/(SCALE/dutyhb - SCALE/dutyha)
    repeat
      waitcnt(clkfreq/dutyha + cnt)
      outa[MOTORAPIN..MOTORBPIN]:= 0
      waitcnt(clkfreq/dutyla + cnt)
      ! outa[MOTORAPIN..MOTORBPIN]

  elseif dutyha > dutyhb
    diff:=SCALE/(SCALE/dutyhb - SCALE/dutyha)
    repeat
      waitcnt(clkfreq/dutyha + cnt)
      outa[MOTORAPIN]:= 0
      waitcnt(clkfreq/diff + cnt)
      outa[MOTORBPIN]:= 0
      waitcnt(clkfreq/dutylb + cnt)

  else
    diff:=(SCALE/(SCALE/dutyha - SCALE/dutyhb))
    repeat
      waitcnt(clkfreq/dutyhb + cnt)
      outa[MOTORBPIN]:= 0
      waitcnt(clkfreq/diff + cnt)
      outa[MOTORAPIN]:= 0
      waitcnt(clkfreq/dutyla + cnt)
      ! outa[MOTORAPIN..MOTORBPIN]



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
  

  
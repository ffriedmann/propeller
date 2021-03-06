{{┌──────────────────────────────────────────┐
  │ MPU-9150 demo using my I2C driver        │
  │ Author: Chris Gadd                       │
  │ Copyright (c) 2014 Chris Gadd            │
  │ See end of file for terms of use.        │
  └──────────────────────────────────────────┘
                                                                                                 
}}                                                                                                                                                
CON
  _clkmode = xtal1 + pll16x                                                      
  _xinfreq = 5_000_000

  SCL = 28
  SDA = 29

  ACC_SENS = 0
  GYRO_SENS = 0

OBJ
  MPU   :   "MPU-9150 PASM driver"
  FDS   :   "FullDuplexSerial"
  
PUB demo | address, acc_scale, gyro_scale

  mpu.start(SCL,SDA,ACC_SENS,GYRO_SENS)
  fds.start(31,30,0,115_200)

  acc_scale := 16384 >> ACC_SENS
  gyro_scale := 131 * 10 >> GYRO_SENS
  address := mpu.get_address                            ' get the base address of the long array in the MPU object
  
  repeat
    waitcnt(cnt + clkfreq / 20)                                                 
    fDS.tx($00)

''  using the get_acc(x) methods to read the accelerometer

    fds.str(string("Acc_X",$09))      
    decf(mpu.get_acc(0),acc_scale,3)                    ' 16384 lsb/mg at ±2g
    fds.str(string($0D,"Acc_Y",$09))                    '  8192 lsb/mg at ±4g   
    decf(mpu.get_acc(1),acc_scale,3)                    '  4096 lsb/mg at ±8g
    fds.str(string($0D,"Acc_Z",$09))                    '  2048 lsb/mg at ±16g
    decf(mpu.get_acc(2),acc_scale,3)

''  alternate method using the base address of the long array in the MPU object
    
    fds.str(string($0D,$0D,"Gyro_X",$09))               ' 131   lsb/°/s at ±250°/s
    decf(long[address][4] * 10,gyro_scale,3)            '  66.5 lsb/°/s at ±500°/s
    fds.str(string($0D,"Gyro_Y",$09))                   '  32.8 lsb/°/s at ±1000°/s
    decf(long[address][5] * 10,gyro_scale,3)            '  16.4 lsb/°/s at ±2000°/s
    fds.str(string($0D,"Gyro_Z",$09))  
    decf(long[address][6] * 10,gyro_scale,3)

    fds.str(string($0D,$0D,"Pitch",$09))
    fds.dec(mpu.get_pitch)            
    fds.str(string("°",$0D,"Roll",$09))
    fds.dec(long[address][7])
    fds.tx("°")   

    FDS.str(string($0D,$0D,"Mag_X",$09))
    FDS.dec(mpu.get_mag(0))
    FDS.str(string($0D,"Mag_Y",$09))
    FDS.dec(mpu.get_mag(1))
    FDS.str(string($0D,"Mag_Z",$09))
    FDS.dec(mpu.get_mag(2))

    fds.str(string($0D,$0D,"Temp",$09))
    fds.dec(mpu.get_temp)
    fds.str(string("°C",$09))                                                   ' die temperature, about 8°C hotter than ambient?
    fds.dec(mpu.get_temp * 9 / 5 + 32)
    fds.str(string("°F"))

PRI DecF(value,divider,places) | i, x

  if value < 0
    || value                                            ' If negative, make positive
    fds.tx("-")                                         ' and output sign
  else
    fds.tx(" ")                                         
  
  i := 1_000_000_000                                    ' Initialize divisor

  x := value / divider

  repeat 10                                             ' Loop for 10 digits
    if x => i                                                                   
      fds.tx(x / i + "0")                               ' If non-zero digit, output digit
      x //= i                                           ' and remove digit from value
      result~~                                          ' flag non-zero found
    elseif result or i == 1
      fds.tx("0")                                       ' If zero digit (or only digit) output it
    i /= 10                                             ' Update divisor

  fds.tx(".")

  i := 1
  repeat places
    i *= 10
    
  x := value * i / divider                             
  x //= i                                               ' limit maximum value
  i /= 10
    
  repeat places
    fds.Tx(x / i + "0")
    x //= i
    i /= 10    

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
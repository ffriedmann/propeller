{{


*******************************************
* Complementary Filter Demo               *
* Author: Zack Lantz   2013               *
*******************************************

*** This Demo uses Serial Chart ( http://code.google.com/p/serialchart/ )


Serial Chart Config:

   
  [_setup_]
  port=COM5
  baudrate=115200
   
  width=1000
  height=201
  background_color = white
   
  grid_h_origin = 100
  grid_h_step = 10
  grid_h_color = #EEE
  grid_h_origin_color = #CCC
   
  grid_v_origin = 100
  grid_v_step = 10
  grid_v_color = #EEE
  grid_v_origin_color = transparent
   
  [_default_]
  min=-180  
  max=180  
   
  [interval]
  color=transparent
  min=0
  max=100000
   
  [X]
  color=red
   
  [Y]
  color=blue
   
  [Z]
  color=green
   
  [A]
  color=cyan
   
  [B]
  color=magenta
   
  [C]
  color=yellow
   
  [G]
  color=red
  dash=1
   
  [H]
  color=blue
  dash=1
   
  [I]
  color=green
  dash=1


}}

Con
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


  MPUsda  = 4     ' // MPU SDA Pin
  MPUscl  = 3     ' // MPU SCL Pin

  dt = 0.002      ' // MPU-6050 500 Hz Sample Rate   ( dt = 1 / 500 )
  tau = 1         ' // Desired Time Constant


Obj

  debug : "FullDuplexSerial"
  MPU   : "MPU-6050"

  f     : "FloatMath"
  fs    : "FloatString"
  

Var
  long Angle[3]


Pub Start | mAngle, A, B, C, X, Y, Z, cDeg, Alpha
  MPU.Start(MPUscl, MPUsda)
  debug.start(31, 30, 0, 115200)

  cDeg  := f.fDiv(180.0, 32768.0)       ' Gyro / Accel Reading to +/- 180 Degrees Conversion Factor 
  
  repeat

    ' // Convert Accleerometer Data to Degrees +/- 0 to 180
    X := f.fMul(f.fFloat(MPU.GetAX), cDeg)
    Y := f.fMul(f.fFloat(MPU.GetAY), cDeg)
    Z := f.fMul(f.fFloat(MPU.GetAZ), cDeg)

    ' // Convert Gyroscope Data to Degrees +/- 0 to 180
    A := f.fMul(f.fFloat(MPU.GetRX), cDeg)
    B := f.fMul(f.fFloat(MPU.GetRY), cDeg)
    C := f.fMul(f.fFloat(MPU.GetRZ), cDeg)
             
    ' // Angle Calculation
    ' dt = 0.02
    ' Angle = 0.98 * (Angle + gyrData * dt) + 0.02 * (accData)
    
    ' // Could also use:
    '    Angle[#] := f.fMul(0.98, f.fAdd(f.fAdd(f.fMul(A, dt), Angle[#]), f.fMul(0.02, X)))
    
    mAngle := Angle[0]          ' // Store Previous Value to calculate New Value
    Angle[0] := f.fMul(0.98, f.fAdd(f.fAdd(f.fMul(A, dt), mAngle), f.fMul(0.02, X)))
    mAngle := Angle[1]          ' // Store Previous Value to calculate New Value
    Angle[1] := f.fMul(0.98, f.fAdd(f.fAdd(f.fMul(B, dt), mAngle), f.fMul(0.02, Y)))
    mAngle := Angle[2]          ' // Store Previous Value to calculate New Value       
    Angle[2] := f.fMul(0.98, f.fAdd(f.fAdd(f.fMul(C, dt), mAngle), f.fMul(0.02, Z)))
    

    ' // Send Data to PC in CSV ( Serial Chart )
    debug.tx(13)      
    debug.dec(f.fRound(X))
    debug.str(string(","))
    debug.dec(f.fRound(Y))
    debug.str(string(","))
    debug.dec(f.fRound(Z))
    debug.str(string(","))

    debug.dec(f.fRound(A))
    debug.str(string(","))
    debug.dec(f.fRound(B))
    debug.str(string(","))
    debug.dec(f.fRound(C))
    debug.str(string(","))

    debug.str(fs.floattostring(Angle[0]))
    debug.str(string(","))
    debug.str(fs.floattostring(Angle[1]))
    debug.str(string(","))
    debug.str(fs.floattostring(Angle[2]))
    debug.tx(13)


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
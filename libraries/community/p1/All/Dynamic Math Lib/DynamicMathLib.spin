''=============================================================================
''
'' @file     DynamicMathLib
'' @target   Propeller
''
'' IEEE 754 compliant 32-bit floating point math routines.
'' This object provides support for the full set of floating point routines
'' and requires one cog. Basic functions can also be run without a dedicated
'' cog: if all cogs are in use, there's an automatic fallback. This is really
'' not the most efficient way to do it, but it works. This library is best
'' used when calling a math library from multiple objects e.g. this should
'' hopefully cover all the math you have in your program. Custom functions
'' as outlined in the Float32 documentation STILL need two cogs.
''
''   ──NavMathLib
''       │
''       └── float32aDML
''
'' @author   Cam Thompson, Matteo Borri          
'' @version  V1.0 - November 9, 2006
'' @changes
''  - oct 20 2006 admittedly slow dynamic cog allocation
''  - nov 05 2006 added some functions
''  - nov 09 2006 Merged with nav math library and floatmath
''=============================================================================

CON
  FAddCmd       = 1 << 16 
  FSubCmd       = 2 << 16 
  FMulCmd       = 3 << 16 
  FDivCmd       = 4 << 16 
  FFloatCmd     = 5 << 16  
  FTruncCmd     = 6 << 16 
  FRoundCmd     = 7 << 16 
  FSqrCmd       = 8 << 16 
  FCmpCmd       = 9 << 16 
  SinCmd        = 10 << 16
  CosCmd        = 11 << 16
  TanCmd        = 12 << 16
  LogCmd        = 13 << 16
  Log10Cmd      = 14 << 16
  ExpCmd        = 15 << 16
  Exp10Cmd      = 16 << 16
  PowCmd        = 17 << 16
  FracCmd       = 18 << 16 
  FModCmd       = 19 << 16
  
  ASinCmd       = 20 << 16
  ACosCmd       = 21 << 16
  ATanCmd       = 22 << 16
  ATan2Cmd      = 23 << 16
  FloorCmd      = 24 << 16
  CeilCmd       = 25 << 16
  FAdd2Cmd      = 26 << 16   ' used to have the float32aDML cog do a basic operation without restartng
  FSub2Cmd      = 27 << 16   ' used to have the float32aDML cog do a basic operation without restartng
  FMul2Cmd      = 28 << 16   ' used to have the float32aDML cog do a basic operation without restartng - used for atan2D
  
  FFuncCmd      = $8000<<16
  LoadCmd       = $8000<<16
  SaveCmd       = $8001<<16
  FNegCmd       = $8002<<16
  FAbsCmd       = $8003<<16
  JmpCmd        = $8004<<16
  JmpEqCmd      = $8005<<16
  JmpNeCmd      = $8006<<16
  JmpLtCmd      = $8007<<16
  JmpLeCmd      = $8008<<16
  JmpGtCmd      = $8009<<16
  JmpGeCmd      = $800A<<16
  JmpNaNCmd     = $800B<<16
    
  SignFlag      = $1
  ZeroFlag      = $2
  NaNFlag       = $8
  
VAR

  long  cog
  long  command2, cmdReturn2, arg1, arg2, command, cmdReturn
  
OBJ

  fa             : "float32aDML" ' For the functions that don't fit into one asm block. Modification of Float32A.
  

con '' usual start/stop functions here
PUB start : okay
'' doesn't really do much, but keep for coherence with float32 -- it will return a word variable with which two cogs get started, though.

    okay := restart
    stop

PUB  stop
'' stop all
   stop2
   stop1

con '' ACTUAL start/stop functions here, private to avoid clogging
pri restart : okay
'' turns on BOTH cogs -- will freeze if they are not available! warning! This only gets used for custom functions though.
    okay := restart1 * 256
    okay += restart2
    
pri try1 
'' start floating point engine 1 in a new cog
'' returns false if no cog available
  command~
  cog := cognew(@GetCommand, @command) + 1
  return cog

pri restart1 : okay

'' start floating point engine 1 in a new cog
'' waits until it's available

  if cog
    cogstop(cog~ - 1)
  command~
  okay := 0
  repeat
    okay := cog := cognew(@GetCommand, @command) + 1
  until okay

pri restart2 : okay

'' start floating point engine 2 in a new cog
'' waits until it's available

  fa.stop
  okay := 0
  repeat
    okay := fa.start(@command2)
  until okay
  
pri stop2

'' stop floating point engine 2 and release the cog
  fa.stop

pri stop1
'' stop floating point engine 1 and release the cog
  if cog
    cogstop(cog~ - 1)
  command~



con '' basic operations follow, from Float32FullDynamic
PUB FAdd(a, b)
  'return sendCmd(FAddCmd + @a)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFAdd(a, b)
  command := FAddCmd + @a
  repeat while command
  stop1
  return cmdReturn
          
PUB FSub(a, b)
  'return sendCmd(FSubCmd + @a)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFSub(a, b)
  command := FSubCmd + @a
  repeat while command
  stop1
  return cmdReturn
  
PUB FMul(a, b)
  'return sendCmd(FMulCmd + @a)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFMul(a, b)
  command := FMulCmd + @a
  repeat while command
  stop1
  return cmdReturn
          
          
PUB FDiv(a, b)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFDiv(a, b)
  'return sendCmd(FDivCmd + @a)
  command := FDivCmd + @a
  repeat while command
  stop1
  return cmdReturn

PUB FFloat(n)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFFloat(n)
  command := FFloatCmd + @n
  repeat while command
  stop1
  return cmdReturn  

PUB FTrunc(a)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFTrunc(a)
  command := FTruncCmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FRound(a)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFRound(a)
  command := FRoundCmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FSqr(a)
  if (try1 == FALSE) '' This operation can fallback to floatmath
      return SlowFSqr(a)
  'return sendCmd(FSqrCmd + @a)
  command := FSqrCmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FNeg(a)
  return a ^ $8000_0000

PUB FAbs(a)
  return a & $7FFF_FFFF
  
PUB Radians(a)
     return FMul(a,0.017453293)       '' No "slow" version because this just calls fmul

PUB TRadians(a)                    '' 1/10th degree to radians : .1 degree is used a lot in gps
     return FMul(a,0.0017453293)      '' No "slow" version because this just calls fmul

PUB Degrees(a)
     return FMul(a,57.2957795)         '' No "slow" version because this just calls fmul

PUB TDegrees(a)                      '' radians to 1/10th degree: .1 degree is used a lot in gps
     return FMul(a,572.957795)          '' No "slow" version because this just calls fmul


con '' Navigation-specific operations, you may want to comment these out
PUB FCoordsToDist(x1,y1,x2,y2)
   return fdist(fsub(x2,x1),fsub(y2,y1))

PUB ICoordsToDistF(x1,y1,x2,y2)               ' used for large integers
   return fdist(ffloat(x2-x1),ffloat(y2-y1))

PUB FCoordsToDegs(x1,y1,x2,y2) | xx, yy
' returns a MathAngle (-18.00 to 180.0)

   xx := fsub(x2,x1)
   yy := fsub(y2,y1)
' special case in which arctan fails
   if (xx == 0.0 and yy < 0.0)
      return 180.0
'   theta := fround(fmul(degrees(atan2(xx,yy)),10.0))
   return atan2D(xx,yy)

Pub FCircleAngle(theta)
    if (theta < 0.0)
        return fadd(360.0, theta)
    return theta

Pub FMathAngle(theta)
    if (theta > 180.0)
        return fsub(theta, 360.0)
    return theta

PUB FMathAngleDiff(angle1, angle2) 
       
      return FMathAngle(fmod(fadd(720.0, fsub(angle1, angle2 )), 360.0))

PUB FCircleAngleDiff (angle1, angle2) | tempangle
                               
      return fmod(fadd(720.0, fsub(angle1, angle2 )), 360.0)            ' the 7200 makes sure we're using positives
    
PUB FDist(a, b) | c, d, e, f, fast ' returns distance between two points
  'return sendCmd(FMulCmd + @a)

  fast := try1
  if (fast == FALSE) '' This operation can fallback to floatmath
      c:=SlowFMul(a,a)
      d:=SlowFMul(b,b)
      e:=SlowFAdd(c,d)
  else
      c := a
      d := a
      e := b
      f := b
      command := FMulCmd + @c ' c*d=c
      repeat while command
      c := cmdReturn
      command := FMulCmd + @e ' e*f=d
      repeat while command
      d := cmdReturn
      command := FAddCmd + @c ' c+d=e
      repeat while command
      e := cmdReturn

'' square root is VERY slow, so try to request a cog again
  if (fast == FALSE)
      fast := try1
  if (fast == FALSE)
      return SlowFSqr(e)
  else 
      command := FSqrCmd + @e
      repeat while command
      stop1
      return cmdReturn

'   return fround(fmul(fsqr(fadd(fmul(xx,xx),fmul(yy,yy))),10.0))

  

con ''These are from Float32 and require a cog no matter what
PUB FCmp(a, b)
  restart1
  'return sendCmd(FCmpCmd + @a)
  command := FCmpCmd + @a
  repeat while command
  stop1
  return cmdReturn

PUB FSin(a)
  restart1
  'return sendCmd(SinCmd + @a)
  command := SinCmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FCos(a)
  'return sendCmd(CosCmd + @a)
  command := CosCmd + @a
  repeat while command
  return cmdReturn  

PUB FTan(a)
  restart
  'return sendCmd(TanCmd + @a)
  command := TanCmd + @a
  repeat while command
  stop1
  return cmdReturn

PUB FSinD(n) | a, b '' same as sin but in degrees
  restart1
  a := n
  b :=  0.017453293 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := SinCmd + @b
  repeat while command
  stop1
  return cmdReturn  

PUB FCosD(n) | a, b '' same as cos but in degrees
  restart1
  a := n
  b :=  0.017453293 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := CosCmd + @b
  repeat while command
  stop1
  return cmdReturn  

PUB FTanD(n) | a,b '' same as tan but in degrees
  restart1
  a := n
  b :=  0.017453293 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := TanCmd + @b
  repeat while command
  stop1
  return cmdReturn  


PUB FLog(a)
  restart1
  'return sendCmd(LogCmd + @a)
  command := LogCmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FLog10(a)
   restart1
  'return sendCmd(Log10Cmd + @a)
  command := Log10Cmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FExp(a)
  'return sendCmd(ExpCmd + @a)
  restart1
  command := ExpCmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FExp10(a)
  restart1
  'return sendCmd(Exp10Cmd + @a)
  command := Exp10Cmd + @a
  repeat while command
  stop1
  return cmdReturn  

PUB FPow(a, b)
  restart1
  'return sendCmd(PowCmd + @a)
  command := PowCmd + @a
  repeat while command
  stop1
  return cmdReturn

PUB FFrac(a)
  restart1
  'return sendCmd(FracCmd + @a)
  command := FracCmd + @a
  repeat while command
  stop1
  return cmdReturn
  
PUB FMod(a, b)
  restart1
  'return sendCmd(FModCmd + @a)
  command := FModCmd + @a
  repeat while command
  stop1
  return cmdReturn

PUB FMin(a, b)
  'sendCmd(FCmpCmd + @a)
  restart1
  command := FCmpCmd + @a
  repeat while command
  stop1
  if cmdReturn < 0
    return a
  return b
  
PUB FMax(a, b)
  'sendCmd(FCmpCmd + @a)
  restart1
  command := FCmpCmd + @a
  repeat while command
  stop1
  if cmdReturn < 0
    return b
  return a

con '' these are also just for navigation
PUB FSinTD(n) | a,b '' same as sin but in tenth of degrees, used a lot in gps
  restart1
  a := n
  b :=  0.0017453293 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := SinCmd + @b
  repeat while command
  stop1
  return cmdReturn  

PUB FCosTD(n) | a,b '' same as cos but in tenth of degrees used a lot in gps
  restart1
  a := n
  b :=  0.0017453293 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := CosCmd + @b
  repeat while command
  stop1
  return cmdReturn  

PUB FTanTD(n) | a,b '' same as tan but in tenth of degrees used a lot in gps
  restart1
  a := n
  b :=  0.0017453293 
  command := FMulCmd + @a
  repeat while command
  b := cmdReturn
  command := TanCmd + @b
  repeat while command
  stop1
  return cmdReturn  


con ''These are from Float32Full and also require a cog, but only one
' Float32A routines
'------------------

PUB ASin(a)
  restart
  command2 := ASinCmd + @a
  repeat while command2
  stop
  return cmdReturn2

PUB ACos(a)
  restart
  command2 := ACosCmd + @a
  repeat while command2
  stop
  return cmdReturn2

PUB ATan(a)
  restart2
  command2 := ATanCmd + @a
  repeat while command2
  stop2
  return cmdReturn2

PUB ATan2(a, b)
  restart2
  command2 := ATan2Cmd + @a
  repeat while command2
  stop2
  return cmdReturn2

PUB ASinD(a) | b, c    '' same as asin but in degrees -180 by +180 
  restart2
  command2 := ASinCmd + @a    ' may use duplicated instructions internally -- see f32aind 
  repeat while command2
  b := cmdReturn2
  c := 57.2957795 
  'sendCmd(FMulCmd + @a)
  command2 := FMul2Cmd + @b   'note that we are using the duplicated multiplication instruction 
  repeat while command2
  stop2
  return cmdReturn2  

PUB ACosD(a) | b, c    '' same as acos but in degrees -180 by +180
  restart2
  command2 := ACosCmd + @a    ' may use duplicated instructions internally -- see f32aind 
  repeat while command2
  b := cmdReturn2
  c := 57.2957795 
  'sendCmd(FMulCmd + @a)
  command2 := FMul2Cmd + @b  'note that we are using the duplicated multiplication instruction 
  repeat while command2
  stop2
  return cmdReturn2  

PUB ATanD(a) | b, c    '' same as atan but in degrees -180 by +180
  restart2
  command2 := ATanCmd + @a     ' may use duplicated instructions internally -- see f32aind 
  repeat while command2
  b := cmdReturn2
  c := 57.2957795 
  'sendCmd(FMulCmd + @a)
  command2 := FMul2Cmd + @b  'note that we are using the duplicated multiplication instruction 
  repeat while command2
  stop2
  return cmdReturn2  

PUB ATan2D(a, b) | c, d    '' same as atan2 but in degrees -180 by +180
  restart2
  command2 := ATan2Cmd + @a     ' may use duplicated instructions internally -- see f32aind 
  repeat while command2
  c := cmdReturn2
  d := 57.2957795 
  'sendCmd(FMulCmd + @a)
  command2 := FMul2Cmd + @c  'note that we are using the duplicated multiplication instruction
  repeat while command2
  stop2
  return cmdReturn2  


PUB Floor(a)
  restart2
  command2 := FloorCmd + @a
  repeat while command2
  stop2
  return cmdReturn2

PUB Ceil(a)
  restart2
  command2 := CeilCmd + @a
  repeat while command2
  stop2
  return cmdReturn2


con '' these are also just for navigation

PUB ASinTD(a) | b, c    '' same as asin but in .1 degrees -1800 by +1800
  restart2
  command2 := ASinCmd + @a    ' may use duplicated instructions internally -- see f32aind 
  repeat while command2
  b := cmdReturn2
  c := 572.957795 
  'sendCmd(FMulCmd + @a)
  command2 := FMul2Cmd + @b   'note that we are using the duplicated multiplication instruction 
  repeat while command2
  stop2
  return cmdReturn2  

PUB ACosTD(a) | b, c    '' same as acos but in .1 degrees -1800 by +1800
  restart2
  command2 := ACosCmd + @a    ' may use duplicated instructions internally -- see f32aind 
  repeat while command2
  b := cmdReturn2
  c := 572.957795 
  'sendCmd(FMulCmd + @a)
  command2 := FMul2Cmd + @b  'note that we are using the duplicated multiplication instruction 
  repeat while command2
  stop2
  return cmdReturn2  

PUB ATanTD(a) | b, c    '' same as atan but in .1 degrees -1800 by +1800
  restart2
  command2 := ATanCmd + @a   ' may use duplicated instructions internally -- see f32aind
  repeat while command2
  b := cmdReturn2
  c := 572.957795 
  'sendCmd(FMulCmd + @a)
  command2 := FMul2Cmd + @b  'note that we are using the duplicated multiplication instruction 
  repeat while command2
  stop2
  return cmdReturn2  

PUB ATan2TD(a, b) | c, d    '' same as atan2 but in .1 degrees -1800 by +1800
  restart2
  command2 := ATan2Cmd + @a    ' may use duplicated instructions internally -- see f32aind 
  repeat while command2
  c := cmdReturn2
  d := 572.957795 
  'sendCmd(FMulCmd + @a)
  command2 := FMul2Cmd + @c  'note that we are using the duplicated multiplication instruction
  repeat while command2
  stop2
  return cmdReturn2  




con ''This I honestly haven't tested with one cog... but should work with two. Still the fastest option available obviously.
PUB FFunc(cmdPointer)
'' Yes, the function processor DOES need both cogs since we don't really know what will be called from here. Sorry.
  restart
  command2 := FFuncCmd + cmdPointer
  repeat while command2
  stop
  return cmdReturn2

'PRI sendCmd(cmd)
'  command := cmd
'  repeat while command
'  return cmdReturn  

con '' from FloatMath, fallback in case there are no cogs available. Still classed as PUB to make sure they can be called directly for low-priority stuff.
PUB SlowFFloat(integer) : single | s, x, m

''Convert integer to float    

  if m := ||integer             'absolutize mantissa, if 0, result 0
    s := integer >> 31          'get sign
    x := >|m - 1                'get exponent
    m <<= 31 - x                'msb-justify mantissa
    m >>= 2                     'bit29-justify mantissa

    return Pack(@s)             'pack result
   

PUB SlowFRound(single) : integer

''Convert float to rounded integer

  return FInteger(single, 1)    'use 1/2 to round


PUB SlowFTrunc(single) : integer

''Convert float to truncated integer

  return FInteger(single, 0)    'use 0 to round


PUB SlowFSqr(singleA) : single | s, x, m, root

''Compute square root of singleA

  if singleA > 0                'if a =< 0, result 0

    Unpack(@s, singleA)         'unpack input

    m >>= !x & 1                'if exponent even, shift mantissa down
    x ~>= 1                     'get root exponent

    root := $4000_0000          'compute square root of mantissa
    repeat 31
      result |= root
      if result ** result > m
        result ^= root
      root >>= 1
    m := result >> 1
  
    return Pack(@s)             'pack result



PUB SlowFAdd(singleA, singleB) : single | sa, xa, ma, sb, xb, mb

''Add singleA and singleB

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, singleB)

  if sa                         'handle mantissa negation
    -ma
  if sb
    -mb

  result := ||(xa - xb) <# 31   'get exponent difference
  if xa > xb                    'shift lower-exponent mantissa down
    mb ~>= result
  else
    ma ~>= result
    xa := xb

  ma += mb                      'add mantissas
  sa := ma < 0                  'get sign
  ||ma                          'absolutize result

  return Pack(@sa)              'pack result


PUB SlowFSub(singleA, singleB) : single

''Subtract singleB from singleA

  return SlowFAdd(singleA, FNeg(singleB))

             
PUB SlowFMul(singleA, singleB) : single | sa, xa, ma, sb, xb, mb

''Multiply singleA by singleB

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, singleB)

  sa ^= sb                      'xor signs
  xa += xb                      'add exponents
  ma := (ma ** mb) << 3         'multiply mantissas and justify

  return Pack(@sa)              'pack result

PUB SlowDegrees(singleA) : single | sa, xa, ma, sb, xb, mb
' 0.0017453293  572.957795
''Multiply singleA by singleB

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, 57.2957795)

  sa ^= sb                      'xor signs
  xa += xb                      'add exponents
  ma := (ma ** mb) << 3         'multiply mantissas and justify

  return Pack(@sa)              'pack result

PUB SlowTDegrees(singleA) : single | sa, xa, ma, sb, xb, mb
' 0.0017453293  572.957795
''Multiply singleA by singleB

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, 572.957795)

  sa ^= sb                      'xor signs
  xa += xb                      'add exponents
  ma := (ma ** mb) << 3         'multiply mantissas and justify

  return Pack(@sa)              'pack result

PUB SlowRadians(singleA) : single | sa, xa, ma, sb, xb, mb
' 0.0017453293  572.957795
''Multiply singleA by singleB

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, 0.017453293)

  sa ^= sb                      'xor signs
  xa += xb                      'add exponents
  ma := (ma ** mb) << 3         'multiply mantissas and justify

  return Pack(@sa)              'pack result

PUB SlowTRadians(singleA) : single | sa, xa, ma, sb, xb, mb
' 0.0017453293  572.957795
''Multiply singleA by singleB

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, 0.0017453293)

  sa ^= sb                      'xor signs
  xa += xb                      'add exponents
  ma := (ma ** mb) << 3         'multiply mantissas and justify

  return Pack(@sa)              'pack result

PUB SlowFDiv(singleA, singleB) : single | sa, xa, ma, sb, xb, mb

''Divide singleA by singleB

  Unpack(@sa, singleA)          'unpack inputs
  Unpack(@sb, singleB)

  sa ^= sb                      'xor signs
  xa -= xb                      'subtract exponents

  repeat 30                     'divide mantissas
    result <<= 1
    if ma => mb
      ma -= mb
      result++        
    ma <<= 1
  ma := result

  return Pack(@sa)              'pack result


con 'these are all deprecated and must die horribly
PUB CoordsToDist(x1,y1,x2,y2)
   return fround(fmul(fdist(ffloat(x2 - x1),ffloat(y2 - y1)),10.0))

PUB CoordsToDegs(x1,y1,x2,y2)
    return fround(fmul(FCoordsToDegs(ffloat(x1), ffloat(y1), ffloat(x2), ffloat(y2)),10.0))

pub IntCosine(val)
return fround(fmul(fcosTD(ffloat(val)),10000.0))

pub IntSine(val)
return fround(fmul(fsinTD(ffloat(val)),10000.0))

pub MathAngle(angle)
return fround(fmul(FMathAngle(fdiv(ffloat(angle),10.0)),10.0))

pub CircleAngle(angle)
return fround(fmul(FCircleAngle(fdiv(ffloat(angle),10.0)),10.0))

PUB AngleDiff(angle1, angle2) | tempangle
return fround(fmul(FCircleAngleDiff(fdiv(ffloat(angle1),10.0),fdiv(ffloat(angle2),10.0)),10.0))








con '' These are used internally... duuh :)
PRI FInteger(a, r) : integer | s, x, m

'Convert float to rounded/truncated integer

  Unpack(@s, a)                 'unpack input

  if x => -1 and x =< 30        'if exponent not -1..30, result 0
    m <<= 2                     'msb-justify mantissa
    m >>= 30 - x                'shift down to 1/2-lsb
    m += r                      'round (1) or truncate (0)
    m >>= 1                     'shift down to lsb
    if s                        'handle negation
      -m
    return m                    'return integer

      
PRI Unpack(pointer, single) | s, x, m

'Unpack floating-point into (sign, exponent, mantissa) at pointer

  s := single >> 31             'unpack sign
  x := single << 1 >> 24        'unpack exponent
  m := single & $007F_FFFF      'unpack mantissa

  if x                          'if exponent > 0,
    m := m << 6 | $2000_0000    '..bit29-justify mantissa with leading 1
  else
    result := >|m - 23          'else, determine first 1 in mantissa
    x := result                 '..adjust exponent
    m <<= 7 - result            '..bit29-justify mantissa

  x -= 127                      'unbias exponent

  longmove(pointer, @s, 3)      'write (s,x,m) structure from locals
  
  
PRI Pack(pointer) : single | s, x, m

'Pack floating-point from (sign, exponent, mantissa) at pointer

  longmove(@s, pointer, 3)      'get (s,x,m) structure into locals

  if m                          'if mantissa 0, result 0
  
    result := 33 - >|m          'determine magnitude of mantissa
    m <<= result                'msb-justify mantissa without leading 1
    x += 3 - result             'adjust exponent

    m += $00000100              'round up mantissa by 1/2 lsb
    if not m & $FFFFFF00        'if rounding overflow,
      x++                       '..increment exponent
    
    x := x + 127 #> -23 <# 255  'bias and limit exponent

    if x < 1                    'if exponent < 1,
      m := $8000_0000 +  m >> 1 '..replace leading 1
      m >>= -x                  '..shift mantissa down by exponent
      x~                        '..exponent is now 0

    return s << 31 | x << 23 | m >> 9 'pack result

con '' Scary assembly language routine starts here.
DAT

'---------------------------
' Assembly language routines
'---------------------------
                        org

GetCommand              rdlong  t1, par wz              ' wait for command
          if_z          jmp     #GetCommand

                        mov     t2, t1                  ' load fnumA
                        rdlong  fnumA, t2
                        add     t2, #4          
                        rdlong  fnumB, t2               ' load fnumB

                        shr     t1, #16 wz              ' get command
                        cmp     t1, #(FModCmd>>16)+1 wc ' check for valid command
          if_z_or_nc    jmp     #:exitNaN 
                        shl     t1, #1
                        add     t1, #:cmdTable-2 
                        jmp     t1                      ' jump to command

:cmdTable               call    #_FAdd                  ' command dispatch table
                        jmp     #endCommand
                        call    #_FSub
                        jmp     #endCommand
                        call    #_FMul
                        jmp     #endCommand
                        call    #_FDiv
                        jmp     #endCommand
                        call    #_FFloat
                        jmp     #endCommand
                        call    #_FTrunc
                        jmp     #endCommand
                        call    #_FRound
                        jmp     #endCommand
                        call    #_FSqr
                        jmp     #endCommand
                        call    #cmd_FCmp
                        jmp     #endCommand
                        call    #_Sin
                        jmp     #endCommand
                        call    #_Cos
                        jmp     #endCommand
                        call    #_Tan
                        jmp     #endCommand
                        call    #_Log
                        jmp     #endCommand
                        call    #_Log10
                        jmp     #endCommand
                        call    #_Exp
                        jmp     #endCommand
                        call    #_Exp10
                        jmp     #endCommand
                        call    #_Pow
                        jmp     #endCommand
                        call    #_Frac
                        jmp     #endCommand
                        call    #_FMod
                        jmp     #endCommand
:cmdTableEnd

:exitNaN                mov     fnumA, NaN              ' unknown command

endCommand              mov     t1, par                 ' return result
                        add     t1, #4
                        wrlong  fnumA, t1
                        wrlong  Zero,par                ' clear command status
                        jmp     #GetCommand             ' wait for next command

'------------------------------------------------------------------------------

cmd_FCmp                call    #_FCmp                  ' compare fnumA and fnumB
                        mov     fnumA, status           ' return compare status
cmd_FCmp_ret            ret

'------------------------------------------------------------------------------
' _FAdd    fnumA = fnumA + fNumB
' _FAddI   fnumA = fnumA + Float immediate
' _FSub    fnumA = fnumA - fNumB
' _FSubI   fnumA = fnumA - Float immediate
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'------------------------------------------------------------------------------

_FSubI                  movs    :getB, _FSubI_ret       ' get immediate value
                        add     _FSubI_ret, #1
:getB                   mov     fnumB, 0

_FSub                   xor     fnumB, Bit31            ' negate B
                        jmp     #_FAdd                  ' add values                                               

_FAddI                  movs    :getB, _FAddI_ret       ' get immediate value
                        add     _FAddI_ret, #1
:getB                   mov     fnumB, 0

_FAdd                   call    #_Unpack2               ' unpack two variables                    
          if_c_or_z     jmp     #_FAdd_ret              ' check for NaN or B = 0

                        test    flagA, #SignFlag wz     ' negate A mantissa if negative
          if_nz         neg     manA, manA
                        test    flagB, #SignFlag wz     ' negate B mantissa if negative
          if_nz         neg     manB, manB

                        mov     t1, expA                ' align mantissas
                        sub     t1, expB
                        abs     t1, t1
                        max     t1, #31
                        cmps    expA, expB wz,wc
          if_nz_and_nc  sar     manB, t1
          if_nz_and_c   sar     manA, t1
          if_nz_and_c   mov     expA, expB        

                        add     manA, manB              ' add the two mantissas
                        cmps    manA, #0 wc, nr         ' set sign of result
          if_c          or      flagA, #SignFlag
          if_nc         andn    flagA, #SignFlag
                        abs     manA, manA              ' pack result and exit
                        call    #_Pack  
_FSubI_ret
_FSub_ret 
_FAddI_ret
_FAdd_ret               ret      

'------------------------------------------------------------------------------
' _FMul    fnumA = fnumA * fNumB
' _FMulI   fnumA = fnumA * Float immediate
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'------------------------------------------------------------------------------

_FMulI                  movs    :getB, _FMulI_ret       ' get immediate value
                        add     _FMulI_ret, #1
:getB                   mov     fnumB, 0

_FMul                   call    #_Unpack2               ' unpack two variables
          if_c          jmp     #_FMul_ret              ' check for NaN

                        xor     flagA, flagB            ' get sign of result
                        add     expA, expB              ' add exponents
                        mov     t1, #0                  ' t2 = upper 32 bits of manB
                        mov     t2, #32                 ' loop counter for multiply
                        shr     manB, #1 wc             ' get initial multiplier bit 
                                    
:multiply if_c          add     t1, manA wc             ' 32x32 bit multiply
                        rcr     t1, #1 wc
                        rcr     manB, #1 wc
                        djnz    t2, #:multiply

                        shl     t1, #3                  ' justify result and exit
                        mov     manA, t1                        
                        call    #_Pack 
_FMulI_ret
_FMul_ret               ret

'------------------------------------------------------------------------------
' _FDiv    fnumA = fnumA / fNumB
' _FDivI   fnumA = fnumA / Float immediate
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'------------------------------------------------------------------------------

_FDivI                  movs    :getB, _FDivI_ret       ' get immediate value
                        add     _FDivI_ret, #1
:getB                   mov     fnumB, 0

_FDiv                   call    #_Unpack2               ' unpack two variables
          if_c_or_z     mov     fnumA, NaN              ' check for NaN or divide by 0
          if_c_or_z     jmp     #_FDiv_ret
        
                        xor     flagA, flagB            ' get sign of result
                        sub     expA, expB              ' subtract exponents
                        mov     t1, #0                  ' clear quotient
                        mov     t2, #30                 ' loop counter for divide

:divide                 shl     t1, #1                  ' divide the mantissas
                        cmps    manA, manB wz,wc
          if_z_or_nc    sub     manA, manB
          if_z_or_nc    add     t1, #1
                        shl     manA, #1
                        djnz    t2, #:divide

                        mov     manA, t1                ' get result and exit
                        call    #_Pack                        
_FDivI_ret
_FDiv_ret               ret

'------------------------------------------------------------------------------
' _FFloat  fnumA = float(fnumA)
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------
         
_FFloat                 mov     flagA, fnumA            ' get integer value
                        mov     fnumA, #0               ' set initial result to zero
                        abs     manA, flagA wz          ' get absolute value of integer
          if_z          jmp     #_FFloat_ret            ' if zero, exit
                        shr     flagA, #31              ' set sign flag
                        mov     expA, #31               ' set initial value for exponent
:normalize              shl     manA, #1 wc             ' normalize the mantissa 
          if_nc         sub     expA, #1                ' adjust exponent
          if_nc         jmp     #:normalize
                        rcr     manA, #1                ' justify mantissa
                        shr     manA, #2
                        call    #_Pack                  ' pack and exit
_FFloat_ret             ret

'------------------------------------------------------------------------------
' _FTrunc  fnumA = fix(fnumA)
' _FRound  fnumA = fix(round(fnumA))
' changes: fnumA, flagA, expA, manA, t1 
'------------------------------------------------------------------------------

_FTrunc                 mov     t1, #0                  ' set for no rounding
                        jmp     #fix

_FRound                 mov     t1, #1                  ' set for rounding

fix                     call    #_Unpack                ' unpack floating point value
          if_c          jmp     #_FRound_ret            ' check for NaN
                        shl     manA, #2                ' left justify mantissa 
                        mov     fnumA, #0               ' initialize result to zero
                        neg     expA, expA              ' adjust for exponent value
                        add     expA, #30 wz
                        cmps    expA, #32 wc
          if_nc_or_z    jmp     #_FRound_ret
                        shr     manA, expA
                                                       
                        add     manA, t1                ' round up 1/2 lsb   
                        shr     manA, #1
                        
                        test    flagA, #signFlag wz     ' check sign and exit
                        sumnz   fnumA, manA
_FTrunc_ret
_FRound_ret             ret
                                  
'------------------------------------------------------------------------------
' _FSqr    fnumA = sqrt(fnumA)
' changes: fnumA, flagA, expA, manA, t1, t2, t3, t4, t5 
'------------------------------------------------------------------------------

_FSqr                   call    #_Unpack                 ' unpack floating point value
          if_nc         mov     fnumA, #0                ' set initial result to zero
          if_c_or_z     jmp     #_FSqr_ret               ' check for NaN or zero
                        test    flagA, #signFlag wz      ' check for negative
          if_nz         mov     fnumA, NaN               ' yes, then return NaN                       
          if_nz         jmp     #_FSqr_ret
          
                        test    expA, #1 wz             ' if even exponent, shift mantissa 
          if_z          shr     manA, #1
                        sar     expA, #1                ' get exponent of root
                        mov     t1, Bit30               ' set root value to $4000_0000                ' 
                        mov     t2, #31                 ' get loop counter

:sqrt                   or      fnumA, t1               ' blend partial root into result
                        mov     t3, #32                 ' loop counter for multiply
                        mov     t4, #0
                        mov     t5, fnumA
                        shr     t5, #1 wc               ' get initial multiplier bit
                        
:multiply if_c          add     t4, fnumA wc            ' 32x32 bit multiply
                        rcr     t4, #1 wc
                        rcr     t5, #1 wc
                        djnz    t3, #:multiply

                        cmps    manA, t4 wc             ' if too large remove partial root
          if_c          xor     fnumA, t1
                        shr     t1, #1                  ' shift partial root
                        djnz    t2, #:sqrt              ' continue for all bits
                        
                        mov     manA, fnumA             ' store new mantissa value and exit
                        shr     manA, #1
                        call    #_Pack
_FSqr_ret               ret

'------------------------------------------------------------------------------
' _FCmp    set Z and C flags for fnumA - fNumB
' _FCmpI   set Z and C flags for fnumA - Float immediate
' changes: status, t1
'------------------------------------------------------------------------------

_FCmpI                  movs    :getB, _FCmpI_ret       ' get immediate value
                        add     _FCmpI_ret, #1
:getB                   mov     fnumB, 0

_FCmp                   mov     t1, fnumA               ' compare signs
                        xor     t1, fnumB
                        and     t1, Bit31 wz
          if_z          jmp     #:cmp1                  ' same, then compare magnitude
          
                        mov     t1, fnumA               ' check for +0 or -0 
                        or      t1, fnumB
                        andn    t1, Bit31 wz,wc         
          if_z          jmp     #:exit
                    
                        test    fnumA, Bit31 wc         ' compare signs
                        jmp     #:exit

:cmp1                   test    fnumA, Bit31 wz         ' check signs
          if_nz         jmp     #:cmp2
                        cmp     fnumA, fnumB wz,wc
                        jmp     #:exit

:cmp2                   cmp     fnumB, fnumA wz,wc      ' reverse test if negative

:exit                   mov     status, #1              ' if fnumA > fnumB, t1 = 1
          if_c          neg     status, status          ' if fnumA < fnumB, t1 = -1
          if_z          mov     status, #0              ' if fnumA = fnumB, t1 = 0
_FCmpI_ret
_FCmp_ret               ret

'------------------------------------------------------------------------------
' _Sin     fnumA = sin(fnumA)
' _Cos     fnumA = cos(fnumA)
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
' changes: t1, t2, t3, t4, t5, t6
'------------------------------------------------------------------------------

_Cos                    call    #_FAddI                 ' cos(x) = sin(x + pi/2)
                        long    pi / 2.0

_Sin                    mov     t6, fnumA               ' save original angle
                        call    #_FDivI                 ' reduce angle to 0 to 2pi
                        long    2.0 * pi
                        call    #_FTrunc
                        cmp     fnumA, NaN wz           ' check for NaN
          if_z          jmp     #_Sin_ret               
                        call    #_FFloat
                        call    #_FMulI
                        long    2.0 * pi
                        mov     fnumB, fnumA
                        mov     fnumA, t6
                        call    #_FSub

                        call    #_FMulI                 ' convert to 13 bit integer plus fraction
                        long    8192.0 / (2.0 * pi)
                        mov     t5, fnumA               ' get fraction
                        call    #_Frac
                        mov     t4, fnumA
                        mov     fnumA, t5               ' get integer
                        call    #_FTrunc
                        
                        test    fnumA, Sin_90 wc        ' set C flag for quandrant 2 or 4
                        test    fnumA, Sin_180 wz       ' set Z flag for quandrant 3 or 4
                        negc    fnumA, fnumA            ' if quandrant 2 or 4, negate offset
                        or      fnumA, SineTable        ' blend in sine table address
                        shl     fnumA, #1               ' get table offset

                        rdword  t2, fnumA               ' get first table value
                        negnz   t2, t2                  ' if quandrant 3 or 4, negate
                        add     fnumA, #2               ' get second table value
                        rdword  t3, fnumA
                        negnz   t3, t3                  ' if quandrant 3 or 4, negate

                        mov     fnumA, t2               ' result = float(value1)
                        call    #_FFloat

                        mov     fnumB, t4 wz            ' exit if no fraction
          if_z          jmp     #:sin2

                        mov     t5, fnumA               ' interpolate the fractional value 
                        mov     fnumA, t3
                        sub     fnumA, t2
                        call    #_FFloat 
                        call    #_FMul    
                        mov     fnumB, t5
                        call    #_FAdd

:sin2                   call    #_FDivI                 ' set range from -1.0 to 1.0 and exit
                        long    65535.0
_Cos_ret
_Sin_ret                ret

'------------------------------------------------------------------------------
' _Tan   fnumA = tan(fnumA)
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
' changes: t1, t2, t3, t4, t5, t6, t7, t8
'------------------------------------------------------------------------------

_Tan                    mov     t7, fnumA               ' tan(x) = sin(x) / cos(x)
                        call    #_Cos
                        mov     t8, fnumA
                        mov     fnumA, t7    
                        call    #_Sin
                        mov     fnumB, t8
                        call    #_FDiv
_Tan_ret                ret

'------------------------------------------------------------------------------
' _Log     fnumA = log (base e) fnumA
' _Log10   fnumA = log (base 10) fnumA
' _Log2    fnumA = log (base 2) fnumA
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2, t3, t5
'------------------------------------------------------------------------------

_Log                    call    #_Log2                  ' log base e
                        call    #_FDivI
                        long    1.442695041
_Log_ret                ret

_Log10                  call    #_Log2                  ' log base 10
                        call    #_FDivI
                        long    3.321928095
_Log10_ret              ret

_Log2                   call    #_Unpack                ' unpack variable 
          if_z_or_c     jmp     #:exitNaN               ' if NaN or <= 0, return NaN   
                        test    flagA, #SignFlag wz              
          if_nz         jmp     #:exitNaN
                      
                        mov     t5, expA                ' save exponent                                                
                        mov     t1, manA                ' get first 11 bits of fraction
                        shr     t1, #17                 ' get table offset
                        and     t1, TableMask
                        add     t1, LogTable            ' get table address
                        call    #float18Bits            ' remainder = lower 18 bits 
                        mov     t2, fnumA
                        call    #loadTable              ' get fraction from log table
                        mov     fnumB, fnumA
                        mov     fnumA, t5               ' convert exponent to float         
                        call    #_FFloat
                        call    #_FAdd                  ' result = exponent + fraction                               
                        jmp     #_Log2_ret

:exitNaN                mov     fnumA, NaN              ' return NaN

_Log2_ret               ret

'------------------------------------------------------------------------------
' _Exp     fnumA = e ** fnumA
' _Exp10   fnumA = 10 ** fnumA
' _Exp2    fnumA = 2 ** fnumA
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
' changes: t1, t2, t3, t4, t5
'------------------------------------------------------------------------------

_Exp                    call    #_FMulI                 ' e ** fnum
                        long    1.442695041
                        jmp     #_Exp2

_Exp10                  call    #_FMulI                 ' 10 ** fnum
                        long    3.321928095

_Exp2                   call    #_Unpack                ' unpack variable                    
          if_c          jmp     #_Exp2_ret              ' check for NaN
          if_z          mov     fnumA, One              ' if 0, return 1.0
          if_z          jmp     #_Exp2_ret

                        mov     t5, fnumA               ' save sign value
                        call    #_FTrunc                ' get positive integer
                        abs     t4, fnumA
                        mov     fnumA, t5
                        call    #_Frac                  ' get fraction
                        call    #_Unpack
                        neg     expA, expA              ' get first 11 bits of fraction
                        shr     manA, expA
                        mov     t1, manA                ' 
                        shr     t1, #17                 ' get table offset
                        and     t1, TableMask
                        add     t1, AlogTable           ' get table address
                        call    #float18Bits            ' remainder = lower 18 bits 
                        mov     t2, fnumA
                        call    #loadTable              ' get fraction from log table                  
                        call    #_FAddI                 ' add 1.0
                        long    1.0
                        call    #_Unpack                ' align fraction
                        mov     expA, t4                ' use integer as exponent  
                        call    #_Pack

                        test    t5, Bit31 wz            ' check if negative
          if_z          jmp     #_Exp2_ret
                        mov     fnumB, fnumA            ' yes, then invert
                        mov     fnumA, One
                        call    #_FDiv
_Exp_ret             
_Exp10_ret           
_Exp2_ret               ret

'------------------------------------------------------------------------------
' _Pow     fnumA = fnumA raised to power fnumB
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2, t3, t5, t6
'------------------------------------------------------------------------------

_Pow                    mov     t6, fnumB               ' save power
                        call    #_Log2                  ' get log of base
                        mov     fnumB, t6               ' multiply by power
                        call    #_FMul
                        call    #_Exp2                  ' get result      
_Pow_ret                ret

'------------------------------------------------------------------------------
' _Frac fnumA = fractional part of fnumA
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------

_Frac                   call    #_Unpack                ' get fraction
                        test    expA, Bit31 wz          ' check for exp < 0 or NaN
          if_c_or_nz    jmp     #:exit
                        max     expA, #23               ' remove the integer
                        shl     manA, expA    
                        and     manA, Mask29
                        mov     expA, #0                ' return fraction

:exit                   call    #_Pack
                        andn    fnumA, Bit31
_Frac_ret               ret

'------------------------------------------------------------------------------
' _FMod fnumA = fnumA mod fnumB
'------------------------------------------------------------------------------

_FMod                   mov     t4, fnumA               ' save fnumA
                        mov     t5, fnumB               ' save fnumB
                        call    #_FDiv                  ' a - float(fix(a/b)) * b
                        call    #_FTrunc
                        call    #_FFloat
                        mov     fnumB, t5
                        call    #_FMul
                        or      fnumA, Bit31
                        mov     fnumB, t4
                        andn    fnumB, Bit31
                        call    #_FAdd
                        test    t4, Bit31 wz            ' if a < 0, set sign
          if_nz         or      fnumA, Bit31
_FMod_ret               ret

'------------------------------------------------------------------------------
' input:   t1           table address (long)
'          t2           remainder (float) 
' output:  fnumA        interpolated table value (float)
' changes: fnumA, flagA, expA, manA, fnumB, t1, t2, t3
'------------------------------------------------------------------------------

loadTable               rdword  t3, t1                  ' t3 = first table value
                        cmp     t2, #0 wz               ' if remainder = 0, skip interpolation
          if_z          mov     t1, #0
          if_z          jmp     #:load2

                        add     t1, #2                  ' load second table value
                        test    t1, #tableMask wz       ' check for end of table
          if_z          mov     t1, #Bit16              ' t1 = second table value
          if_nz         rdword  t1, t1
                        sub     t1, t3                  ' t1 = t1 - t3

:load2                  mov     manA, t3                ' convert t3 to float
                        call    #float16Bits
                        mov     t3, fnumA           
                        mov     manA, t1                ' convert t1 to float
                        call    #float16Bits
                        mov     fnumB, t2               ' t1 = t1 * remainder
                        call    #_FMul
                        mov     fnumB, t3               ' result = t1 + t3
                        call    #_FAdd
loadTable_ret           ret

float18Bits             shl     manA, #14               ' float lower 18 bits
                        jmp     #floatBits
float16Bits             shl     manA, #16               ' float lower 16 bits
floatBits               shr     manA, #3                ' align to bit 29
                        mov     flagA, #0               ' convert table value to float 
                        mov     expA, #0
                        call    #_Pack                  ' pack and exit
float18Bits_ret
float16Bits_ret
floatBits_ret           ret

'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value
'          fnumB        32-bit floating point value 
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          flagB        fnumB flag bits (Nan, Infinity, Zero, Sign)
'          expB         fnumB exponent (no bias)
'          manB         fnumB mantissa (aligned to bit 29)
'          C flag       set if fnumA or fnumB is NaN
'          Z flag       set if fnumB is zero
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'------------------------------------------------------------------------------

_Unpack2                mov     t1, fnumA               ' save A
                        mov     fnumA, fnumB            ' unpack B to A
                        call    #_Unpack
          if_c          jmp     #_Unpack2_ret           ' check for NaN

                        mov     fnumB, fnumA            ' save B variables
                        mov     flagB, flagA
                        mov     expB, expA
                        mov     manB, manA

                        mov     fnumA, t1               ' unpack A
                        call    #_Unpack
                        cmp     manB, #0 wz             ' set Z flag                      
_Unpack2_ret            ret

'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value 
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          C flag       set if fnumA is NaN
'          Z flag       set if fnumA is zero
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------

_Unpack                 mov     flagA, fnumA            ' get sign
                        shr     flagA, #31
                        mov     manA, fnumA             ' get mantissa
                        and     manA, Mask23
                        mov     expA, fnumA             ' get exponent
                        shl     expA, #1
                        shr     expA, #24 wz
          if_z          jmp     #:zeroSubnormal         ' check for zero or subnormal
                        cmp     expA, #255 wz           ' check if finite
          if_nz         jmp     #:finite
                        mov     fnumA, NaN              ' no, then return NaN
                        mov     flagA, #NaNFlag
                        jmp     #:exit2        

:zeroSubnormal          or      manA, expA wz,nr        ' check for zero
          if_nz         jmp     #:subnorm
                        or      flagA, #ZeroFlag        ' yes, then set zero flag
                        neg     expA, #150              ' set exponent and exit
                        jmp     #:exit2
                                 
:subnorm                shl     manA, #7                ' fix justification for subnormals  
:subnorm2               test    manA, Bit29 wz
          if_nz         jmp     #:exit1
                        shl     manA, #1
                        sub     expA, #1
                        jmp     #:subnorm2

:finite                 shl     manA, #6                ' justify mantissa to bit 29
                        or      manA, Bit29             ' add leading one bit
                        
:exit1                  sub     expA, #127              ' remove bias from exponent
:exit2                  test    flagA, #NaNFlag wc      ' set C flag
                        cmp     manA, #0 wz             ' set Z flag
_Unpack_ret             ret       

'------------------------------------------------------------------------------
' input:   flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
' output:  fnumA        32-bit floating point value
' changes: fnumA, flagA, expA, manA 
'------------------------------------------------------------------------------

_Pack                   cmp     manA, #0 wz             ' check for zero                                        
          if_z          mov     expA, #0
          if_z          jmp     #:exit1

:normalize              shl     manA, #1 wc             ' normalize the mantissa 
          if_nc         sub     expA, #1                ' adjust exponent
          if_nc         jmp     #:normalize
                      
                        add     expA, #2                ' adjust exponent
                        add     manA, #$100 wc          ' round up by 1/2 lsb
          if_c          add     expA, #1

                        add     expA, #127              ' add bias to exponent
                        mins    expA, Minus23
                        maxs    expA, #255
 
                        cmps    expA, #1 wc             ' check for subnormals
          if_nc         jmp     #:exit1

:subnormal              or      manA, #1                ' adjust mantissa
                        ror     manA, #1

                        neg     expA, expA
                        shr     manA, expA
                        mov     expA, #0                ' biased exponent = 0

:exit1                  mov     fnumA, manA             ' bits 22:0 mantissa
                        shr     fnumA, #9
                        movi    fnumA, expA             ' bits 23:30 exponent
                        shl     flagA, #31
                        or      fnumA, flagA            ' bit 31 sign            
_Pack_ret               ret

'-------------------- constant values -----------------------------------------

Zero                    long    0                       ' constants
One                     long    $3F80_0000
NaN                     long    $7FFF_FFFF
Minus23                 long    -23
Mask23                  long    $007F_FFFF
Mask29                  long    $1FFF_FFFF
Bit16                   long    $0001_0000
Bit29                   long    $2000_0000
Bit30                   long    $4000_0000
Bit31                   long    $8000_0000
LogTable                long    $C000
ALogTable               long    $D000
TableMask               long    $0FFE
SineTable               long    $E000 >> 1
Sin_90                  long    $0800
Sin_180                 long    $1000

'-------------------- local variables -----------------------------------------

t1                      res     1                       ' temporary values
t2                      res     1
t3                      res     1
t4                      res     1
t5                      res     1
t6                      res     1
t7                      res     1
t8                      res     1

status                  res     1                       ' last compare status

fnumA                   res     1                       ' floating point A value
flagA                   res     1
expA                    res     1
manA                    res     1

fnumB                   res     1                       ' floating point B value
flagB                   res     1
expB                    res     1
manB                    res     1
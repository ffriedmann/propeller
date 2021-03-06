{
┌──────────────────────────────────────────────────────────┐
│      32- and 64-bit unsigned math routines in Spin.      │
│(c) Copyright 2008 Philip C. Pilgrim (propeller@phipi.com)│
│            See end of file for terms of use.             │
└──────────────────────────────────────────────────────────┘

This Propeller object provides the following unsigned integer math functions:

  div: Divides a 64-bit integer by a 32-bit integer to yield a 32-bit quotient.

  multdiv: Multiplies a 32-bit integer by the rational fraction formed by
    the ratio of two 32-bit numbers.

  unsigned comparisons: <, =<, =>, and >

}

CON

  UGT           = %100
  EQ            = %010
  ULT           = %001

VAR

  long  producth, productl

PUB multdiv(x, num, denom)

'' Multiply x by num, forming a 64-bit unsigned product.
'' Divide this by denom, returning the result.
'' x ** num must be less than (unsigned) denom.

  mult(x, num)
  return div(producth, productl, denom)   

PUB div(dvndh, dvndl, dvsr) | carry, quotient

'' Divide the 64-bit dividend, dvdnh:dvndl by the 32-bit divisor, dvsr,
'' returning a 32-bit quotient. Returns 0 on overflow.

  quotient~
  if (ge(dvndh, dvsr))
    return 0
  repeat 32
    carry := dvndh < 0
    dvndh := (dvndh << 1) + (dvndl >> 31)
    dvndl <<= 1
    quotient <<= 1
    if (ge(dvndh, dvsr) or carry)
      quotient++
      dvndh -= dvsr
  return quotient

PUB gt(x,y)

'' Return true if x > y unsigned.

  return cpr(x,y) & UGT <> 0

PUB ge(x,y)

'' Return true if x => y unsigned.

  return cpr(x,y) & constant(UGT | EQ) <> 0

PUB le(x,y)

'' Return true if x =< y unsigned.

  return cpr(x,y) & constant(ULT | EQ) <> 0

PUB lt(x,y)

'' Return true if x < y unsigned.

  return cpr(x,y) & ULT <> 0
  
PRI mult(mplr, mpld) | umplr, umpld

  producth := (mplr & $7fff_ffff) ** (mpld & $7fff_ffff)
  productl := (mplr & $7fff_ffff) * (mpld & $7fff_ffff)
  if (mplr < 0)
    dadd(producth, productl, mpld >> 1, mpld << 31)
  if (mpld < 0)
    dadd(producth, productl, mplr << 1 >> 2, mplr << 31)

PRI dadd(addh, addl, augh, augl)

  producth := addh + augh
  productl := addl + augl
  if (lt(productl, addl))
    producth++

PRI cpr(x, y)

  if (x == y)
    return EQ
  elseif (x ^ $8000_0000 > y ^ $8000_0000)
    return UGT
  else
    return ULT
    
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
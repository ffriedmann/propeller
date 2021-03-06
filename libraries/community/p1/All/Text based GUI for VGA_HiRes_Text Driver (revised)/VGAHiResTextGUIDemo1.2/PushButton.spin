'' ===========================================================================
''  VGA High-Res Text UI Elements Base UI Support Functions  v1.2
''
''  File: PushButton.spin
''  Author: Allen Marincak
''  Copyright (c) 2009 Allen MArincak
''  See end of file for terms of use
'' ===========================================================================
''
''============================================================================
'' Push Button Control
''============================================================================
''
'' Creates a straight forward pushbutton control.


OBJ
  SBOX          : "SimpleBox"


VAR
  word varGdx         'GUI control variable
  long varScreenPtr   'screen buffer pointer
  long varVgaPos      'starting position of the menu item
  byte varTextN[16]   'normal text, 15 chars MAX, with room for terminating Null
  byte varTextI[16]   'inverted text, 15 chars MAX, with room for terminating Null
  byte varRow         'top row location
  byte varCol         'left col location
  byte varCol2        'right col location
  byte varWidth       'width of text
  byte varVgaCols     'width of screen in columns
  

PUB Init( pRow, pCol, pTextPtr, pVgaPtr, pVgaWidth ) | strIdx

  varVgaCols    := pVgaWidth
  varRow        := pRow
  varCol        := pCol
  varScreenPtr  := pVgaPtr
  varWidth      := strsize( pTextPtr )+ 2
  varCol2       := varCol + varWidth - 1

  SBOX.DrawBox( pRow, pCol, varWidth, 3, 0, pVgaPtr, pVgaWidth )

  bytemove( @varTextN[0], pTextPtr, varWidth - 2 ) 'copy menu item text string

  strIdx := 0
  repeat varWidth-2
    varTextI[strIdx] := varTextN[strIdx]+128    'invert the string
    strIdx++

  varVgaPos := varRow * varVgaCols + varCol + varVgaCols + 1                                              
  bytemove( @byte[varScreenPtr][varVgaPos], varTextI, varWidth - 2 )
  
  
PUB DrawText( pMode )

  if pMode & 1
    bytemove( @byte[varScreenPtr][varVgaPos], @varTextI, varWidth-2 )
  else  
    bytemove( @byte[varScreenPtr][varVgaPos], @varTextN, varWidth-2 )
 

PUB IsIn( pCx, pCy ) : qq

  qq := false

    if ( pCx > varCol ) AND ( pCx < varCol2 )
      if pCy == varRow+1
        qq := true

  return qq


PUB SetText( pPtr ) | strIdx

  bytefill( @varTextN[0], 32, varWidth - 2 )    'clear it first
  bytemove( @varTextN[0], pPtr, strsize(pPtr) ) 'copy menu item text string
  
  strIdx := 0
  repeat varWidth-2
    varTextI[strIdx] := varTextN[strIdx]+128    'invert the string
    strIdx++ 
  bytemove( @byte[varScreenPtr][varVgaPos], varTextN, varWidth-2 )


PUB set_gzidx( gzidx )
  varGdx := gzidx


PUB get_gzidx
  return varGdx

  
{{
┌────────────────────────────────────────────────────────────────────────────┐
│                     TERMS OF USE: MIT License                              │                                                            
├────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy│
│of this software and associated documentation files (the "Software"), to    │
│deal in the Software without restriction, including without limitation the  │
│rights to use, copy, modify, merge, publish, distribute, sublicense, and/or │
│sell copies of the Software, and to permit persons to whom the Software is  │
│furnished to do so, subject to the following conditions:                    │
│                                                                            │
│The above copyright notice and this permission notice shall be included in  │
│all copies or substantial portions of the Software.                         │
│                                                                            │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  │
│IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    │
│FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE │
│AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     │
│FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS│
│IN THE SOFTWARE.                                                            │
└────────────────────────────────────────────────────────────────────────────┘
}}   
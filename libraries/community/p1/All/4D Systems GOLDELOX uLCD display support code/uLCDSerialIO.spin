{{
┌───────────────────────────────────────────────────┐
│ uLCDSerialIO.spin  version 1.0.0                  │
├───────────────────────────────────────────────────┤
│                                                   │               
│ Author: Mark M. Owen                              │
│                                                   │                 
│ Copyright (C)2015 Mark M. Owen                    │               
│ MIT License - see end of file for terms of use.   │                
└───────────────────────────────────────────────────┘

Description:

  Glue routines for serial transmissions to 4D systems uLCD display systems.

  Uses a slightly modified version of FullDuplexSerial incorporating a CTS pin
  for flow control, necessary as the 4D Systems displays tend to bog down during
  certain text and graphic operations and their serial communications driver
  throws away incoming information once its buffer is full.  The relevant code for
  this workaround is present in the display drivers, using the IO1 pin as CTS. The
  modifications to FullDuplexSerial are transparent to any process which does not
  need or want to use the CTS function.

  In general the uLCD displays use a protocol which involves sending one or more
  somethings to the display and waiting for the display to respond by sending an
  ACK.

Revision History:
  Initial release 2015-Feb-10

}}

CON
   ACK           = $06

OBJ
  FDS   : "FullDuplexSerial-wCTS"
  
PUB Start(rx,tx,rate,cts)
{{
    Initializes FUllDuplexSerial with a CTS (clear to send) function.

    Parameters:
      rx    receive data pin
      tx    transmit data pin
      rate  baud rate contant
      cts   clear to send pin
      
}}
  FDS.SetCTSpin(cts)
  FDS.Start(rx,tx,%0000,rate)   ' starts a cog
  ' if the above doesn't return > 0 we have a major problem
  ' we cannot easily deal with here... will probably hang (could abort trap it maybe?)
  waitcnt( 800_000 + cnt ) ' 10mS
  FDS.RxFlush
  waitcnt( 800_000 + cnt ) ' 10mS

PUB Stop
{{
    Terminates FUllDuplexSerial
}}
  FDS.Stop

PUB bSend(b)
{{
    Sends one byte.

    Parameters:
      b     the data byte to send
      
}}
  FDS.Tx(b)
             
PUB wSend(w) 'send word as two bytes MSB first
{{
    Sends one word (two bytes).

    Parameters:
    w      the data word to send
    
}}
  FDS.Tx(w>>8) ' MSB
  FDS.Tx(w)    ' LSB

PUB GetByte
{{
    Receives a byte and returns it to the caller.  Waits until a byte is received.
    
}}
  return FDS.Rx ' receive

PUB GetWord
{{
    Receives a word and returns it to the caller.  Waits until a word is received.
    
}}
  return FDS.Rx<<8 | FDS.Rx

PUB GetAck
{{
    Receives a byte and returns it or a timeout indication (-1) to the caller.
    If a byte is not received within 500mS or if the byte that is received is
    not an ACK ($06) the receive buffer is flushed.

}}
  result:=FDS.RxTime(500)
  if result == -1 or result <> ACK
    FDS.RxFlush ' timed out or incorrect response

PUB SendBytes(pbSource, bSize) | i' array
{{
    Sends and array of bytes.

    Parameters:
    pbSource    address of byte array to send
    bSize       number of bytes in the array
    

}}
  --bSize
  repeat i from 0 to bSize
    FDS.Tx(byte[pbSource][i])

PUB SendWords(pwSource, wSize)  | i ' array
{{
    Sends and array of words (two bytes each).

    Parameters:
    pwSource    address of word array to send
    wSize       number of words in the array
    
}}
  --wSize
  repeat i from 0 to wSize
    wSend(word[pwSource][i])

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
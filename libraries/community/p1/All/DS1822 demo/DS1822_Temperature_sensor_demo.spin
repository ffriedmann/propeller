{{┌──────────────────────────────────────────┐
  │ DS1822 Temperature sensor demo           │   
  │ Author: Chris Gadd                       │   
  │ Copyright (c) 2015 Chris Gadd            │   
  │ See end of file for terms of use.        │   
  └──────────────────────────────────────────┘
  Spin-based 1-wire driver for reading any number of externally or parasitically-powered DS1822 temperature sensors
  
  When parasitically-powered, the DQ line must have a strong pullup during temperature measurement and EEPROM writes
   For a single slave, or one slave at a time, it is possible to supply the strong pullup by setting DQ to output a high
   For simultaneous temperature measurements, an external circuit must be attached to a 2nd Prop pin

      Parasitically powered:                                 Externally powered:
               10K         ┌───┐ ┌───┐ ┌───┐ ┌───┐                      ┌───┐ ┌───┐ ┌───┐ ┌───┐
               10K   │  │    │DS │ │DS │ │DS │ │DS │                │     │ │DS │ │DS │ │DS │ │DS │
       Pullup───┻─  4K7 └┬┬┬┘ └┬┬┬┘ └┬┬┬┘ └┬┬┬┘                4K7  │ └┬┬┬┘ └┬┬┬┘ └┬┬┬┘ └┬┬┬┘
                      │  │     └┼┫   └┼┫   └┼┫   └┼┫                 │     └──┼┼┻───┼┼┻───┼┼┻───┼┼┘ 
           DQ──────┻──┻──────┻┼────┻┼────┻┼────┘│          DQ──┻────────┼┻────┼┻────┼┻────┼┘  
               1K                                             1K                          
}}                    
CON
  _clkmode = xtal1 + pll16x                                             
  _xinfreq = 5_000_000

CON
             
'ROM commands
  SEARCH_ROM   = $F0
  READ_ROM     = $33
  MATCH_ROM    = $55
  SKIP_ROM     = $CC
  ALARM_SEARCH = $EC

'Function commands
  CONVERT = $44     
  READ    = $BE     
  WRITE   = $4E     
  COPY    = $48     
  RECALL  = $B8     
  READ_P  = $B4

  CRC8    = $131
  SLAVES  = 11        ' Number of devices on bus
               
VAR

  long  _480us, _60us, DQ, PULLUP
  long  Tconv
  long  crc
  byte  rom_code[8 * SLAVES]
  byte  alarm_code[8 * SLAVES]
  byte  rx_array[9]
  byte  power
  
OBJ
  fds : "FullDuplexSerial"

PUB Demo | bank, devices, alarms, i

  init(7,4)                                               ' use pin 7 for DQ, pullup on 4 - pullup is only necessary for parasite power
  fds.start(31,30,0,115_200)
  waitcnt(cnt + clkfreq)
  fds.tx($00)
  fds.tx($01)

  SkipROM
  if ReadPower
    fds.str(string("Extenally powered",$0D))
  else
    fds.str(string("Parasitically powered",$0D))

  devices := SearchROM                                     ' Read the ROM codes of all devices on the bus into the rom_code arrays
  fds.dec(devices)                                         ' Store the number of codes found into devices
  fds.str(string(" devices detected",$0D))

  repeat bank from 0 to devices - 1
    fds.str(string("ROM code: "))
    repeat i from 0 to 7                                   '   Family code       Checksum
      fds.hex(rom_code[bank * 8 + i],2)                    '   │  ┌─Serial number┐  │    
      fds.tx(" ")                                          '                         
    fds.tx($0D)                                            '   22 B6 1B 3F 00 00 00 FE   

  SetResolution(12)                                        ' Set 12-bit resolution
  SetAlarm(100,23)                                         ' Upper alarm at 100°C, lower at 23°C
  SkipROM                                                  ' Write the same resolution and alarm limits to every sensor                         
  WriteScratch                                                                                                                                  
' SkipROM                                                  ' Store resolution and alarm limits in the EEPROM of every sensor                    
' CopyScratch                                                                                                                                   
                                                                                                                                                
  waitcnt(cnt + clkfreq)                                                                                                                        
                                                                                                                                                
  repeat                                                                                                                                        
    SkipROM                                                ' Start temperature measurement on all sensors                                       
    repeat until ConvertTemp                                                                                                                    
    fds.tx($00)                                                                                                                                 
    repeat bank from 0 to devices - 1                                                                                                           
      MatchROM(bank)
      DecF((ReadTemp * 625), 10_000, 3)                    ' The conversion is temp * 625 / 10_000, regardless of resolution                    
      fds.str(string("°C",$0D))                            

    if alarms := AlarmSearch                               ' Check for alarms
      repeat bank from 0 to alarms - 1
        fds.str(string(" Alarm on: "))
        fds.dec(CompareROM(bank))                          ' Find the rom code index of the device in alarm
        fds.tx($09)        
        repeat i from 0 to 7                      
          fds.hex(alarm_code[bank * 8 + i],2)              ' Display the rom code of the device in alarm
          fds.tx(" ")
        fds.tx($0D)

PRI DecF(value,divider,places) | i, x                   '' Display a value to a specified number of decimal places
{
  DecF(1234,100,3) displays "12.340"
}
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

PUB Init(DQ_pin, pullup_pin)
  DQ := DQ_pin
  PULLUP := pullup_pin                                  
  _480us := clkfreq / 1_000_000 * 480
  _60us  := clkfreq / 1_000_000 * 60
  
PUB ReadROM | i                                         '' Find the address of a single 1-wire device - do not use if multiple devices are on the bus
  crc := 0
  _reset
  _Tx(READ_ROM)
  repeat i from 0 to 7                                  
    rom_code[i] := _Rx
  if crc == 0
    return true    

PUB MatchROM(bank) | i                                  '' Address a specific 1-wire device      
  _reset
  _Tx(MATCH_ROM)
  repeat i from 0 to 7
    _TX(rom_code[bank * 8 + i])

PUB SearchROM                                           '' Find the unique ID of every device on the bus
  return SearchDevices(@rom_code,SEARCH_ROM)

PUB AlarmSearch                                         '' Find the unique ID of every device in alarm
  bytefill(@alarm_code,0,SLAVES * 8)
  return SearchDevices(@alarm_code,ALARM_SEARCH)
  
PRI searchDevices(dest,command) : numFound | q1, q2, bit, rom[2], disc, discMark
'' search method based on Micah Dowty's SpinOneWire object
  
  longfill(@rom,0,2)
  numFound~
  disc := -1

  repeat
    _Reset
    _Tx(command)
    discMark~
    crc~
    repeat bit from 0 to 63
      dira[DQ] := 1                                     ' 1st read slot                                                                                            
      dira[DQ] := 0                                                                                                                                                
      q1 := ina[DQ]                                                                                                                                                
      waitcnt(cnt + _60us)
      dira[DQ] := 1                                     ' 2nd read slot                                                                                            
      dira[DQ] := 0                                                                                                                                                
      q2 := ina[DQ]                                                                                                                                                
      waitcnt(cnt + _60us)
      if q1 == 0 and q2 == 0                            ' Conflict detected when both read slots read 0                                  
        if bit > disc                                   ' Following a new code                                                           
          rom[bit / 32] &= !1 <- bit                    '  store a 0 for this location                                                   
          discMark := bit                               '  Remember this location
        elseif bit == disc                              ' Follow an alternate code                                                       
          rom[bit / 32] |= 1 << bit                     '  store a 1 for this location                                                   
        elseif (rom[bit / 32] >> bit) & 1 == 0          ' Following an existing code                                                     
          discMark := bit                               '  Only remember this location if 0 was stored in previous iteration             
      elseif q1 == 1 and q2 == 1                        ' This check indicates that no devices are in alarm                              
        return false                                    '  should never happen during a ROM code search                                  
      else                                              ' No conflict                                                                    
        rom[bit / 32] &= !1 <- bit                      '  store result of first read slot
        rom[bit / 32] |= q1 << bit
      waitcnt(cnt + _60us)                              ' Write slot              
      if (rom[bit / 32] >> bit) & 1 == 1                ' Send a 1 or a 0 as stored in this location
        dira[DQ] := 1                                                             
        dira[DQ] := 0                                                             
        waitcnt(cnt + _60us)                                                      
      else                                                                        
        dira[DQ] := 1                                                             
        waitcnt(cnt + _60us)                                                      
        dira[DQ] := 0                                                             
      crc := crc << 1 | ((rom[bit / 32] >> bit) & 1)    ' Update the crc
      if crc & $100                                                  
        crc ^= CRC8
    if crc == 0
      longmove(dest,@rom,2)
      dest += 8
      numFound++
      disc := discMark
      if disc == 0 or numFound == SLAVES
        return numFound
    else                                                ' CRC invalid
      longmove(@rom,dest,2)                             ' restore previous read and try again
        
PUB SkipROM                                             '' Address every 1-wire device on the bus
  _reset
  _Tx(SKIP_ROM)

PUB ConvertTemp : Ready                                 '' Measure the temperature 
  if power
    _Tx(CONVERT)            
    repeat until ready                                  ' Poll DQ if externally powered
      dira[DQ] := 1                                     
      dira[DQ] := 0                                     
      ready := ina[DQ]      
      waitcnt(cnt + _60us)  
  else                                                  ' Wait a fixed time if parasitically powered
    _Tx(CONVERT)
    dira[PULLUP] := 1
'   outa[DQ] := dira[DQ] := 1                           ' Use DQ to supply the strong pull-up 
    waitcnt(cnt + Tconv)                                '  only works when reading a single sensor
'   outa[DQ] := dira[DQ] := 0                           ' An external pull-up circuit must be used for simultaneous measurement on multiple sensors
    dira[PULLUP] := 0
    return true

PUB CopyScratch : Ready                                 '' Store resolution and alarm limits in EEPROM
  if power
    _Tx(COPY)               
    repeat until ready                                  ' Poll DQ if externally powered                 
      dira[DQ] := 1                                                                                     
      dira[DQ] := 0                                                                                     
      ready := ina[DQ]                                                                                  
      waitcnt(cnt + _60us)                                                                              
  else                                                  ' Wait 10ms if parasitically powered            
    _Tx(COPY)
    dira[PULLUP] := 1
'   outa[DQ] := dira[DQ] := 1                           ' DQ is able to supply this for simultaneous writes
    waitcnt(cnt + clkfreq / 100)
    dira[PULLUP] := 0
'   outa[DQ] := dira[DQ] := 0
    return true

PUB WriteScratch                                        '' Set resolution and alarm limits
  _Tx(WRITE)
  _Tx(rx_array[2])
  _Tx(rx_array[3])
  _Tx(rx_array[4])
    
PUB ReadScratch | i                                     '' Read the temperature, alarm limits, configuration, and crc
  crc := 0
  _Tx(READ)
  repeat i from 0 to 8
    rx_array[i] := _Rx
  if crc == 0
    return true

PUB ReadTemp                                            '' Only read the temperature from the scratchpad, returns an immediate result
  _Tx(READ)
  result := (_Rx | _Rx << 8)
  return ~~result
    
PUB RecallEeprom : Ready                                '' Restore resolution and alarm limits from EEPROM
  _Tx(RECALL)
  repeat until ready
    dira[DQ] := 1
    dira[DQ] := 0
    ready := ina[DQ]
    waitcnt(cnt + _60us)  
  
PUB ReadPower                                           '' Determine if the devices use external or parasitic power

  _Tx(READ_P)
  dira[DQ] := 1
  dira[DQ] := 0
  result := Power := ina[DQ]                            ' DQ is low if parasitically-powered
  waitcnt(cnt + _60us)

PUB SetResolution(reso)                                 '' Set the resolution to 9, 10, 11, or 12 bits
'' Not effective until written using WriteScratch

  if 8 < reso < 13
    rx_array[4] := (reso - 9) << 5 | %0_00_11111
    
  case reso                             ' Tconv is only used when parasitically-powered, DQ is polled when externally-powered
    9:  Tconv := clkfreq / 1000 * 94    '  9-bit = 0.5000°C, 93.75ms
    10: Tconv := clkfreq / 1000 * 188   ' 10-bit = 0.2500°C, 187.5ms
    11: Tconv := clkfreq / 1000 * 375   ' 11-bit = 0.1250°C, 375ms  
    12: Tconv := clkfreq / 1000 * 750   ' 12-bit = 0.0625°C, 750ms  
    
PUB SetAlarm(high,low)                                  '' Set the upper and lower alarm limits
'' Alarms use 8-bit resolution, each lsb represents 1°C
'' Not effective until written using WriteScratch

  rx_array[2] := high
  rx_array[3] := low

PUB CompareROM(bank) | idx ,i                           '' Returns the index of the rom code bank matching the code in the alarm bank

  repeat idx from 0 to SLAVES - 1
    repeat i from 0 to 7
      if rom_code[idx * 8 + i] <> alarm_code[bank * 8 + i]
        quit
      if i == 7
        return idx
  return -1

PRI _Reset : ready | t                                  '' Send a reset pulse and detect a presence pulse

  dira[DQ] := 1
  waitcnt(cnt + _480us)                              
  dira[DQ] := 0
  waitcnt(cnt + _60us)                                 
  ready := ina[DQ] ^ 1                                  '  DQ is low if a 1-wire device is present
  waitcnt(cnt + _480us)                             

PRI _Tx(txByte)                                         '' Transmit one byte

  repeat 8
    if txByte & 1
      dira[DQ] := 1                                   
      dira[DQ] := 0
      waitcnt(cnt + _60us)                                     
    else
      dira[DQ] := 1
      waitcnt(cnt + _60us)
      dira[DQ] := 0
    txByte >>= 1                                        ' bits are sent lsb first
    
PRI _Rx : rxByte | q, i                                 '' Receive one byte

  repeat i from 0 to 7
    dira[DQ] := 1                                                                     
    dira[DQ] := 0                                       
    q := ina[DQ]
    rxByte |= q << i
    crc := crc << 1 | q
    if crc & $100
      crc ^= CRC8    
    waitcnt(cnt + _60us)

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
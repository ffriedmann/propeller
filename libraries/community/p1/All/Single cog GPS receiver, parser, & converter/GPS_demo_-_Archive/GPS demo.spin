{{┌──────────────────────────────────────────┐
  │ GPS receiver and parser demo             │
  └──────────────────────────────────────────┘
}}                                                                                                                                                
CON                
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000

  GPS_PIN = 1
  BAUD = 4800

OBJ
  fds    : "FullDuplexSerial"
  gps    : "GPS parser 1.03"
  gen    : "GPS generator"

PUB start | ch, i
  fds.start(31,30,0,115200)
  gen.start(GPS_PIN,BAUD)
  gps.start(GPS_PIN,BAUD)

  repeat
    waitcnt(clkfreq + cnt)
    repeat until gps.setlock
    fds.tx($00)
    fds.str(string("Time:",$09))                    
    fds.str(gps.timePtr)                            
    fds.str(string($0D,"Date:",$09))                
    fds.str(gps.datePtr)                            
    fds.str(string($0D,"Lat:",$09))                 
    fds.str(gps.latPtr)                             
    fds.tx($09)
    fds.str(fDecStr(gps.latVal,10_000_000,6))           ' divide by 10_000_000 and show to 6 decimal places 
    fds.tx($09)                                                                                                    
    fds.str(fDecStr(gps.latVal_minutes,100_000,5))      ' divide by 100_000 to show minutes and decimal minutes    
    fds.str(string($0D,"Lon:",$09))                 
    fds.str(gps.lonPtr)                             
    fds.tx($09)                                     
    fds.str(fDecStr(gps.lonVal,10_000_000,6))           
    fds.tx($09)                             
    fds.str(fDecStr(gps.lonVal_minutes,100_000,5))      
    fds.str(string($0D,"Alt:",$09))                 
    fds.str(gps.altPtr)                             
    fds.tx($09)                                     
    fds.tx($09)                                     
    fds.dec(gps.altVal)                             
    fds.str(string($0D,"Crs:",$09))                 
    fds.str(gps.crsPtr)                             
    fds.tx($09)                                     
    fds.tx($09)                                     
    fds.dec(gps.crsVal)                             
    fds.str(string($0D,"Speed:",$09))               
    fds.str(gps.spdPtr)                             
    fds.tx($09)                                     
    fds.dec(gps.spdVal)                     
    fds.str(string($0D,"Status:",$09))                                                                          
    fds.tx(gps.getStatus)
    fds.str(string($0D,"Sats:",$09))
    fds.dec(gps.satsVal)
    gps.unlock                                      

DAT
  str_ptr byte          "-123.456789",0
  str_ind byte          0

PUB fDecStr(value,divider,places) | div, ipart, fpart
  str_ind := 0
  
  if value < 0
    || value                                            ' If negative, make positive
    append("-")                                         ' and output sign
  
  div := 1_000_000_000                                  ' Initialize divisor
  ipart := value / divider
  fpart := value // divider

  repeat 10                                             ' Loop for 10 digits
    if ipart => div                                                             
      append(ipart / div + "0")                         ' If non-zero digit, output digit
      ipart //= div                                     ' and remove digit from value
      result~~                                          ' flag non-zero found
    elseif result or div == 1
      append("0")                                       ' If zero digit (or only digit) output it
    div /= 10                                           ' Update divisor

  if places <> 0
    append(".")
    repeat places 
      fpart *= 10
      append(fpart / divider // 10 + "0")
      fpart //= divider
  append(0)
  return @str_ptr

PRI append(char)
  str_ptr[str_ind++] := char
       
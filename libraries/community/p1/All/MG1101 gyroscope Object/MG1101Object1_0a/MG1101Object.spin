{{

┌──────────────────────────────────────────┐
│ MG1101Object Object 1.0                  │
│ Author: Eric Ratliff                     │               
│ Copyright (c) 2008 Eric Ratliff          │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

MG1101Object, for using a Gyration MG1101 dual axis gyroscope
Revision History:
 -> V1.0 first version 2008.10.12 by Eric Ratliff

patterned avter James Burrows' MD22 object

tested with MG1101B gyroscope salvaged from mouse

this object provides the major PUBLIC functions:
StartupGyro, MeasureAndSetAxisOffsets, getAxisRetults, getVoltageRetults_mV, and getTemperatureRetults_C
other public functions allow access to lower level details

this object uses the following sub OBJECTS:
 -> basic_i2c_driver

the gyro addresses are not (to my knowledge) changable, so there are no parameters to spedify this

Connection of I2C bus to Propeller Chip and MG1101 dual axis gyroscope

                                20K                          1    3.3V
                            ┌──────  3.3V        MG1101B───────┘  
                            │ ┌────  3.3V        │ │   └───────┐     
                            │ │                     3│ │2   4,5    0V
 Prop Pin n+1  SDA   ───────┻─┼──────────────────────┻─┼──          
                              │                        │        
 Prop Pin n    SCL   ─────────┻────────────────────────┻──      

for MG-1101 documentation, see http://www.gyration.co.kr/product/images/DE01300-001%20Data%20Sheet%20MG1101%20RevA.pdf

}}

CON
'' 
  MG1101_EEPROM_Addr            = %1010_0000            ' adds lsb of 0 compared to MG1101 doc
  MG1101_Gyro_Addr              = %1010_1110            ' adds lsb of 0 compared to MG1101 doc
  CalByteCount                  = 16                    ' how many bytes in calibration constant list
  CalBytesEERegister            = 0                     ' where in EEPROM to find calibration bytes
  CalBytesGyroRegister          = 0                     ' where in Gyro device to find calibration bytes

  ' Gyro device control regiester constants
  CNTRL_Address                 = $0F                   ' control register address in write area of gyro device
  CNTRL_INIT                    = %0100_0000            ' the initialize bit
  CNTRL_Reserved                = %0000_1000            ' the reserved bit of the control register
  ' power modes
  CNTRL_PMD_Sleep               = %0000_0000            ' sleep
  CNTRL_PMD_Full                = %0000_0001            ' full operation
  CNTRL_PMD_TVOnly              = %0000_0010            ' temperature and voltage reading only
  CNTRL_PMD_WaitingForMotion    = %0000_0011            ' vibrate, but don't measure vibrations
  CNTRL_PMD_TestAndCal          = %0000_0100            ' factory testing and calibration (reserved)
  CNTRL_PMD_RemainSleepingA     = %0000_0101            ' stay in sleep mode
  CNTRL_PMD_RemainSleepingB     = %0000_0110            ' stay in sleep mode
  CNTRL_PMD_Reset               = %0000_0111            ' reset all functions to power up state
  ' Gyro status register
  STATUS_Address                = $08                   ' status register address in read area of gyro device
  STATUS_PC                     = %0000_0001            ' power cycle bit mask
  STATUS_GRNR                   = %0000_0010            ' GyRo Not Ready bit mask, for when vibrating beam is starting and rotation read devices are starting
  STATUS_TRNR                   = %0000_1000            ' TRansition Not Ready bit mask, for settling after power commands
  GRNR_WaitOK                   = -1                    ' GRNR wait function return result code
  ' Gyro transducer registers
  GyroDataByteCount             = 9                     ' how many bytes in gyro sensor data + status register
  GyroDataRegister              = 0                     ' were gyro sensor data starts
  AxisResultBaseRegister        = GyroDataRegister      ' where in gyro data the axis result registers begin
  AxisResultByteCount           = 4                     ' how many bytes in gyro sensor data
  NominalLSBperDegPerSecP2      = 5                     ' nominal sensitivity of gyro rate, how many least significant bits for 1 degree per second rate (2**n)
  NominalLSBperDegPerSec        = 2 << NominalLSBperDegPerSecP2 ' nominal sensitivity of gyro rate, how many least significant bits for 1 degree per second rate
  VoltageResultBaseRegister     = GyroDataRegister+4    ' where in gyro data the power supply voltage result register begins
  VoltageResultByteCount        = 2                     ' how many bytes in voltage data
  NominalMicroVoltsPerLSB       = 4_885                 ' slope 1/Vslope of data sheet (uV/LSB)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
  TemperatureResultBaseRegister = GyroDataRegister+6    ' where in gyro data the axis result registers begin
  TemperatureResultByteCount    = 2                     ' how many bytes in temperature data
  NominalMicroKelvinsPerLSB     = 195_503               ' slope 1/Vslope of data sheet (uK/LSB)
  MicroCelciusOffset            = -73_150_431           ' to convert from micro Kelvins to micro Celcius's with sensor's offset included
  LoseUpper6BitsMask            = %00000011             ' to get rid of 1's that come in unused upper 6 MSBs of voltage and temperature
  NominalAxesOffset             = $8000

OBJ
  i2cObject     : "basic_i2c_driver"

VAR
  long  YawOffset
  long  PitchOffset                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
  byte  CalConstants[CalByteCount]                      ' calibration constants for gyro chip
  
PUB StartupGyro(i2cSCL):ResultCode
    ' setup i2cobject
    i2cObject.Initialize(i2cSCL)

    ' read calibration constants from EEPROM of gyro
    getStoredCalibrationConstants(i2cSCL,@CalConstants[0])

    ' write cal constants
    writeCalConstantsToRam(i2cSCL,@CalConstants[0])
    
    ' set gyro initialize bit
    setGyroIinitalizeBit(i2cSCL)
    
    ' set power mode to full operation
    setGyroPowerFull(i2cSCL)

    ' poll not ready bit until it is cleared
    ResultCode := WaitForGyroReady(i2cSCL)

PUB getStoredCalibrationConstants(i2cSCL,pCalByteArray)
  '' first step after power on
  '' first argumant is clock pin
  '' second argumant should show first address of 16 byte array to put values into
  ReadSmallModelPage(i2cSCL,MG1101_EEPROM_Addr,CalBytesEERegister,pCalByteArray,CalByteCount)

PUB writeCalConstantsToRam(i2cSCL,pCalByteArray)
  '' second step after power on
  '' first argumant is clock pin
  '' second argumant should show first address of 16 byte array to put values into
  WriteSmallModelPage(i2cSCL,MG1101_Gyro_Addr,CalBytesGyroRegister,pCalByteArray,CalByteCount)

PUB setGyroIinitalizeBit(i2cSCL)
  '' argument is clock pin
  WriteSmallModelByte(i2cSCL,MG1101_Gyro_Addr,CNTRL_Address,CNTRL_Reserved | CNTRL_INIT | CNTRL_PMD_RemainSleepingA)

PUB setGyroPowerFull(i2cSCL)
  '' argument is clock pin
  WriteSmallModelByte(i2cSCL,MG1101_Gyro_Addr,CNTRL_Address,CNTRL_Reserved | CNTRL_PMD_Full)

PUB WaitForGyroReady(i2cSCL) | StatusByte, NotReady, GiveUpTime, TimedOut
  '' argument is clock pin
  GiveUpTime := clkfreq*3 + cnt
  TimedOut := false
  repeat
    StatusByte := ReadSmallModelByte(i2cSCL,MG1101_Gyro_Addr,STATUS_Address)
    NotReady := StatusByte & (STATUS_GRNR | STATUS_TRNR) ' not vibrating or not powered up?
    if GiveUpTime-cnt < 0
      TimedOut := true
      quit
  while NotReady
  if TimedOut
    result := StatusByte
  else
    result := GRNR_WaitOK

PUB getAllGyroData(i2cSCL,pGyroDataByteArray)
  '' first argumant is clock pin
  '' second argumant should show first address of 16 byte array to put values into
  ReadSmallModelPage(i2cSCL,MG1101_Gyro_Addr,GyroDataRegister,pGyroDataByteArray,GyroDataByteCount)

PUB SetAxisOffsets(YawOff,PitchOff)
  '' set these from still atate axis rate readings for later subtraction to get signed rates
  YawOffset := YawOff
  PitchOffset := PitchOff
  
PUB GetAxisOffsets(pYawOff,pPitchOff)
  '' reports axis rate offsets in use (LSBs)
  LONG[pYawOff] := YawOffset
  LONG[pPitchOff] := PitchOffset
  
PUB MeasureAndSetAxisOffsets(i2cSCL)
  '' call when gyro is known to be still and you want to calibrate it
  ' an improvement would be to do several readings 33 ms apart and average them
  ' zero out offsets so we can get raw reading
  YawOffset := 0
  PitchOffset := 0
  ' get raw reading and store it right back into the offsets
  getAxisRetults(i2cSCL,@YawOffset,@PitchOffset)
  
PUB getAxisRetults(i2cSCL,pYawRate,pPitchRate)|AxisDataCombo,YawHiByte,YawLoByte,PitchHiByte,PitchLoByte
  '' first argumant is clock pin
  '' results are put into yaw and pitch rates (nominal units are 1/32 degree per second)

  ReadSmallModelPage(i2cSCL,MG1101_Gyro_Addr,AxisResultBaseRegister,@AxisDataCombo,AxisResultByteCount)
  YawHiByte := BYTE[@AxisDataCombo]
  YawLoByte := BYTE[(@AxisDataCombo)+1]
  PitchHiByte := BYTE[(@AxisDataCombo)+2]
  PitchLoByte := BYTE[(@AxisDataCombo)+3]
  LONG[pYawRate] := ((YawHiByte << 8) + YawLoByte) - YawOffset
  LONG[pPitchRate] := ((PitchHiByte << 8) + PitchLoByte) - PitchOffset

PUB getVoltageRetults(i2cSCL,pVoltageData)|BigEndianVolts
  '' this routine public to give user access to maximum resolution data
  '' first argumant is clock pin
  '' second argument is pointer to long to put EMF in (LSBs)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
  '' results come to 10 least significant bits of the 16 bit word, tells supply voltage to the device
  '' nominally 4.89 mV per bit, nominally $170 (368 decimal) = 1.8V, nominally $2E1 (737 decimal) = 3.6V
  '' measurement range is 1.8 to 3.6V
  ' get raw voltage bytes
  ReadSmallModelPage(i2cSCL,MG1101_Gyro_Addr,VoltageResultBaseRegister,@BigEndianVolts,VoltageResultByteCount)
  MaskAndSwap10Bits(@BigEndianVolts,pVoltageData)

PUB getVoltageRetults_mV(i2cSCL,pVoltageData)| PowerEMF_LSBs
  '' first argumant is clock pin
  '' second argument is pointer to long to report supply voltage to the device (mV)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
  '' measurement range is nominally 1.8 to 3.6V
  getVoltageRetults(i2cSCL,@PowerEMF_LSBs)
  LONG[pVoltageData] := (PowerEMF_LSBs * NominalMicroVoltsPerLSB) / 1000 ' convert LSBs to micorvolts, then millivolts

PUB getTemperatureRetults(i2cSCL,pTemperatureData)|BigEndianTemperature
  '' this routine public to give user access to maximum resolution data
  '' first argumant is clock pin
  '' second argumant should show first address of 2 byte array to put value into
  '' results come to 10 least significant bits of the 16 bit word, tells the temperature inside the device
  '' nominally .196 C per bit, nominally $15C (348 decimal) = -5C, nominally $28F (655 decimal) = 55C
  ' get raw temperature bytes
  ReadSmallModelPage(i2cSCL,MG1101_Gyro_Addr,TemperatureResultBaseRegister,@BigEndianTemperature,TemperatureResultByteCount)
  MaskAndSwap10Bits(@BigEndianTemperature,pTemperatureData)

PUB getTemperatureRetults_C(i2cSCL,pTemperatureData)|Temperature_LSBs
  '' first argumant is clock pin
  '' second argumant should show first address to put temperature result into (C)
  '' nominal range -5C to 55C
  getTemperatureRetults(i2cSCL,@Temperature_LSBs)       ' get temperature in units of Least Significant Bits
  LONG[pTemperatureData] := (Temperature_LSBs * NominalMicroKelvinsPerLSB + MicroCelciusOffset) / 1_000_000 ' convert LSBs to micorCelcius, then Celcius

PUB MaskAndSwap10Bits(pBigEndian,pLittleEndian10)|HiByte,LoByte
  '' gets rid of six false 1's in high byte, swaps high and low bytes, clears unused highest two bytes
  '' used for preparing voltage and temperature data
  HiByte := LoseUpper6BitsMask & BYTE[pBigEndian]
  LoByte := BYTE[pBigEndian+1]
  LONG[pLittleEndian10] := ((HiByte << 8) + LoByte)  

PUB ReadSmallModelPage(SCL, addrDev, addrReg, dataPtr, count) : ackbit
'' Read in a block of i2c data.
'' 7 bit address of device is in bits 7 to 1 of addrDev, which is padded with a zero least significant bit
'' address within device is addrReg, 8 bits.
'' Data address is at pData. Number of bytes is count.
'' Return zero if no errors or the acknowledge bits if an error occurred.
   i2cObject.Start(SCL)                ' Select the device & send address
   ackbit := i2cObject.Write(SCL, addrDev | i2cObject#Xmit)
   ackbit := (ackbit << 1) | i2cObject.Write(SCL, addrReg & $FF)
   i2cObject.Start(SCL)                ' Reselect the device for reading
   ackbit := (ackbit << 1) | i2cObject.Write(SCL, addrDev | i2cObject#Recv)
   repeat count - 1
      byte[dataPtr++] := i2cObject.Read(SCL, i2cObject#ACK)
   byte[dataPtr++] := i2cObject.Read(SCL, i2cObject#NAK)
   i2cObject.Stop(SCL)
   return ackbit

PUB ReadSmallModelByte(SCL, addrDev, addrReg) : data
'' Read in a single byte of i2c data.
'' 7 bit address of device is in bits 7 to 1 of addrDev, which is padded with a zero least significant bit
'' address within device is addrReg, 8 bits.
'' returns the read byte or -1 long if failure
   if ReadSmallModelPage(SCL, addrDev, addrReg, @data, 1)
      return -1

PRI WriteSmallModelPage(SCL, addrDev, addrReg, pData, count) : ackbit
'' Write out a block of i2c data.
'' 7 bit address of device is in bits 7 to 1 of addrDev, which is padded with a zero least significant bit
'' address within device is addrReg, 8 bits.
'' Data address is at pData. Number of bytes is count.
'' Return zero if no errors or the acknowledge bits if an error occurred.  If
'' more than 31 bytes are transmitted, the sign bit is "sticky" and is the
'' logical "or" of the acknowledge bits of any bytes past the 31st.
   i2cObject.Start(SCL)                ' Select the device & send address
   ackbit := i2cObject.Write(SCL, addrDev | i2cObject#Xmit)
   ackbit := (ackbit << 1) | i2cObject.Write(SCL, addrReg & $FF)
   repeat count                        ' Now send the data
      ackbit := ackbit << 1 | ackbit & $80000000 ' "Sticky" sign bit         
      ackbit |= i2cObject.Write(SCL, byte[pData++])
   i2cObject.Stop(SCL)
   return ackbit

PRI WriteSmallModelByte(SCL, addrDev, addrReg, Data)
'' Write out a single byte of i2c data. 
'' 7 bit address of device is in bits 7 to 1 of addrDev, which is padded with a zero least significant bit
'' address within device is addrReg, 8 bits.
   if WriteSmallModelPage(SCL, addrDev, addrReg, @data, 1)
      return true
   ' james edit - wait for 5ms for page write to complete (80_000 * 5 = 400_000)      
   waitcnt(400_000 + cnt)      
   return false

          
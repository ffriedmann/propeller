{{=========================================================================== 

** VGM music player **

AUTHOR: Francesco de Simone, www.digimorf.com
LAST MODIFIED: 17.10.2012
VERSION 2.7

FILENAME: VGM_Player_027

COMMENTS: This player parse an array in memory and drives the chip SN76489 according to
VGM PSG music format.
More at http://www.smspower.org/Music/VGMFileFormat?from=Development.VGMFormat

HARDWARE REQUIREMENT:
Parallax Propeller C3 Board,
AUDIO SET for audio output,
Serial terminal program for keyboard emulation

LICENSE: See end of file for terms of use

===========================================================================

 After the program has been uploaded to C3, just open the serial terminal
 by pressing F12 within Propeller Tool, and press return to start within
 the terminal.

 Make sure that terminal program has been configured with the same baud rate
 of this program.
 
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000 ' final clock of 80Mhz
          
  SAMPLE_RATE = 44100
  startPos = 64 ' end of VGM header

  ' Status led
  STATUS_LED_BUS_MUX = 15
  C3AudioPin = 24

  SECTOR_SIZE           = 512         ' should always be 512 for SD cards                  
  MAX_SECTORS_BUFFER    = 1           ' number of sectors buffer can hold, make larger if needed 

  BLACK = 0
  WHITE = 1
  GREEN = 2
  RED = 3
  statusLineY = 12
  
  PAL  = %0001
  NTSC = %0000

  Video_Pins = %001_0101   ''pin location for video out
 
  ''used for video driver
  SCANLINE_BUFFER        = $7F00    
  request_scanline       = SCANLINE_BUFFER-4  'address of scanline buffer for TV driver
  tilemap_adr            = SCANLINE_BUFFER-8  'address of tile map
  tile_adr               = SCANLINE_BUFFER-12 'address of tiles
  border_color           = SCANLINE_BUFFER-16 'address of border color 

  ' ASCII codes for ease of parser development
  ASCII_1      = 49
  ASCII_2      = 50
  ASCII_LEFT   = 52  ' 4 = left on keypad
  ASCII_RIGHT  = 54  ' 6 = right on keypad  
  ASCII_LF     = $0A ' carriage return
  ASCII_CR     = $0D ' carriage return
  ASCII_ESC    = $CB ' escape
  ASCII_NULL   = $00 ' null character
   
  down_drop = 50 ''how much to deduct from drop clock when pushing down - NTSC
  ''50 ''how much to deduct from drop clock when pushing down - NTSC
  ''42 ''how much to deduct from drop clock when pushing down - PAL
' --------------------------------------------------------------------------      
VAR
long playback, pause, framerate, head, end

long filehandle[4] ' generic file handle first_cluster, file_length, curr_pos, directory_entry
byte filename[13]
long parPtr
byte progr

byte SD_DISK_buff[2048] ' generic disk sector buffer

long params
long play
long Tile_Map_Adr ''address to tilemap for graphics driver
long new_clock '' what to reset drop clock to
long Game_State
long musicnameptr
long io_command
' --------------------------------------------------------------------------                  
OBJ
spi  : "Cog_SPI_Driver_014"
psg  : "SN76489_031"
vdp  : "JTC_Tile_Drv"
keyboard : "Serial keyboard 010"
' --------------------------------------------------------------------------    
PUB Main | msg, n
    pauseMSec( 2000 )
     
    initObject
    n := bootPlayer
    
    if n == 0          
      repeat
        loadMusic 
        playMusic  
    else
      repeat
' --------------------------------------------------------------------------          
PUB initObject
    Tile_Map_Adr := LONG[ CONSTANT($7F00-8) ] 'grab address of tile map
    
    vdp.start( Video_Pins, NTSC, 5, 15 ) 'start graphics driver
    vdp.set_border_color( 14 )
    vdp.clr_screen ( 61 )
     
    spi.SPI_Start
    spi.SPI_Set_Channel( 0 )
    
    psg.start( @io_command )
    
    keyboard.Start(115200)
                
    pauseMSec( 1000 )
    musicnameptr := 0
' --------------------------------------------------------------------------         
PUB bootPlayer | tempVal, index, i
    showBootScreen
    pauseMSec( 500 )
        
    ' --------------------------------------------------------------------------
    Icon ( 2, 7, 8 )
    vdp.print_string( 11, 9, STRING("SRAM test"))
     
    tempVal := spi.SRAM_Init
    
    if tempVal == 3
      Icon ( 0, 21, 9 )  
    else
      Icon ( 1, 21, 9 )
      return ( $FF )

    pauseMSec( 1000 )
                                 
    ' --------------------------------------------------------------------------
    Icon ( 3, 7, 11 ) 
    vdp.print_string( 11, 12, STRING("SD Card test"))
            
    tempVal := spi.SD_Mount( 0, 0, 0 ) ' pass dummy data for asm
    
    if tempVal == 0
      Icon ( 0, 24, 12 )  
    else
      Icon ( 1, 24, 12 )
      return ( $FF )

    pauseMSec( 1000 )        
    ' --------------------------------------------------------------------------
    vdp.print_string( 11, 13, STRING("SD Card init"))
            
    parPtr := spi.SD_Init 
    
    if parPtr > 0
      Icon ( 0, 24, 13 )  
    else
      Icon ( 1, 24, 13 )
      return ( $FF )

    push_button( 12, 16, 1 )
    waitButton( 1 )
    
    return ( 0 )
      
' --------------------------------------------------------------------------
PUB loadMusic | tempVal, index, i
    showLoadScreen
            
    repeat i from 0 to 12
      filename[i] := byte[@names+musicnameptr][i]

    vdp.print_string( 7, 8, STRING("VGM Player loading"))
    vdp.print_string( 10, 9, @filename )

    spi.SD_FAT_File_Open( @filename, @filehandle )
       
    load_bar ( 8, 11, 15, 0 )
                             
    repeat index from 0 to 15
      filehandle[2] := index*2048                      
      spi.SD_FAT_File_Read( @filehandle, @SD_DISK_buff[0], 2048 )
      spi.SRAM_Wr_block( 0, index*2048, 2048, @SD_DISK_buff[0] )
      spi.SPI_Set_Channel(5)
      load_bar( 8, 11, 15, index )
        
    spi.SD_FAT_File_Close( @filehandle )         
' --------------------------------------------------------------------------                                                                   
PUB playMusic | continue, wait, datacache0, i, button1, pos, joy_status, playpos

  vdp.print_string( 7, 8, STRING("     Playing      ")) 
  vumeter( 11, 14, 8, 0 ) 
  play_bar( 8, 11, 16, 0, 1 )
  interface( 6, 17 )
      
  play := true
  pause := 0
  head := startPos
  end := false
  button1 := 0
  pos := 0
  playpos := 0
    
  spi.SPI_Set_Channel( 1 ) 
  spi.SRAM_Write_Read( 24, $FF, ( %00000011 << 16 )| startPos )
  i := 0
                                 
  repeat until end
    if play == true
      if ( i > $1FF )
        i := 0
        play_bar ( 8, 11, 16, head >> 11, 1 )
        
      if head > 32767
        head := 0
        musicnameptr += 13
        if musicnameptr > 143
           musicnameptr := 0
         
        pauseMSec( 200 ) 
        spi.SPI_Set_Channel( 0 )
        spi.SPI_Set_Channel( 1 ) 
        spi.SRAM_Write_Read( 24, $FF, ( %00000011 << 16 )| startPos )
        end := true
           
      if pause > 0
        waitcnt( wait + cnt )
       
      datacache0 := spi.SRAM_Write_Read( 8, $FF, $FF )
                                                                                                               
      case datacache0                                                                                                                                                                                        
        $50:
             PSGwrite( spi.SRAM_Write_Read( 8, $FF, $FF ) ) 
             head := head + 2
             i := i + 2
             pause := 0
             vumeter( 13, 14, pos++ & $3, 1 ) 
                                                                                                                                                                                                 
        $61:   
             wait := spi.SRAM_Write_Read( 8, $FF, $FF )                                                  
             wait := ( constant( 80_000_000 / SAMPLE_RATE ) * ( wait | ( spi.SRAM_Write_Read( 8, $FF, $FF ) << 8 )))                                  
             head := head + 3
             i := i + 3
             pause := 1
                                                                                                                                                                                           
        $62:
             wait := constant( 80_000_000 / SAMPLE_RATE ) * 735            
             head := head + 2
             i := i + 2
             pause := 1  
                                                                                                                                                               
        $63:
             wait := constant( 80_000_000 / SAMPLE_RATE ) * 882       
             head := head + 2
             i := i + 2
             pause := 1              
                                       
        $66:
          head := 0
          musicnameptr += 13
          if musicnameptr > 143
            musicnameptr := 0
           
          pauseMSec( 200 )
          end := true
          spi.SPI_Set_Channel( 0 )
          spi.SPI_Set_Channel( 1 )
          spi.SRAM_Write_Read( 24, $FF, ( %00000011 << 16 )| startPos )
                            
        other:
             head := head + 1
             i := i + 1
             pause := 0
           
    check_keyboard
  
  spi.SPI_Set_Channel( 0 )
  spi.SPI_Set_Channel( 1 ) 
  spi.SRAM_Write_Read( 24, $FF, ( %00000011 << 16 )| 0 )
  spi.SPI_Set_Channel(5)
  
  '' ----------------------------------------------------------------------------------       
PUB getReturn
    draw_box ( 8, 15, 16, 3, 1 )
    vdp.print_string( 9, 16, STRING("Press [RETURN]"))
    Get_Key
        
'' ----------------------------------------------------------------------------------      
PUB pauseMSec ( msec )
    waitcnt (( 80_000 * msec ) + cnt )
    
'' ----------------------------------------------------------------------------------
PUB Get_Key | g_key
{┌────────────────────────────────────────────────┐
 │ Start driver on a cog and set starting values  │
 └────────────────────────────────────────────────┘} 
  repeat
    g_key := keyboard.CharIn
     
    case g_key
      ASCII_CR:
        return ( g_key )                            
            
'' ----------------------------------------------------------------------------------
PUB check_keyboard | kbd

    kbd := keyboard.CharRx
    
    if kbd > 0
      case kbd
        ASCII_RIGHT:
          musicnameptr += 13
           if musicnameptr > 338
              musicnameptr := 0
                                       pauseMSec( 200 ) 
          end := true
          
        ASCII_LEFT:
          musicnameptr -= 13
          if musicnameptr < 0
             musicnameptr := 338
             
          pauseMSec( 200 )          
          end := true
          
        ASCII_2: 
          pauseMSec( 200 )          
          showCredits
       
        ASCII_1:
          if play 
            play := false
            play_bar ( 8, 11, 16, head >> 11, 0 )
          else
            play := true
            play_bar ( 8, 11, 16, head >> 11, 1 )
             
          pauseMSec( 200 )

'' ----------------------------------------------------------------------------------                       
PUB playSound ( sndPtr ) | continue, wait, datacache0, pos

  head := 0
  end := false                                                 
  pos := sndPtr
          
  repeat until end
    if pause > 0
      waitcnt( wait + cnt )
      
    datacache0 := snd_startup[head]
                                                                                                        
    case datacache0                                                                                                                                                                                        
      $50:
           PSGwrite( datacache0 := snd_startup[head+1] ) 
           head := head + 2
           pause := 0   
                                                                                                                                                                                               
      $61:   
           wait := snd_startup[head]                                                   
           wait := ( constant( 80_000_000 / SAMPLE_RATE ) * ( wait | ( snd_startup[head+1] << 8 )))                                  
           head := head + 3
           pause := 1
                                                                                                                                                                                         
      $62:
           wait := constant( 80_000_000 / SAMPLE_RATE ) * 735            
           head := head + 2
           pause := 1  
                                                                                                                                                             
      $63:
           wait := constant( 80_000_000 / SAMPLE_RATE ) * 882       
           head := head + 2
           pause := 1              
                                     
      $FF:
          end := true         
                          
      other:
           head := head + 1
           pause := 0

'' ----------------------------------------------------------------------------------  
PUB PSGwrite ( data )
    io_command := $01_00_7F_00 | data
    repeat while io_command & $FF000000 > 0
           
'' ---------------------------------------------------------------------------------- 
PUB showBootScreen  | n
    draw_box ( 2, 0, 28, 23, 0 )
    pauseMSec( 300 )   
    aniLogo ( 8, 9, 0, -7, 9 )
    vdp.print_string( 7, 20, STRING("VGM Player 2.7"))
    vdp.print_string( 12, 21, STRING("Digimorf"))
  
'' ----------------------------------------------------------------------------------   
PUB showLoadScreen  | n
    vdp.erase_area( 3, 6, 19, 12, 0 )  
    draw_box ( 5, 7, 22, 12, 1 )
        
'' ----------------------------------------------------------------------------------
PUB showCredits | r
    vdp.erase_area( 3, 1, 26, 21, 0 )
    aniLogo ( 8, 2, 0, 4, 0 )
    vdp.print_string( 6, 12, STRING("www.c3emulation.com"))
    vdp.print_string( 6, 14, STRING("      PARALLAX"))
    vdp.print_string( 6, 15, STRING("   Nurve Networks"))
    
    repeat while 1
      r := 0
'' ----------------------------------------------------------------------------------      
PUB aniLogo ( x, y, dx, dy, sndstart )| iy
  repeat iy from y to y+dy
    vdp.erase_area( x, iy-1, 16, 6, 0 )
    Icon ( 4, x, iy )  ' prop c3
    Icon ( 5, x+7, iy ) ' propeller
    Icon ( 6, x+9, iy+1 ) ' powered
    vdp.print_string( 15, iy+3, STRING("Emulation"))
    
    pauseMSec( 50 )
    
    if iy == sndstart
      playSound ( @snd_startup )                     
       
'' ----------------------------------------------------------------------------------
PUB Wait_Vsync ''wait until frame is done drawing
   repeat while long[ $7F00 - 4 ] <> 191
   
'' ---------------------------------------------------------------------------------- 
PUB Int_To_String(adr, i) | t
  adr+=3
  repeat t from 0 to 3
    BYTE[adr] := ( i // 10 ) + 48
    i/=10
    adr--
    
'' ----------------------------------------------------------------------------------
PUB waitButton( n ) | button
  button := 0
  repeat until button
    button := ( not INA[6-n] ) & 1 
    
'' ----------------------------------------------------------------------------------     
PRI draw_box ( x, y, w, h, s ) | ix, iy, idx, d
  d := ( s * 8 ) + 1 + s
  idx := 52 + d 
  
  ix := x
  iy := y
  
  vdp.place_tile_xy( ix++, iy, idx )
  repeat w - 2
    vdp.place_tile_xy( ix++, iy, idx+1 )
  vdp.place_tile_xy( ix, iy++, idx+2 )
  
  repeat h - 2
    ix := x  
    vdp.place_tile_xy( ix++, iy, idx+7 )
    repeat w - 2
      vdp.place_tile_xy( ix++, iy, 0 )    
    vdp.place_tile_xy( ix, iy++, idx+3 )
    
  ix := x 
  vdp.place_tile_xy( ix++, iy, idx+6 )
  repeat w - 2
    vdp.place_tile_xy( ix++, iy, idx+5 )
  vdp.place_tile_xy( ix, iy++, idx+4 )
'' ----------------------------------------------------------------------------------  
PRI load_bar ( x, y, w, p ) | ix, iy, idx, o 
  idx := 73
  ix := x
  iy := y
  
  vdp.place_tile_xy( ix++, iy, idx )
  
  repeat w - 2
    vdp.place_tile_xy( ix++, iy, idx+1 )  

  vdp.place_tile_xy( ix, iy, idx+2 )

  idx := 70
  if p > 1
    vdp.place_tile_xy( x, y, idx )
    
    repeat o from x+1 to x+p-1
      vdp.place_tile_xy( o, y, idx+1 )
      
    if p < w-1
      vdp.place_tile_xy( p+x, y, idx+6 )
    else                   
      vdp.place_tile_xy( w+x-1, y, idx+2 )

'' ----------------------------------------------------------------------------------
PRI play_bar ( x, y, w, p, i ) | ix, iy, idx, o 
  idx := 94
  ix := x
  iy := y
  
  vdp.place_tile_xy( ix++, iy, idx )
  repeat w - 2
    vdp.place_tile_xy( ix++, iy, idx+1 )
  vdp.place_tile_xy( ix, iy, idx+2 )

  if p > 1 
    vdp.place_tile_xy( x+p-1, y, idx+1 )
    vdp.place_tile_xy( x+p, y, idx+4-i )
  else                 
    vdp.place_tile_xy( x+p, y, idx+4-i )
    
'' ----------------------------------------------------------------------------------                 
PRI push_button( x, y, num ) | l, idx, t, vu
    vdp.print_string( x, y, STRING("Push"))
    Icon ( 7 + num - 1, x+5, y-1 )
    
'' ----------------------------------------------------------------------------------
PRI interface( x, y ) | l, idx, ix
    idx := 99
    ix := x
    
    vdp.place_tile_xy( ix++, y, idx )
    vdp.place_tile_xy( ix++, y, idx+1 )
    repeat l from 110 to 114
      vdp.place_tile_xy( ix++, y, l )       
    ix+=2
    
    vdp.place_tile_xy( ix++, y, idx+4 )
    repeat l from 105 to 109
      vdp.place_tile_xy( ix++, y, l )       
    ix+=2   
    
    vdp.place_tile_xy( ix++, y, idx+5 )
    vdp.place_tile_xy( ix++, y, 115 )
    vdp.place_tile_xy( ix++, y, 116 )
    
'' ----------------------------------------------------------------------------------              
PRI vumeter( x, y, num, upd ) | l, idx, t, vu
  idx := 78 ' starting pointer for VU meter tiles
  
  if upd ' if this flag is on ( 1 ) updates only levels
    vu := cnt
    l := idx + ||( vu? // 7 )  
    vdp.place_tile_xy( x+num, y, l )
  else ' otherwise draw the only the starting window
    draw_box ( x-1, y-1, 12, 3, 1 )
    vdp.print_string( 19, y, STRING("VU"))
    repeat num
      vdp.place_tile_xy( x++, y, idx )
           
'' ----------------------------------------------------------------------------------
PRI ShowPic ( n, x, y )

'' ----------------------------------------------------------------------------------       
PRI Icon ( n, x, y ) | ix, iy, idx
  case n
    0: ' OK
      idx := 1
      vdp.place_tile_xy( x, y, idx )

    1: ' BAD
      idx := 2
      vdp.place_tile_xy( x, y, idx )

    2: ' SRAM
      idx := 3
      repeat ix from 0 to 2
        repeat iy from 0 to 2
          vdp.place_tile_xy( x+ix, y+iy, idx++ )

    3: ' SD
      idx := 12
      repeat ix from 0 to 2
        repeat iy from 0 to 2
          vdp.place_tile_xy( x+ix, y+iy, idx++ )

    4: ' logo
      idx := 21
      ix := x
      iy := y
      repeat 4
        vdp.place_tile_xy( ix, iy++, idx++ )
      iy := y
      ix := ix + 1
      vdp.place_tile_xy( ix, iy, idx++ )
      iy := y + 3
      vdp.place_tile_xy( ix, iy, idx++ )
      iy := y
      
      repeat ix from 0 to 3
        repeat iy from 0 to 3
          vdp.place_tile_xy( x+2+ix, y+iy, idx++ )      

    5: ' propeller
      idx := 43
      repeat ix from 0 to 1
        repeat iy from 0 to 1
          vdp.place_tile_xy( x+ix, y+iy, idx++ )
          
    6: ' powered
      idx := 47
      repeat ix from 0 to 5
        vdp.place_tile_xy( x+ix, y, idx++ )
        
    7: ' button1
      idx := 86
      repeat ix from 0 to 1
        repeat iy from 0 to 1
          vdp.place_tile_xy( x+ix, y+iy, idx++ )
          
    8: ' button2
      idx := 90
      repeat ix from 0 to 1
        repeat iy from 0 to 1
          vdp.place_tile_xy( x+ix, y+iy, idx++ )
                                                                       
'' ----------------------------------------------------------------------------------         
DAT
names
byte "batman.vgm  ",0  
byte "beans.vgm   ",0  
byte "blues.vgm   ",0  
byte "BonusZ1.vgm ",0  
byte "conflict.vgm",0  
byte "darklab.vgm ",0  
byte "Fire.vgm    ",0  
byte "forest.vgm  ",0  
byte "Fyrajave.vgm",0  
byte "GrassVal.vgm",0  
byte "HitEnt.vgm  ",0  
byte "insurm.vgm  ",0  
byte "Kicking.vgm ",0       
byte "lizards.vgm ",0  
byte "Matador.vgm ",0  
byte "Mission2.vgm",0  
byte "mycar.vgm   ",0  
byte "offradio.vgm",0  
byte "phoenix.vgm ",0  
byte "prehistr.vgm",0  
byte "radio.vgm   ",0  
byte "somewher.vgm",0  
byte "SpaceBat.vgm",0  
byte "TheMonk.vgm ",0  
byte "ThePark.vgm ",0     
byte "Ultra.vgm   ",0
                  
snd_startup       
byte  $61, $00, $FF  ' "ping sound effect"                                
byte  $50, %10011111, $50, $8E, $50, $3
                  
byte  $50, %10010001, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62
byte  $50, %10010010, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62        
byte  $50, %10010011, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10010100, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10010101, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10010110, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10010111, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10011000, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10011001, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10011010, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10011011, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10011100, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10011101, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10011110, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62         
byte  $50, %10011111, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62
byte  $50, %10111111, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62
byte  $50, %11011111, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62
byte  $50, %11111111, $61, $00, $0A, $62, $62, $62, $62, $62, $62, $62, $62    
byte  $FF                            
                        
{{
  ______________________________________________________________________________________________________________________________
 |                                                   TERMS OF USE: MIT License                                                  |                                                            
 |______________________________________________________________________________________________________________________________|
 |Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    |       
 |files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    |
 |modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software|
 |is furnished to do so, subject to the following conditions:                                                                   |
 |                                                                                                                              |
 |The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.|
 |                                                                                                                              |
 |THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          |
 |WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         |
 |COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   |
 |ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         |
 --------------------------------------------------------------------------------------------------------------------------------
 }}
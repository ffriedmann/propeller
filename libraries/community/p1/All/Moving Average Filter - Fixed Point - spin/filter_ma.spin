{{ filter_ma.spin
┌─────────────────────────────────────┬────────────────┬─────────────────────┬───────────────┐
│ Moving Average Filter v1.0          │ BR             │ (C)2010             │  6 Nov 2010   │
├─────────────────────────────────────┴────────────────┴─────────────────────┴───────────────┤
│ A simple moving average filter, implemented in spin.  Two versions of the same basic       │
│ filter are provided:                                                                       │
│       •4-point moving average filter                                                       │
│       •16-point moving average filter                                                      │
│                                                                                            │
│ Recommended reading if you want to understand how these filters work: www.dspguide.com     │
│                                                                                            │
│ USAGE:                                                                                     │
│    filtered_msmnt_out := <filter_obj_name>.<filtername>(raw_msmnt_in)                      │
│                                                                                            │
│    where: raw_msmnt_in       = the raw data to be filtered                                 │
│           filtername         = method name, e.g.: "ma4", "conv16", "kalman1", etc.         │
│           filter_obj_name    = instance name of this object                                │
│           filtered_msmnt_out = filtered output                                             │
│                                                                                            │
│    So for example, to use the 4-point moving average filter:                               │
│           filtered_out := ma4(raw_in)                                                      │
│                                                                                            │
│ NOTES:                                                                                     │
│ •This filter is best suited for low-to-moderate bandwidth filtering applications           │
│  (e.g. filtering accelerometer or Ping))) data).                                           │
│ •Uses a ring buffer to hold the measurement data history.  The buffers are initialized to  │
│  zero, so the first few values returned from these filters may be suspect until the        │
│  buffers are fully populated with measurement data (4 or 16 filter function calls required │
│  to do this).                                                                              │
│ •No integer overflow/underflow detection logic is provided.  It is up to the user to       │
│  ensure that filter kernels and filter data input are scaled appropriately.                │
│                                                                                            │
│ See end of file for terms of use.                                                          │
└────────────────────────────────────────────────────────────────────────────────────────────┘
}}


pub ma4(x_meas):x_ret
''4-sample moving average filter, implemented with recursion.
''Max filter update rate ~13000 samples/sec for 1 cog @ clkfreq=80

  ptr &= %00000011                         'mask off all but lower two bits
  sum := sum + x_meas - x_buf4[ptr]
  x_buf4[ptr] := x_meas
  x_ret := sum ~> 2                        'divide sum by 4
  ptr++
  
 
pub ma16(x_meas):x_ret
''16-sample moving average filter, implemented with recursion.
''Max filter update rate ~13000 samples/sec for 1 cog @ clkfreq=80

  ptr &= %00001111                         'mask off all but lower four bits
  sum := sum + x_meas - x_buf16[ptr]
  x_buf16[ptr] := x_meas
  x_ret := sum ~> 4                        'divide sum by 16
  ptr++
  
 
dat                                
'-----------[ Predefined variables and constants ]-----------------------------
x_buf4         long      0,0,0,0           '4-place filter input history buffer
x_buf16        long      0,0,0,0,0,0,0,0   '16-place filter input history buffer
               long      0,0,0,0,0,0,0,0   
sum            long      0
ptr            byte      0                 'pointer (set up as ring buffer)



DAT

{{

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     TERMS OF USE: MIT License                                       │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and    │
│associated documentation files (the "Software"), to deal in the Software without restriction,        │
│including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,│
│and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,│
│subject to the following conditions:                                                                 │
│                                                                                                     │                        │
│The above copyright notice and this permission notice shall be included in all copies or substantial │
│portions of the Software.                                                                            │
│                                                                                                     │                        │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT│
│LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  │
│IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION│
│WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}  
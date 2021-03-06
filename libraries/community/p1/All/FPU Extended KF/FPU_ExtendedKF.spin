{{
┌──────────────────────────┬───────────────────────┬─────────────────────┐
│ FPU_ExtendedKF.spin v2.0 │   Author: I.Kövesdi   │ Rel.: 27 April 2009 │
├──────────────────────────┴───────────────────────┴─────────────────────┤
│                    Copyright (c) 2009 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│  Assuming that a discrete system has n states, m inputs and r outputs, │
│ this application provides the user a general coding framework of       │
│ Extended Kalman filter using the following notations and definitions:  │
│                                                                        │
│                  x(k+1) = F[x(k), u(k)] + w(k)  State equation         │
│                                                 that can be nonlinear  │
│                                                                        │ 
│                    y(k) = H[x(k)] + z(k)        Measurement equation   │
│                                                 that can be nonlinear  │
│                                                                        │
│ where                                                                  │
│                                                                        │
│ x is a [n-by-1] vector          Estimated state vector                 │
│ k is the time index                                                    │   
│ F is a [n-by-1] vector func.    System model function. This is actually│
│                                 a set of n functions, there is a       │
│                                 function for each component of the     │
│                                 state vector:                          │
│                                                                        │
│                                            F1[x(k), u(k)],             │
│                                                 ...,                   │
│                                            Fn[x(k), u(k)])             │
│                                                                        │ 
│ u is a [m-by-1] vector          Known control input to the system      │
│ w                               process noise, only it's statistics    │
│                                 known. It is "calculated" only during  │
│                                 simulations. In real applications it is│
│                                 just a notation, we don't have to code │
│                                 it, to remind us that it might be      │
│                                 there.                                 │
│ y is a [r-by-1] vector          Measured output, i.e. sensor readings  │
│ H is a [r-by-1] vector func.    Measurement model function. This is a  │
│                                 set of r functions                     │
│                                                                        │
│                                                H1[x(k)],               │
│                                                  ...,                  │
│                                                Hr[x(k)])               │ 
│                                                                        │ 
│ z                               Measurement noise, only its statistics │
│                                 known. It is "calculated" only during  │
│                                 simulations. During real filtering we  │
│                                 do not have to care about it. Nature   │
│                                 will generate it for us.               │
│                                                                        │
│ If either the state equation or the measurement equation has nonlinear │
│ terms, then the system is called a nonlinear system.                   │
│                                                                        │
│ The w and z noise vectors are described by their covariance matrices:  │
│                                                                        │ 
│    Sw is a [n-by-n] matrix  Process noise covariance matrix            │
│    Sz is a [r-by-r] matrix  Measurement noise covariance matrix        │
│                                                                        │
│ which are the expected values of the corresponding covariance products:│
│                                                                        │
│    Sw = E[w(k) * wT(k)]       (estimated and fixed before calculation) │
│    Sz = E[z(k) * zT(k)]       (estimated and fixed before calculation) │
│                                                                        │
│  In order to use an Extended Kalman filter we need to find the         │
│ derivatives of                                                         │
│                                                                        │
│                            F1[x(k), u(k)],                             │
│                                 ...,                                   │
│                            Fn[x(k), u(k)])                             │
│                                                                        │
│ and                                                                    │
│                                                                        │
│                               H1[x(k)],                                │
│                                 ...,                                   │
│                               Hr[x(k)])                                │                                                                          
│                                                                        │
│ State and Measurement functions with respect to                        │
│                                                                        │
│                              x1, ..., xn                               │
│                                                                        │
│ and then to evaluate them at the state estimate x(k). The derivative of│
│ F with respect to x is expressed as a [n-by-n] matrix                  │
│                                                                        │
│                    ┌                       ┐                           │
│                    │ dF1/dx1, ..., dF1/dxn │                           │
│                    │          ...,         │ = A                       │
│                    │ dFn/dx1, ..., dFn/dxn │                           │
│                    └                       ┘                           │
│                                                                        │ 
│ Note that the effect of control inputs u(k) is implicitly encoded into │
│ the A matrix as the F1, ..., Fn functions, and so the derivatives,     │
│ depend on u(k) at each time step k.                                    │
│ The derivative of H with respect to x is expressed as a [r-by-n] matrix│
│                                                                        │
│                    ┌                       ┐                           │
│                    │ dH1/dx1, ..., dH1/dxn │                           │
│                    │          ...,         │ = C                       │
│                    │ dHr/dx1, ..., dHr/dxn │                           │
│                    └                       ┘                           │
│                                                                        │
│ After the evaluation these matrices at the current state estimate x(k),│
│ we obtain the A and C matrices that contain only numbers. With these   │
│ matrices we can setup the  Kalman filter equations:                    │
│                                                                        │
│    K(k) = A * P(k) * CT * Inv[C * P(k) * CT + Sz]                      │
│                                                                        │
│  x(k+1) = F[x(k), u(k)] + K(k) * [y(k) - H[x(k)]]                      │
│                                                                        │
│  P(k+1) = A * P(k) * AT + Sw - A * P(k) * CT * Inv(Sz) * C * P(k) * AT │
│                                                                        │
│ where                                                                  │
│                                                                        │
│           K(k)   [n-by-r] Kalman gain matrix                           │
│           P(k)   [n-by-n] estimation error covariance matrix           │
│                                                                        │
│  Contrary to the linear case, here the A and C matrices usually change │
│ from timestep to timestep, aLONG with the state of the system, adapting│
│ the filter to the nonlinearity of the F and H functions. Consequently, │
│ the time evolution of the P and K matrices now depends on the actual   │
│ time evolution of the states.                                          │
│                                                                        │ 
├────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                 │
│  Perhaps the most famous application of Kalman filters to date was     │
│ guiding the Apollo spacecraft to the Moon. Rocket engineers have to    │
│ reconcile a spacecraft's current sensor readings with differential     │
│ equations that tell them where it ought to be, based on their knowledge│
│ of its past. When the designers of Apollo needed a way to blend these  │
│ two sources of information, they found it in Kalman filters which were │
│ developed for those missions. Those filters were actually  Extended    │
│ Kalman filters for nonlinear systems, i.e. for spacecraft navigation.  │
│ Since then, the Kalman filter became a reliable computational workhorse│
│ of inertial guidance systems for airplanes and  spacecrafts. During the│
│ last three decades it has found other applications in hundreds of      │
│ diverse areas, including all forms of navigation, demographic modeling,│
│ nuclear plant instrumentation, robotics, weather prediction, just to   │
│ mention a few.                                                         │
│  The idea behind Kalman filters can be tracked back to least-squares   │
│ estimation theory by (K)arl (F)riedrich Gauss. With his words:         │
│                                                                        │
│ "...But since all our measurements and observations are nothing more   │
│ than approximations to the truth, the same must be true for all        │
│ calculations resting upon them, and the highest aim of all computations│
│ concerning concrete phenomena must be to approximate, as nearly as     │
│ practicable, to the truth. ... This problem can only be properly       │
│ undertaken when approximate knowledge has been already attained, which │
│ is afterwards to be corrected so as to satisfy all the observations in │
│ the most accurate manner possible."                                    │
│                                                                        │
│ These ideas, which captures the essential ingredients of all data      │
│ processing methods, were incarnated in modern form as Kalman filters   │
│ when, following similar work of Peter Swerling, Rudolph Kálmán         │
│ developed the algorithm. Sometimes the filter is referred to as the    │
│ Kalman-Bucy filter because of Richard Bucy's early work on the topic,  │
│ conducted jointly with Kálmán.                                         │
│  If you have two measurements x1, and x2 of an unknown variable x, what│
│ combination of x1 and x2 gives you the best estimate of x? The answer  │
│ depends on how much uncertainty you expect in each of the measurements.│
│ Statisticians usually measure uncertainty with the variances sigma1    │
│ squared and sigma2 squared. It can be shown, then, that the combination│
│ of x1 and x2 that gives the least variance is                          │
│                                                                        │
│   xhat = [(sigma2^2)*x1 + (sigma1^2)*x2] / [(sigma2^2) + (sigma1^2)]   │
│                                                                        │
│ This result can be figured out, or at least accepted, with common sense│
│ without algebra. The larger the variance of x2 the larger is the weight│
│ we give to x1 in the weighted average. In Kalman filters the first     │
│ measurement, x1, comes from sensor data, and the second "measurement"  │
│ is not really a measurement at all: It is your last forecast of the    │
│ spacecraft's trajectory. In real, e.g. life-saving situations these    │
│ measurements are usually not single numbers, but array of numbers, i.e.│
│ vectors. In the case of the Apollo spacecraft, the vectors had a few   │
│ tens of components. In our demo application here we will use a simpler │
│ scenario. On our observer ship we will track a contact with our radar. │
│ The state of the system will be the relative position and speed of the │
│ contact. The coding is based on the FPU_Matrix_Driver.spin object,     │
│ which allows us to construct Kalman filters that apply vectors up to 11│
│ components and can use [11-by-11] matrices. In the famous book of      │
│ Robert M. Rogers "Applied Mathematics in Integrated Navigation Systems,│
│ Second Edition" (AIAA) the largest matrix you can find is a [13-by-13] │                                          
│ one at a single occasion (as a theoretical summary of error state      │
│ dynamics of INU fine alignments including even time-correlated         │
│ accelerometer error states). But all of the worked out and in-practice │
│ demonstrated  algorithms in that book, before and after this matrix,   │
│ use smaller than [11-by-11] matrices and vectors.                      │
│                                                                        │
├────────────────────────────────────────────────────────────────────────┤
│ Note:                                                                  │
│  Linear systems are only convenient approximations of the real ones,   │
│ which are ultimately nonlinear. If either the state equation or the    │
│ measurement equation has nonlinear terms, then the system is nonlinear.│
│ The system and measurement equations need to be linearized before they │
│ can be estimated. The Extended Kalman Filter (EKF) solves this problem │
│ by calculating the Jacobian derivative matrix of F and H around the    │
│ estimated state. After that the EKF works like a Standard Kalman filter│
│ using the A and C Jacobian matrices. These A and C matrices can change │
│ as the state of the system evolves. In other words, we can program     │
│ directly the nonlinear system or measurement equations and that is very│
│ convenient. Other side of the coin is that we have to program the      │
│ calculation of the Jacobian derivative matrices, which might not be so │
│ convenient. In this application the user has to program only the F and │ 
│ and H functions with the prepared templates and the derivative matrices│
│ A and C will be calculated numerically by the program. In other words I│
│ preferred ease of use against efficiency with this choice. The user,   │
│ of course, can program the analytical derivatives on her/his own       │
│ responsibility. The analytical derivatives, which are actually partial │
│ derivatives, can be rather complicated formulas even for simple systems│
│ and their programming may be prone to errors during derivation and     │
│ during coding. However, if we do the hard coding of these formulas the │
│ right way, we will gain a lot of speed during real filtering.          │
│  There are many mathematically equivalent ways of writing the Kalman   │
│ filter equations. This can be a pretty effective source of confusion to│
│ novice and veteran alike. The coded version is a so called prediction  │
│ form of the Kalman filter equations where x(k+1) is estimated on the   │
│ basis of the measurements up to and including time k. It can be found  │
│ for example in Embedded System Programming, June 2001 and in Embedded  │
│ Systems Design June 2006 by Dan Simon.                                 │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘

Hardware:
 
                                           3.3V
                                            │
    │                               4.7K    │        
   P├A3─────────────────────────┳─────────┫  
   X│                           │           │
   3├A4─────────────────┐       │           │
   2│                   │       │           │ 
   A├A5────┳─────┐      │       │           │
    │      │     │      │       │           │
           │  ┌──┴──────┴───────┴──┐        │                               
         1K  │SIN12  SCLK16  /MCLR│        │                  
           │  │                    │        │
           │  │                AVDD├────────┫       
           └──┤SOUT11           VDD├────────┘
              │                    │         
              │     uM-FPU 3.1     │
              │                    │         
           ┌──┤CS                  │         
           ┣──┤SERIN9              │             
           ┣──┤AVSS                │         
           ┣──┤VSS                 │         
           ┴  └────────────────────┘
          GND

The CS pin of the FPU is tied to LOW to select SPI mode at Reset and must
remain LOW during operation. For this Demo the 2-wire SPI connection was
used, where the SOUT and SIN pins were connected through a 1K resistor and
the A5 pin(6) of the Propeller was connected to the SIN(12) of the FPU.
}}


CON

_CLKMODE = XTAL1 + PLL16X
_XINFREQ = 5_000_000

'Hardware
'_FPU_MCLR    = 0                    'PROP pin to MCLR pin of FPU
'_FPU_CLK     = 1                    'PROP pin to SCLK pin of FPU 
'_FPU_DIO     = 2                    'PROP pin to SIN(-1K-SOUT) of FPU

_FPU_MCLR    = 3                   'PROP pin to MCLR pin of FPU
_FPU_CLK     = 4                   'PROP pin to SCLK pin of FPU 
_FPU_DIO     = 5                   'PROP pin to SIN(-1K-SOUT) of FPU

_FLOAT_SEED  = 0.31415927          'Change this (from [0,1]) to run 
                                   'the demo with other pseudorandom
                                   'data
'_FLOAT_SEED  = 0.27182818
                                     
'Debug
_DBGDEL      = 40_000_000
'_DBGDEL      = 20_000_000

'System dimensions
_N           = 4                   'States  (Max. 11)
_M           = 0                   'Inputs  (Max. 11) 
_R           = 4                   'Outputs (Max. 11) 

  
OBJ

DBG     : "FullDuplexSerialPlus"   'From Parallax Inc.
                                   'Propeller Education Kit
                                   'Objects Lab v1.1
                                        
FPUMAT  : "FPU_Matrix_Driver"      'v2.0
 
  
VAR

LONG  fpu3
LONG  cog_ID

LONG  rnd                    'Global random variable
LONG  time                   'Time  
LONG  deltaT                 'Time step

'I deliberately will not be very parsimonious with HUB memory in the 
'followings to make the coding more traceable and easier to DBG. Most
'of the next allocated matrices and vectors can be reused but I leave
'this memory optimization to the user when she/he tailors this general
'coding framework to a given application

'Constant matrices
LONG         mA[_N * _N]     'System model matrix
LONG         mB[_N * _M]     'System control matrix
LONG         mC[_R * _N]     'Measurement model matrix
LONG        mSw[_N * _N]     'Process noise covariance matrix
LONG        mSz[_R * _R]     'Measurement noise covariance matrix
LONG         mK[_N * _R]     'Kalman gain matrix
LONG         mP[_N * _N]     'Estimation error covariance matrix

'Pre-calculated constant matrix
LONG     mSzInv[_R * _R]     'Inverse of Sz

'Time varying vectors  
LONG         vX[_N]          'Estimate of state vector
LONG     vXtrue[_N]          '"true" state vector used only
                             'in simulations
                             
LONG         vU[_M]          'Input vector
LONG         vY[_R]          'Measurement vector

LONG vProcNoise[_N]          'Process noise vector for simulations
LONG vMeasNoise[_R]          'Measurement noise vector for simulations 

 'Matrices and vectors created during Kalman filtering algorithm  
'In the calculation of the next Kalman gain matrix K(k+1)
LONG        mAP[_N * _N]
LONG        mCT[_N * _R]     
LONG      mAPCT[_N * _R]
LONG        mCP[_R * _N]
LONG      mCPCT[_R * _R]
LONG    mCPCTSz[_R * _R]
LONG mCPCTSzInv[_R * _R]

'In the calculation of the next state estimate x(k+1)
LONG        vHx[_R]
LONG       vyHx[_R]
LONG      vKyHx[_N]
LONG        vFx[_N]

'In the calculation of the new estimation error covariance matrix P(k+1)
LONG             mAT[_N * _N]
LONG            mPAT[_N * _N] 
LONG           mAPAT[_N * _N]     
LONG         mAPATSw[_N * _N]                     
LONG         mSzInvC[_R * _N]                    
LONG       mCTSzInvC[_N * _N]                                       
LONG     mAPCTSzINVC[_N * _N]
LONG    mAPCTSzINVCP[_N * _N]
LONG  mAPCTSzINVCPAT[_N * _N]          

'Define model and environment dependent process noise parameters
'These will be actuated in EKF_Initialize procedure
LONG  dt2              'Sguared deltaT
LONG  accStDev         'One standard deviation. In this example this
                       'will be the source of process noises

LONG  posProcNoise     'One standard deviation
LONG  posProcNoiseVar  'Variance of position process noise  
LONG  velProcNoise     'One standard deviation
LONG  velProcNoiseVar  'Variance of velocity process noise
LONG  velPosPNCovar    'Covariance of velocity and position p. noises
LONG  velVelPNCovar    'Covariance of velocity and velocity p. noises
LONG  posPosPNCovar    'Covariance of position and position p. noises 

'Define sensor dependent measurement noises and covar. matrix elements
LONG  distMeasNoise    'One standard deviation
LONG  bearMeasNoise    'One standard deviation
LONG  doplMeasNoise    'One standard deviation
LONG  distMeasNoiseVar 'Variance of the distance measurement noise
LONG  bearMeasNoiseVar 'Variance of the bearing measurement noise
LONG  doplMeasNoiseVar 'Variance of the doppler measurement noise  
LONG  distBearMNCovar  'Measurement noise covariance
LONG  distDoplMNCovar  'Measurement noise covariance
LONG  bearDoplMNCovar  'Measurement noise covariance
LONG  doplDoplMNCovar  'Measurement noise covariance 

'Parameters of "Tracking Ship" scenario
LONG  ownshipHDG       'Ownship heading
LONG  ownshipSPD       'Ownship speed
LONG  ownshipVn        'Vnorth
LONG  ownshipVe        'Veast
LONG  ownshipHDGr      'Ownship heading in signed radian

LONG  contactBRG       'Contact bearing
LONG  contactHDG       'Contact heading
LONG  contactSPD       'Contact speed
LONG  contactDST       'Contact distance
LONG  contactVn        'Vnorth
LONG  contactVe        'Veast
LONG  contactPn        'Vnorth
LONG  contactPe        'Veast

LONG  relPn            'True relative position and speed components 
LONG  relPe            'used in the simultion
LONG  relVn            
LONG  relVe            

LONG  tBearing         '"True" bearing used in simulation  [degrees]
LONG  tRange           '"True" range used in simulation    [nmi]

LONG  mBearing         '"Measured" bearing used in simulation instead of
                       'sensor value  [degrees]
LONG  mRange           '"Measured" range used in simulation insted of
                       'sensor value  [nmi]
LONG  mVn
LONG  mVe                       


DAT '-------------------------Start of SPIN code--------------------------

               
PUB DoIt | ad_                              
'-------------------------------------------------------------------------
'----------------------------------┌──────┐-------------------------------
'----------------------------------│ DoIt │-------------------------------
'----------------------------------└──────┘-------------------------------
'-------------------------------------------------------------------------
''     Action: -Starts driver objects
''             -Makes a MASTER CLEAR of the FPU and
''             -Calls Extended Kalman Filter demo
'' Parameters: None
''    Results: None
''+Reads/Uses: /fpu3, Hardware constants from CON section
''    +Writes: fpu3
''      Calls: FullDuplexSerialPlus--------->DBG.Start
''                                           DBG,Tx
''                                           DBG.Str
''                                           DBG.Str
''             FPU_Matrix_Driver ----------->FPUMAT.StartCOG
''                                           FPUMAT.StopCOG
''             ExtendedKF_Demo  
'-------------------------------------------------------------------------
'Start FullDuplexSerialPlus Debug terminal
DBG.Start(31, 30, 0, 57600)
  
WAITCNT(6 * CLKFREQ + CNT)
DBG.Tx(16)
DBG.Tx(1)
DBG.Str(STRING("Extended KF with uM-FPU Matrix v2.0", 13))

WAITCNT(CLKFREQ + CNT)

fpu3 := FALSE
ad_ := @cog_ID

'FPU Master Clear...
DBG.Str(STRING(13, "FPU MASTER CLEAR...", 13))
OUTA[_FPU_MCLR]~~ 
DIRA[_FPU_MCLR]~~
OUTA[_FPU_MCLR]~
WAITCNT(CLKFREQ + CNT)
OUTA[_FPU_MCLR]~~
DIRA[_FPU_MCLR]~

'Start FPU_Matrix_Driver
fpu3 := FPUMAT.StartCOG(_FPU_DIO, _FPU_CLK, ad_)

IF fpu3
  DBG.Str(STRING(13, "FPU Matrix Driver started in COG "))
  DBG.Dec(cog_ID)
  DBG.Tx(13)
  WAITCNT(CLKFREQ + CNT)
  
  ExtendedKF_Demo 

  DBG.Str(STRING(13, "ExtendedKF with uM-FPU Matrix v2.0 "))
  DBG.Str(STRING("terminated normally...", 13))
  FPUMAT.StopCOG  
ELSE
  DBG.Str(STRING("FPU Matrix Driver Start failed!", 13))
  DBG.Tx(13)
  DBG.Str(STRING("No FPU found! Check board and try again...", 13))

WAITCNT(CLKFREQ + CNT)   
DBG.Stop    
'-------------------------------------------------------------------------    


PRI ExtendedKF_Demo | oKay, char, row, col, i
'-------------------------------------------------------------------------
'----------------------------┌─────────────────┐--------------------------
'----------------------------│ ExtendedKF_Demo │--------------------------
'----------------------------└─────────────────┘--------------------------
'-------------------------------------------------------------------------
''     Action: Demonstrates ExtendedKF with the use of FPU_Matrix_Driver
''             procedures
'' Parameters: None
''    Results: None
''+Reads/Uses: None
''    +Writes: None
''      Calls: FullDuplexSerialPlus--------->DBG.Str
''                                           DBG,Tx
''                                           DBG,Dec                                      
''             EKF_Initialize
''             EKF_Prepare_Next_TimeStep
''             EKF_Calculate_Next_A
''             EKF_Calculate_Next_C
''             EKF_Next_K
''             EKF_Next_X
''             EKF_Next_P
'-------------------------------------------------------------------------
DBG.Str(STRING(16, 1))
DBG.Str(STRING("-----------Extended KF Demo-----------", 13))

WAITCNT(CLKFREQ + CNT)

oKay := FALSE
oKay := FPUMAT.Reset
DBG.Tx(13)   
IF oKay
  DBG.Str(STRING("FPU Software Reset done...", 13))
ELSE
  DBG.Str(STRING("FPU Software Reset failed...", 13, 13))
  DBG.Str(STRING("Please check hardware and restart..."))
  REPEAT                             'Untill restart or switch off

WAITCNT(CLKFREQ + CNT)

char := FPUMAT.ReadSyncChar
DBG.Str(STRING(13, "Response to _SYNC: "))
DBG.Dec(char)
IF (char == FPUMAT#_SYNC_CHAR)
  DBG.Str(STRING("    (OK)", 13))  
ELSE
  DBG.Str(STRING("   Not OK!", 13, 13))
  DBG.Str(STRING("Please check hardware and restart...", 13))
  REPEAT                             'Untill restart or switch off

WAITCNT(CLKFREQ + CNT)

'Initialise pseudorandom run
rnd := FPUMAT.Rnd_Float_UnifDist(_FLOAT_SEED)
'Disperse values from similar initial seeds       
REPEAT 12
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd)                  

DBG.Str(STRING(16, 1))
DBG.Str(STRING("********************Tracking Ship********************"))
DBG.Tx(13)
DBG.Tx(13) 
DBG.Str(STRING("A new contact is appearing on the radar screen of our"))
DBG.Tx(13)
DBG.Str(STRING("observer ship. The radar measures the range and the"))
DBG.Tx(13)
DBG.Str(STRING("relative bearing of this contact once per second."))
DBG.Tx(13)
DBG.Str(STRING("The Doppler shift provides us some information of the"))
DBG.Tx(13)
DBG.Str(STRING("relative speed of the contact. Track this new contact"))
DBG.Tx(13)
DBG.Str(STRING("for 15 seconds."))
DBG.Tx(13)
DBG.Tx(13)                          
DBG.Str(STRING("---------------Mathematical details--------------"))
DBG.Tx(13)
DBG.Str(STRING("Own ship is cruising with 30 knots in the heading"))
DBG.Tx(13)
DBG.Str(STRING("between somewhere 000T and 360T degrees. The tracking"))
DBG.Tx(13)
DBG.Str(STRING("range of our radar is ca. 48 nautical miles. Its"))     
DBG.Tx(13)
DBG.Str(STRING("range accuracy is about 120 feet and its bearing"))
DBG.Tx(13)
DBG.Str(STRING("accuracy is about 0.5 degree (one standard deviation"))
DBG.Tx(13)
DBG.Str(STRING("each). Doppler speed data has an uncertainty of 2"))
DBG.Tx(13)
DBG.Str(STRING("knots. Contact ship's speed will be between 0 and 25"))
DBG.Tx(13)
DBG.Str(STRING("knots and its heading will be between 000T and 360T."))
DBG.Tx(13)
DBG.Str(STRING("degrees. Both vessels are moving with constant speed."))
DBG.Tx(13)
DBG.Str(STRING("In this case the measurement model is nonlinear."))
DBG.Tx(13) 
  
WAITCNT(20*_DBGDEL + CNT) 

'Initialize Kalman filter***********************************************
EKF_Initialize
'***********************************************************************

DBG.Tx(16)
DBG.Tx(1)
DBG.Str(STRING("---------------------------------------")) 
DBG.Tx(13)
DBG.Str(STRING("Parameters of the system:"))
DBG.Tx(13)
DBG.Str(STRING(" Number of states n :"))  
DBG.Dec(_N) 
DBG.Str(STRING(13, " Number of inputs m :"))
DBG.Dec(_M) 
DBG.Str(STRING(13, "Number of outputs r :"))
DBG.Dec(_R) 
DBG.Tx(13)

WAITCNT(4*_DBGDEL + CNT) 

DBG.Tx(13) 
DBG.Str(STRING("Process noise covariance{Sw} [n-by-n]:", 13))
REPEAT row FROM 1 TO _N
  REPEAT col FROM 1 TO _N
    DBG.Str(FloatToString(mSw[((row-1)*_N)+(col-1)], 0))
    DBG.Str(STRING(" "))
  DBG.Tx(13)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4*_DBGDEL + CNT)

DBG.Str(STRING(13, "Measurement noise covariance {Sz} [r-by-r]:"))
DBG.Tx(13)
REPEAT row FROM 1 TO _R
  REPEAT col FROM 1 TO _R
    DBG.Str(FloatToString(mSz[((row-1)*_R)+(col-1)], 97))
    DBG.Str(STRING(" "))
  DBG.Tx(13)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4*_DBGDEL + CNT)

REPEAT i FROM 1 TO 15

  'Prepare next time step***********************************************
  EKF_Prepare_Next_TimeStep
  '*********************************************************************

  DBG.Str(STRING(16, 1))
  DBG.Str(STRING("-------------------------------------------------")) 
  DBG.Tx(13)

  DBG.Str(STRING( "Time : "))
  DBG.Dec(i)   
  DBG.Tx(13)

  DBG.Tx(13)
  DBG.Str(STRING("Range, Bearing and Doppler measurement data Y(k):"))
  DBG.Tx(13) 
  REPEAT row FROM 1 TO _R
    REPEAT col FROM 1 TO 1
      CASE row
        1:
          DBG.Str(STRING("  Range [nmi] = "))
        2:
          DBG.Str(STRING("Bearing [nmi] = "))
        3:
          DBG.Str(STRING(" Vnorth [knt] = "))
        4:
          DBG.Str(STRING("  Veast [knt] = "))
      DBG.Str(FloatToString(vY[(row-1)+(col-1)], 72))
    DBG.Tx(13)
    WAITCNT((_DBGDEL/25) + CNT)
  
  WAITCNT(_DBGDEL + CNT)
  
  'Calculate A, C matrices********************************************** 
  EKF_Calculate_Next_A
  EKF_Calculate_Next_C
  '*********************************************************************

  'Calculate next Kalman gain matrix************************************
  EKF_Next_K
  '*********************************************************************
  
  DBG.Str(STRING(13,"K(k) [n-by-r]:",13))
  REPEAT row FROM 1 TO _N
    REPEAT col FROM 1 TO _R
      DBG.Str(FloatToString(mK[((row-1)*_R)+(col-1)], 95))
    DBG.Tx(13)
    WAITCNT((_DBGDEL/25) + CNT)

  WAITCNT(_DBGDEL + CNT)

  'Calculate next State estimate****************************************
  EKF_Next_X
  '*********************************************************************
          
  DBG.Str(STRING(13,"Estimated and 'True' position and relative velocity:"))
  DBG.Tx(13)  
    REPEAT row FROM 1 TO _N
      REPEAT col FROM 1 TO 1
        CASE row
          1:
            DBG.Str(STRING("Pos.North [nmi] = "))
          2:
            DBG.Str(STRING("Pos.East  [nmi] = "))
          3:
            DBG.Str(STRING("Vel.North [knt] = "))
          4:
            DBG.Str(STRING("Vel.Eorth [knt] = "))
        DBG.Str(FloatToString(vX[(row-1)+(col-1)], 72))
        DBG.Str(STRING("      "))
        DBG.Str(FloatToString(vXtrue[(row-1)+(col-1)], 72))
      DBG.Tx(13)
      WAITCNT((_DBGDEL/25) + CNT)

  WAITCNT(6*_DBGDEL + CNT)
 
  'Calculate next estimation error covariance matrix********************
  EKF_Next_P
  '*********************************************************************
'-------------------------------------------------------------------------


DAT '-------------Modell dependent Kalman Filter procedures---------------


PRI EKF_Initialize | row, col, fV1, oKay
'-------------------------------------------------------------------------
'----------------------------┌────────────────┐---------------------------
'----------------------------│ EKF_Initialize │---------------------------
'----------------------------└────────────────┘---------------------------
'-------------------------------------------------------------------------
'     Action: Initializes Extended KF calculations
' Parameters: Timestep deltaT, process noise and measurement noise data
'             System parameters
'    Results: Sw, Sz matrices, "Tracking Ship" scenario data
'             Starting valu of vX, vXtrue vectors
'+Reads/Uses: /FPUMAT CONs
'    +Writes: FPU Reg:127, 126
'      Calls: FPU_Matrix_Driver------------->FPUMAT.Read/Write procedures
'                                            FPUMAT.Matrix_Copy
'                                            FPUMAT.Matrix_Transpose
'                                            FPUMAT.Matrix_InvertSmall
'                                            FPUMAT.Matrix_Multiply    
'-------------------------------------------------------------------------
'Setup time and time step
time := 0.0                        'sec 
deltaT := 1.0                      'sec

'Assume process noise to arise from random white noise relative
'acceleration of 10.0 [(feet)/sec^2] one standard deviation. (Waves) 
accStDev := 0.00165             'One standard deviation  [(nmi)/sec^2]

'Calculate user defined variables---------------------------------------
'Calculate (deltaT^2)/2
dt2 := FPUMAT.Float_MUL(deltaT, deltaT)
dt2 := FPUMAT.Float_DIV(dt2, 2.0)

'One Standard deviation of the position process noise is
'         (dt2) * (accStDev)
posProcNoise := FPUMAT.Float_MUL(dt2, accStDev)

'One Standard deviation of the velocity process noise is
'         (deltaT) * (accStDev)
velProcNoise := FPUMAT.Float_MUL(deltaT, accStDev)

'Variance of the position proc. noise is
'       (sdev of pos. p. noise)^2
posProcNoiseVar := FPUMAT.Float_MUL(posProcNoise, posProcNoise) 

'Variance of the velocity proc. noise is
'       (sdev of vel. p. noise)^2
velProcNoiseVar := FPUMAT.Float_MUL(velProcNoise, velProcNoise)

'Covariance of the position and velocity process noises
'  (sdev of pos. p. noise) * (sdev of vel. p. noise)
velPosPNCovar := FPUMAT.Float_MUL(velProcNoise, posProcNoise)

'Covariance of the position / position process noises
'  (sdev of pos. p. noise) * (sdev of pos. p. noise)
posPosPNCovar := posProcNoiseVar

'Covariance of the velocity / velocity process noises
'  (sdev of vel. p. noise) * (sdev of vel. p. noise)
velVelPNCovar := velProcNoiseVar

'Define Sw[n-by-n] constant matrix [4-by-4] 
row := 1
col := 1
mSw[((row-1)*_N)+(col-1)] := posProcNoiseVar
row := 1
col := 2
mSw[((row-1)*_N)+(col-1)] := posPosPNCovar
row := 1
col := 3
mSw[((row-1)*_N)+(col-1)] := velPosPNCovar
row := 1
col := 4
mSw[((row-1)*_N)+(col-1)] := velPosPNCovar

row := 2
col := 1
mSw[((row-1)*_N)+(col-1)] := posPosPNCovar
row := 2
col := 2
mSw[((row-1)*_N)+(col-1)] := posProcNoiseVar
row := 2
col := 3
mSw[((row-1)*_N)+(col-1)] := velPosPNCovar
row := 2
col := 4
mSw[((row-1)*_N)+(col-1)] := velPosPNCovar

row := 3
col := 1
mSw[((row-1)*_N)+(col-1)] := velPosPNCovar
row := 3
col := 2
mSw[((row-1)*_N)+(col-1)] := velPosPNCovar
row := 3
col := 3
mSw[((row-1)*_N)+(col-1)] := velProcNoiseVar
row := 3
col := 4
mSw[((row-1)*_N)+(col-1)] := velVelPNCovar

row := 4
col := 1
mSw[((row-1)*_N)+(col-1)] := velPosPNCovar
row := 4
col := 2
mSw[((row-1)*_N)+(col-1)] := velPosPNCovar
row := 4
col := 3
mSw[((row-1)*_N)+(col-1)] := velVelPNCovar 
row := 4
col := 4
mSw[((row-1)*_N)+(col-1)] := velProcNoiseVar

'Define measurement noise parameters
distMeasNoise := 0.02        'One standard deviation [nmi]
bearMeasNoise := 0.5         'One standard deviation [degree]
doplMeasNoise := 2.0         'One standard deviation [knot]

'Variance of the distant meas. noise is
'  (sdev of distance m. noise)^2
distMeasNoiseVar := FPUMAT.Float_MUL(distMeasNoise, distMeasNoise)

'Variance of the bearing meas. noise is
'   (sdev of bearing m. noise)^2
bearMeasNoiseVar := FPUMAT.Float_MUL(bearMeasNoise, bearMeasNoise)

'Variance of the doppler meas. noise is
'   (sdev of doppler m. noise)^2
doplMeasNoiseVar := FPUMAT.Float_MUL(doplMeasNoise, doplMeasNoise) 

'Covariance of the measurement noises
distBearMNCovar := 0.0
distDoplMNCovar := 0.0
bearDoplMNCovar := 0.0
doplDoplMnCovar := 0.0  

'Define Sz[r-by-r] matrix [4-by-4]
row := 1
col := 1
mSz[((row-1)*_R)+(col-1)] := distMeasNoisevar
row := 1
col := 2
mSz[((row-1)*_R)+(col-1)] := distBearMNCovar
row := 1
col := 3
mSz[((row-1)*_R)+(col-1)] := distDoplMNCovar
row := 1
col := 4
mSz[((row-1)*_R)+(col-1)] := distDoplMNCovar

row := 2
col := 1
mSz[((row-1)*_R)+(col-1)] := distBearMNCovar 
row := 2
col := 2
mSz[((row-1)*_R)+(col-1)] := bearMeasNoiseVar
row := 2
col := 3
mSz[((row-1)*_R)+(col-1)] := bearDoplMNCovar 
row := 2
col := 4
mSz[((row-1)*_R)+(col-1)] := bearDoplMNCovar

row := 3
col := 1
mSz[((row-1)*_R)+(col-1)] := distDoplMNCovar
row := 3
col := 2
mSz[((row-1)*_R)+(col-1)] := bearDoplMNCovar
row := 3
col := 3
mSz[((row-1)*_R)+(col-1)] := doplMeasNoisevar
row := 3
col := 4
mSz[((row-1)*_R)+(col-1)] := doplDoplMNCovar

row := 4
col := 1
mSz[((row-1)*_R)+(col-1)] := distDoplMNCovar
row := 4
col := 2
mSz[((row-1)*_R)+(col-1)] := bearDoplMNCovar
row := 4
col := 3
mSz[((row-1)*_R)+(col-1)] := doplDoplMNCovar 
row := 4
col := 4
mSz[((row-1)*_R)+(col-1)] := doplMeasNoisevar

'Initialize the P estimation error covariance matrix as Sw
FPUMAT.Matrix_Copy(@mP, @mSw, _N, _N)

'Initialize scenario
DBG.Tx(16)
DBG.Tx(1)
DBG.Str(STRING("---------------------------------------")) 
DBG.Tx(13)
DBG.Str(STRING("Initial position and speed of ships:"))
DBG.Tx(13)
'Ownship speed is 30 knots
ownshipSPD := 30.0 
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, ownshipSPD)
'Generate ownship's random heading
rnd := FPUMAT.Rnd_Float_UnifDist(rnd)
'HDG=360*rnd
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)      
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, rnd)
FPUMAT.WriteCmdByte(FPUMAT#_FMULI, 120)
FPUMAT.WriteCmdByte(FPUMAT#_FMULI, 3)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
ownshipHDG := FPUMAT.ReadReg
'Convert to radian
FPUMAT.WriteCmd(FPUMAT#_RADIANS)
FPUMAT.Wait   
FPUMAT.WriteCmd(FPUMAT#_FREADA)
ownshipHDGr := FPUMAT.ReadReg
FPUMAT.WriteCmdByte(FPUMAT#_COPYA, 126)
FPUMAT.WriteCmd(FPUMAT#_COS)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmd(FPUMAT#_SIN)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
FPUMAT.Wait   
FPUMAT.WriteCmd(FPUMAT#_FREADA)
ownshipVe := FPUMAT.ReadReg
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
ownshipVn := FPUMAT.ReadReg

DBG.Str(STRING("     Ownship HDG:"))
DBG.Str(FloatToString(ownshipHDG, 92))
DBG.Tx(13)

DBG.Str(STRING("      Ownship Vn:"))
DBG.Str(FloatToString(ownshipVn, 92))
DBG.Tx(13)

DBG.Str(STRING("      Ownship Ve:"))
DBG.Str(FloatToString(ownshipVe, 92))
DBG.Tx(13)

WAITCNT(6*_DBGDEL + CNT) 
 
'Generate contact's random relative position
'Generate contact's random distance
rnd := FPUMAT.Rnd_Float_UnifDist(rnd)
contactDST := FPUMAT.Rnd_Float_NormDist(rnd, 30.0, 5.0)  
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)      
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, contactDST)
FPUMAT.WriteCmd(FPUMAT#_FABS)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
contactDST := FPUMAT.ReadReg
'Generate contact's random bearing
rnd := FPUMAT.Rnd_Float_UnifDist(rnd)
'BRG=360*rnd
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)      
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, rnd)
FPUMAT.WriteCmdByte(FPUMAT#_FMULI, 120)
FPUMAT.WriteCmdByte(FPUMAT#_FMULI, 3)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
contactBRG := FPUMAT.ReadReg
'Convert to radian
FPUMAT.WriteCmd(FPUMAT#_RADIANS)
FPUMAT.WriteCmdByte(FPUMAT#_COPYA, 126)
FPUMAT.WriteCmd(FPUMAT#_COS)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmd(FPUMAT#_SIN)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
contactPe := FPUMAT.ReadReg
vXtrue[1] := contactPe
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
contactPn := FPUMAT.ReadReg
vXtrue[0] := contactPn

DBG.Tx(13) 
DBG.Str(STRING("     Contact BRG:"))
DBG.Str(FloatToString(contactBRG, 92))
DBG.Tx(13)

DBG.Str(STRING("     Contact DST:"))
DBG.Str(FloatToString(contactDST, 92))
DBG.Tx(13)

WAITCNT(CLKFREQ + CNT)

'Generate contact's random speed
rnd := FPUMAT.Rnd_Float_UnifDist(rnd)
'SPD=25*rnd
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)      
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, rnd)
FPUMAT.WriteCmdByte(FPUMAT#_FMULI, 25)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
contactSPD := FPUMAT.ReadReg
'Generate contact's random heading
rnd := FPUMAT.Rnd_Float_UnifDist(rnd)
'HDG=360*rnd
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)      
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, rnd)
FPUMAT.WriteCmdByte(FPUMAT#_FMULI, 120)
FPUMAT.WriteCmdByte(FPUMAT#_FMULI, 3)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
contactHDG := FPUMAT.ReadReg
'Convert to radian
FPUMAT.WriteCmdByte(FPUMAT#_FCNV, FPUMAT#_DEG_RAD)
FPUMAT.WriteCmdByte(FPUMAT#_COPYA, 126)
FPUMAT.WriteCmd(FPUMAT#_COS)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmd(FPUMAT#_SIN)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
contactVe := FPUMAT.ReadReg
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
contactVn := FPUMAT.ReadReg

DBG.Str(STRING(13, "     Contact HDG:"))
DBG.Str(FloatToString(contactHDG, 92))
DBG.Tx(13)

DBG.Str(STRING("     Contact SPD:"))
DBG.Str(FloatToString(contactSPD, 92))
DBG.Tx(13)

WAITCNT(6*_DBGDEL + CNT)

'Calculate relative speed and position of the contact refered to ownship
'These will be the "true" state variables in our case that we will use
'in the simulation
'At the moment of the start
relPn := contactPn
relPe := contactPe
'relV=contactV-ownshipV
relVn := FPUMAT.Float_SUB(contactVn, ownshipVn) 
vXtrue[2] := relVn
relVe := FPUMAT.Float_SUB(contactVe, ownshipVe) 
vXtrue[3] := relVe

'Calculate first state estimate data from the first ten radar blimp
'to approximate initial state of contact in the filter.
'Measurement data came from the "true" state with added measurement
'noise
mRange := 0.0
mBearing := 0.0
mVn := 0.0
mVe := 0.0
REPEAT 10
  EKF_Prepare_Next_TimeStep
  'The vY vector contains the "measured" Range, Bearing and dopler data 
  mRange := FPUMAT.Float_ADD(mRange, vY[0])
  mBearing := FPUMAT.Float_ADD(mBearing, vY[1])
  mVn :=  FPUMAT.Float_ADD(mVn, vY[2])
  mVe :=  FPUMAT.Float_ADD(mVe, vY[3])

'Take the average
mRange :=  FPUMAT.Float_DIV(mRange, 10.0)
mBearing :=  FPUMAT.Float_DIV(mBearing, 10.0) 
mVn :=  FPUMAT.Float_DIV(mVn, 10.0)
mVe :=  FPUMAT.Float_DIV(mVe, 10.0)
 
DBG.Tx(13)
DBG.Str(STRING("    Initial Range Data = "))
DBG.Str(FloatToString(mRange, 72)) 
DBG.Tx(13)

DBG.Str(STRING("  Initial Bearing Data = "))
DBG.Str(FloatToString(mBearing, 72))
DBG.Tx(13)
DBG.Tx(13)

DBG.Str(STRING("Initial Dopler Vn Data = "))
DBG.Str(FloatToString(mVn, 72))
DBG.Tx(13)

DBG.Str(STRING("Initial Dopler Ve Data = "))
DBG.Str(FloatToString(mVe, 72))
DBG.Tx(13)

WAITCNT(8*_DBGDEL + CNT) 

'Now to simulate the reality a bit more, initialize system
'state for the filter only from the averaged noisy "measured" values 
'Calculate Pn and Pe directly from the averaged "measured" Range
'and Distance values 
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, mRange)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, mBearing)
FPUMAT.WriteCmd(FPUMAT#_RADIANS)
FPUMAT.WriteCmdByte(FPUMAT#_COPYA, 126)
FPUMAT.WriteCmd(FPUMAT#_COS)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmd(FPUMAT#_SIN)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
vX[1] := FPUMAT.ReadReg
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
vX[0] := FPUMAT.ReadReg

'Measurement model for Dopler data is the identity
vX[2] := mVn
vX[3] := mVe

'Calculate a permanently used constant matrix --------------------------
 FPUMAT.Matrix_Invert(@mSzInv, @mSz, _R)
'-------------------------------------------------------------------------


PRI EKF_Prepare_Next_TimeStep | fV, oKay
'-------------------------------------------------------------------------
'---------------------┌───────────────────────────┐-----------------------
'---------------------│ EKF_Prepare_Next_TimeStep │-----------------------
'---------------------└───────────────────────────┘-----------------------
'-------------------------------------------------------------------------
'     Action: -Prepares data to calculate X(k+1), i.e.
'             -Generates process noise and   (for tests and filter tuning)
'             Measurement  noise             (for tests and filter tuning)
'             -Calculates input vector vU(k) for timestep k 
' Parameters: None
'    Results: -New "true" system state (This will be estimated)
'             -New sensor data
'+Reads/Uses: /FPUMAT CONs 
'    +Writes: FPU Reg:127, 126
'      Calls: FPU_Matrix_Driver------------->FPUMAT.Read/Write procedures
'                                            FPUMAT.Rnd_Float_UnifDist
'                                            FPUMAT.Rnd_Float_NormDist
'       Note: This procedure now serves for testing and tuning but this is
'             the right place to enter actuator (input) data and sensor
'             (measurement) data in real applications. In that case Mother
'             Nature will do us the favour to generate all the noises.
'-------------------------------------------------------------------------
'First calculate "true" measurement values from the "true" state (k).
'Then add measurement noise prepare the vY(k) measurement vector to the
'filter
'Calculate Y[0](k)=H[0](X(k))
'In our "Tracking Ship" scenario Y[0] is the D distance to contact
'This LOS distance is measured by our Radar 
'H[0](k)=Y[0](k)=D(k)=SQR(Pn*Pn+Pe*Pe)=SQR(Xtrue[0](k)^2+Xtrue[1](k)^2)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vXtrue[0])
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 126)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vXtrue[1])
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 127)
FPUMAT.WriteCmdByte(FPUMAT#_FADD, 126)
FPUMAT.WriteCmd(FPUMAT#_SQRT)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_FREADA)
fV := FPUMAT.ReadReg
'Add measurement noise to obtain "measured" value
rnd := FPUMAT.Rnd_Float_UnifDist(rnd)           
vY[0] := FPUMAT.Rnd_Float_NormDist(rnd, fV, distMeasNoise) 

'Calculate Y[1](k)=H[1](X(k))
'In our "Tracking Ship" scenario Y[1] is the TB bearing to contact
'H[1](k)=Y[1](k)=TB(k)=ATAN(Pe/Pn)=ATAN(X[1](k)/X[0](k))
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vXtrue[0])
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vXtrue[1])
FPUMAT.WriteCmdByte(FPUMAT#_ATAN2, 126)
FPUMAT.WriteCmd(FPUMAT#_DEGREES)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_FREADA)
fV := FPUMAT.ReadReg
oKay := FPUMAT.Float_GT(0.0, fV, 0.0)
if oKay             'Then add 360 degrees
  FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
  FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fV)
  FPUMAT.WriteCmdByte(FPUMAT#_FADDI, 120)
  FPUMAT.WriteCmdByte(FPUMAT#_FADDI, 120)
  FPUMAT.WriteCmdByte(FPUMAT#_FADDI, 120)
  FPUMAT.Wait 
  FPUMAT.WriteCmd(FPUMAT#_FREADA)
  fV := FPUMAT.ReadReg 
'Add measurement noise to obtain "measured" value
rnd := FPUMAT.Rnd_Float_UnifDist(rnd)           
vY[1] := FPUMAT.Rnd_Float_NormDist(rnd, fV, bearMeasNoise)

'Calculate doppler data  
rnd := FPUMAT.Rnd_Float_UnifDist(rnd)           
vY[2] := FPUMAT.Rnd_Float_NormDist(rnd, vXtrue[2], doplMeasNoise)
rnd := FPUMAT.Rnd_Float_UnifDist(rnd)           
vY[3] := FPUMAT.Rnd_Float_NormDist(rnd, vXtrue[3], doplMeasNoise)

'Calculate new time=time+DeltaT
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, time)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, deltaT)
FPUMAT.WriteCmdByte(FPUMAT#_FADD, 127)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_FREADA)
time := FPUMAT.ReadReg

'Now calculate "true" state (k+1) for simulation purposes
'Integrate Pn relative position
'vXtrue[0](k+1)=vXtrue[0](k)+vXtrue[2](k)*deltaT
fV := vXtrue[0]     'Previous "true" Pn relative position
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fV)
fV := vXtrue[2]     'Previous "true" Vn relative velocity
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fV)
'Convert to nmi/sec
FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 60)
FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 60)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, deltaT)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 126)
FPUMAT.WriteCmdByte(FPUMAT#_FADD, 127)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_FREADA)
fV := FPUMAT.ReadReg
vXtrue[0] := fV      'New "true" Pn relative position

'Integrate Pe relative position
'vXtrue[1](k+1)=vXtrue[1](k)+vXtrue[3](k)*deltaT
fV := vXtrue[1]     'Previous "true" Pe relative position
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fV)
fV := vXtrue[3]     'Previous "true" Ve relative velocity
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fV)
'Convert to nmi/sec
FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 60)
FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 60)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, deltaT)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 126)
FPUMAT.WriteCmdByte(FPUMAT#_FADD, 127)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_FREADA)
fV := FPUMAT.ReadReg
vXtrue[1] := fV      'New "true" Py relative position

'We do not need to update "true" relative speed since it is constant.
'-------------------------------------------------------------------------


PRI EKF_Calculate_F(i) : fX 
'-------------------------------------------------------------------------
'----------------------------┌─────────────────┐--------------------------
'----------------------------│ EKF_Calculate_F │--------------------------
'----------------------------└─────────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Calculates a selected component of the system model
'             function F 
' Parameters: i index, state vector vX
'    Results: fX representing F[i](X(k))=X[i](k+1)
'+Reads/Uses: FPUMAT CONs
'    +Writes: FPU Reg:127, 126, 125
'      Calls: FPU_Matrix_Driver------------->FPUMAT.Read/Write procedures
'       Note: -This system model is linear.
'             -We have no control inputs (_M=0) here. We are passive
'             observers
'-------------------------------------------------------------------------
CASE i
  0: 'Calculate F[0](X(k))=X[0](k+1)
    'In our "Tracking Ship" scenario X[0] is the relative position 
    'expressed in geographic North/East (NE) coordinates
    'F[0]=X[0](k+1)=Pn(k+1)=Pn(k)+dT*Vn(k)=X[0]+deltaT*X[2]
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, deltaT)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vX[2])
    'Convert to nmi/sec
    FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 60)
    FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 60)
    FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vX[0])
    FPUMAT.WriteCmdByte(FPUMAT#_FADD, 126)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    fX := FPUMAT.ReadReg
    
  1: 'Calculate F[1](X(k))=X[1](k+1)
    'In our "Tracking Ship" scenario X[1] is the relative position Py
    'expressed in geographic North/East (NE) coordinates                      
    'F[1]=X[1](k+1)=Py(k+1)=Py(k)+dT*Vy(k)=X[1]+deltaT*X[3]
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, deltaT)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vX[3])
    'Convert to nmi/sec
    FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 60)
    FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 60)
    FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vX[1])
    FPUMAT.WriteCmdByte(FPUMAT#_FADD, 126)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    fX := FPUMAT.ReadReg
    
  2: 'Calculate X[2](k+1)=F[2](X(k))                     
    'In our "Tracking Ship" scenario X[2] is the relative velocity Vx 
    'F[2]=X[2][k+1]=Vx(k+1)=Vx(k)=X[2]
    fX := vX[2]
    
  3: 'Calculate X[3](k+1)=F[3](X(k))
    'In our "Tracking Ship" scenario X[3] is the relative velocity Vy                      
    'F[3]=X[3][k+1]=Vy(k+1)=Vy(k)=X[3]
    fX := vX[3]

  4: 'Calculate F[4](X(k))=X[4](k+1)
    
  5: 'Calculate F[5](X(k))=X[5](k+1)

  6: 'Calculate F[6](X(k))=X[6](k+1)
    
  7: 'Calculate F[7](X(k))=X[7](k+1)

  8: 'Calculate F[8](X(k))=X[8](k+1)
    
  9: 'Calculate F[9](X(k))=X[9](k+1)
    
  10: 'Calculate F[10](X(k))=X[10](k+1)

RETURN fX   
'-------------------------------------------------------------------------


PRI EKF_Calculate_H(i) : fH | oKay
'-------------------------------------------------------------------------
'----------------------------┌─────────────────┐--------------------------
'----------------------------│ EKF_Calculate_H │--------------------------
'----------------------------└─────────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Calculates a selected component of the measurement model
'             function H  
' Parameters: i index, state estimate vector vX
'    Results: fH representing H[i](X(k))=Y[i](k)
'+Reads/Uses: FPUMAT CONs
'    +Writes: None
'      Calls: FPU_Matrix_Driver------------->FPUMAT.Read/Write procedures 
'       Note: -This calculates the estimated mesurement values from the
'             actual state vector estimate vX. The result is used "inside" 
'             the filter. In simulations the "true" measurement data 
'             should be calculated from the "true" state separately, and 
'             that comes "outside" from the filter to mimic the sensor
'             values.
'             -H function, e.g. measurement model, is nonlinear.
'             -Doppler data gives us information usually about the rate of
'             change of the LOS range. In that case simple EKF is prone to
'             divergence. To avoid this we assume in this simulation other
'             sources of target's velocity data (echoes, network, etc..)
'             to give us somewhat more complete velocity information.
'-------------------------------------------------------------------------
CASE i
  0: 'Calculate Y[0](k)=H[0](X(k))
    'In our "Tracking Ship" scenario Y[0] is the D distance to contact
    'This LOS distance is measured by the Radar 
    'H[0](k)=Y[0](k)=D(k)=SQR(Pn*Pn+Pe*Pe)=SQR(X[0](k)^2+X[1](k)^2)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vX[0])
    FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 126)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vX[1])
    FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 127)
    FPUMAT.WriteCmdByte(FPUMAT#_FADD, 126)
    FPUMAT.WriteCmd(FPUMAT#_SQRT)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    fH := FPUMAT.ReadReg
    
  1: 'Calculate Y[1](k)=H[1](X(k))
    'In our "Tracking Ship" scenario Y[1] is the TB bearing to contact
    'True bearing are the LOS angle on our compass scale
    'The relative bearing RB measured by our radar is transformed
    'to true bearing using TB=HDG+RB where HDG is own ship's heading.
    'We calculate directly this true bearing as 
    'H[1](k)=Y[1](k)=TB(k)=ATAN(Pe/Pn)=ATAN(X[1](k)/X[0](k))
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vX[0])
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, vX[1])
    FPUMAT.WriteCmdByte(FPUMAT#_ATAN2, 126)
    FPUMAT.WriteCmd(FPUMAT#_DEGREES)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    fH := FPUMAT.ReadReg
    oKay := FPUMAT.Float_GT(0.0, fH, 0.0)
    if oKay             'Then add 360 to bearing
      FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
      FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fH)
      FPUMAT.WriteCmdByte(FPUMAT#_FADDI, 120)
      FPUMAT.WriteCmdByte(FPUMAT#_FADDI, 120)
      FPUMAT.WriteCmdByte(FPUMAT#_FADDI, 120)
      FPUMAT.Wait 
      FPUMAT.WriteCmd(FPUMAT#_FREADA)
      fH := FPUMAT.ReadReg
    
  2: 'Calculate Y[2](k)=H[2](X(k))
    'Our dopler sensor array measure the North component of the target's
    'velocity
    fH := vX[2]

  3: 'Calculate Y[3](k)=H[3](X(k))
    'Our doppler sensor array measure the East component of the target's
    'velocity
    fH := vX[3] 
    
  4: 'Calculate Y[4](k)=H[4](X(k))
    
  5: 'Calculate Y[5](k)=H[5](X(k))
    
  6: 'Calculate Y[6](k)=H[6](X(k))
    
  7: 'Calculate Y[7](k)=H[7](X(k))
    
  8: 'Calculate Y[8](k)=H[8](X(k))

  9: 'Calculate Y[9](k)=H[9](X(k))
    
  10: 'Calculate Y[1](k)=H[10](X(k))

RETURN fH  
'-------------------------------------------------------------------------


PRI EKF_Calculate_Next_A|row,col,x1,x2,fX0,fDx,fY1,fY2,fdYdX,oKay
'-------------------------------------------------------------------------
'-------------------------┌──────────────────────┐------------------------
'-------------------------│ EKF_Calculate_Next_A │------------------------
'-------------------------└──────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Calculates the Jacobian derivative matrix A 
' Parameters: X(k) state estimate, U(k) control
'    Results: Jacobian A
'+Reads/Uses: /FPUMAT CONs 
'    +Writes: FPU Reg:127, 126
'      Calls: FPU_Matrix_Driver------------->FPUMAT.Read/Write procedures
'             EKF_Calculate_F                          
'       Note: -You may fine tune this numerical Jacobian calculator
'             according to the given F functions
'             -In this example A is constant but the algorithm should work
'             for that case, either.
'-------------------------------------------------------------------------
REPEAT row FROM 0 TO (_N - 1)
  REPEAT col FROM 0 to (_N - 1)
    'Calculate numerical derivative of dF[row]/fX[col] and strore in
    'A[row, col]
    fX0 := vX[col]             'Store original vX value
    'Find dx
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fX0)
    FPUMAT.WriteCmd(FPUMAT#_FABS) 
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, 0.01)
    FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 126)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    fDx := FPUMAT.ReadReg
    'Check for nul fDx
    oKay := FPUMAT.Float_EQ(fDx, 0.0, 0.01)
    IF oKay
      fDx := 0.01 
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fDx)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fX0)
    FPUMAT.WriteCmdByte(FPUMAT#_FSUB, 127)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    vX[col] := FPUMAT.ReadReg 
    fY1 := EKF_Calculate_F(row)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fDx)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fX0)
    FPUMAT.WriteCmdByte(FPUMAT#_FADD, 127)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    vX[col] := FPUMAT.ReadReg 
    fY2 := EKF_Calculate_F(row)
    'deriv.=(fY2-fY1)/(2*dx)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fDx)
    FPUMAT.WriteCmdByte(FPUMAT#_FMULI, 2)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fY1)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fY2)
    FPUMAT.WriteCmdByte(FPUMAT#_FSUB, 126)
    FPUMAT.WriteCmdByte(FPUMAT#_FDIV, 127)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    fdYdX := FPUMAT.ReadReg 
    mA[(row  * _N) + col] := fdYdX
    vX[col] := fX0      'Restore original vX
'-------------------------------------------------------------------------


PRI EKF_Calculate_Next_C|row,col,x1,x2,fX0,fDx,fY1,fY2,fdYdX,oKay
'-------------------------------------------------------------------------
'-------------------------┌──────────────────────┐------------------------
'-------------------------│ EKF_Calculate_Next_C │------------------------
'-------------------------└──────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Calculates the Jacobian derivative matrix C for x(k)
' Parameters: X(k) state estimate
'    Results: Jacobian C
'+Reads/Uses: /FPUMAT CONs 
'    +Writes: FPU Reg:127, 126, 125
'      Calls: FPU_Matrix_Driver------------->FPUMAT.Read/Write procedures
'             EKF_Calculate_H      
'       Note: You may fine tune this numerical Jacobian calculator
'             according to the given H functions
'             Jacobian is
'                          x/r    y/r   0   0
'                         -y/r2  -x/r2  0   0
'                           0      0    1   0
'                           0      0    0   1
'             in our case.
'             It can be more interesting if you program into H the rate
'             of change of the range (radial velocity)
'                             rdot = (x*vx + y*vy)/r
'-------------------------------------------------------------------------
REPEAT row FROM 0 TO (_R - 1)
  REPEAT col FROM 0 to (_N - 1)
    'Calculate numerical derivative of dH[row]/fX[col] and strore in
    'C[row, col]
    fX0 := vX[col]             'Store original vX value
    'Find dx
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fX0)
    FPUMAT.WriteCmd(FPUMAT#_FABS) 
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, 0.01)
    FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 126)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    fDx := FPUMAT.ReadReg
    'Check for nul fDx
    oKay := FPUMAT.Float_EQ(fDx, 0.0, 0.01)
    if oKay
      fDx := 0.01 
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fDx)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fX0)
    FPUMAT.WriteCmdByte(FPUMAT#_FSUB, 127)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    vX[col] := FPUMAT.ReadReg 
    fY1 := EKF_Calculate_H(row)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fDx)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fX0)
    FPUMAT.WriteCmdByte(FPUMAT#_FADD, 127)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    vX[col] := FPUMAT.ReadReg 
    fY2 := EKF_Calculate_H(row)
    'deriv.=(fY2-fY1)/(2*dx)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fDx)
    FPUMAT.WriteCmdByte(FPUMAT#_FMULI, 2)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fY1)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
    FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, fY2)
    FPUMAT.WriteCmdByte(FPUMAT#_FSUB, 126)
    FPUMAT.WriteCmdByte(FPUMAT#_FDIV, 127)
    FPUMAT.Wait
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    fdYdX := FPUMAT.ReadReg 
    mC[(row  * _N) + col] := fdYdX
    vX[col] := fX0      'Restore original vX
'-------------------------------------------------------------------------


DAT '---------Modell independent Kalman Filter Core procedures------------


PRI EKF_Next_K
'-------------------------------------------------------------------------
'------------------------------┌────────────┐-----------------------------
'------------------------------│ EKF_Next_K │-----------------------------
'------------------------------└────────────┘-----------------------------
'-------------------------------------------------------------------------
'     Action: This sequence of FPU_Matrix procedure calls computes the
'             K(k) matrix
' Parameters: A, C, Sz, P
'    Results: Kalman gain matrix
'+Reads/Uses: /KF matrices 
'    +Writes: KF matrices
'      Calls: FPU_Matrix_Driver------------->FPUMAT.Matrix_Transpose
'                                            FPUMAT.Matrix_Multiply  
'                                            FPUMAT.Matrix_Add 
'                                            FPUMAT.Matrix_Invert
'-------------------------------------------------------------------------
FPUMAT.Matrix_Transpose(@mCT, @mC, _R, _N)
FPUMAT.Matrix_Multiply(@mAP, @mA, @mP, _N, _N, _N)
FPUMAT.Matrix_Multiply(@mAPCT, @mAP, @mCT, _N, _N, _R)
FPUMAT.Matrix_Multiply(@mCP, @mC, @mP, _R, _N, _N)
FPUMAT.Matrix_Multiply(@mCPCT, @mCP, @mCT, _R, _N, _R)
FPUMAT.Matrix_Add(@mCPCTSz, @mCPCT, @mSz, _R, _R)
FPUMAT.Matrix_Invert(@mCPCTSzInv, @mCPCTSz, _R)
'Use Matrix_InvertSmall when _R<4   
FPUMAT.Matrix_Multiply(@mK, @mAPCT, @mCPCTSzInv, _N, _R, _R)                                         
'-------------------------------------------------------------------------


PRI EKF_Next_X | row
'-------------------------------------------------------------------------
'------------------------------┌────────────┐-----------------------------
'------------------------------│ EKF_Next_X │-----------------------------
'------------------------------└────────────┘-----------------------------
'-------------------------------------------------------------------------
'     Action: This sequence of procedure calls computes X(k+1)
' Parameters: Previous state estimate X(k)
'             Measurement values Y(k)
'             Kalman gain matrix K(k)
'    Results: New state estimate vector X(k+1)
'+Reads/Uses: /KF matrices 
'    +Writes: KF matrices
'      Calls: FPU_Matrix_Driver------------->FPUMAT.Matrix_Substract
'                                            FPUMAT.Matrix_Multiply        
'                                            FPUMAT.Matrix_Add
'             EKF_Calculate_H
'             EKF_Calculate_F
'       Note: Here we apply the state and measurement equations.
'-------------------------------------------------------------------------
'Calculate H(X)
REPEAT row FROM 0 TO (_R - 1)
  vHx[row] := EKF_Calculate_H(row)

FPUMAT.Matrix_Subtract(@vyHx, @vY, @vHx, _R, 1) 
FPUMAT.Matrix_Multiply(@vKyHx, @mK, @vyHx, _N, _R, 1)

'Calculate F(x)
REPEAT row FROM 0 TO (_N - 1)
  vFx[row] := EKF_Calculate_F(row)

FPUMAT.Matrix_Add(@vX, @vFx, @vKyHx, _N, 1) 
'-------------------------------------------------------------------------


PRI EKF_Next_P
'-------------------------------------------------------------------------
'------------------------------┌────────────┐-----------------------------
'------------------------------│ EKF_Next_P │-----------------------------
'------------------------------└────────────┘-----------------------------
'-------------------------------------------------------------------------
'     Action: This sequence of procedure calls computes the P(k+1) matrix
' Parameters: A, C, Sz, Sw
'    Results: P(k+1)
'+Reads/Uses: /KF matrices 
'    +Writes: KF matrices
'      Calls: FPU_Matrix_Driver------------->FPUMAT.Matrix_Transpose
'                                            FPUMAT.Matrix_Multiply         
'                                            FPUMAT.Matrix_Add
'                                            FPUMAT.Matrix_Subtract 
'-------------------------------------------------------------------------
FPUMAT.Matrix_Transpose(@mAT, @mA, _N, _N)                       
FPUMAT.Matrix_Multiply(@mAPAT, @mAP, @mAT, _N, _N, _N)
FPUMAT.Matrix_Add(@mAPATSw, @mAPAT, @mSw, _N, _N)
FPUMAT.Matrix_Multiply(@mSzInvC, @mSzInv, @mC, _R, _R, _N)
FPUMAT.Matrix_Multiply(@mCTSzInvC, @mCT, @mSzInvC, _N, _R, _N)
FPUMAT.Matrix_Multiply(@mAPCTSzInvC, @mAP, @mCTSzInvC, _N, _N, _N)
FPUMAT.Matrix_Multiply(@mAPCTSzInvCP,@mAPCTSzInvC,@mP,_N,_N,_N)
FPUMAT.Matrix_Multiply(@mAPCTSzInvCPAT,@mAPCTSzInvCP,@mAT,_N,_N,_N)
FPUMAT.Matrix_Subtract(@mP, @mAPATSw, @mAPCTSzInvCPAT, _N, _N)
'-------------------------------------------------------------------------


PRI FloatToString(floatV, format)
'-------------------------------------------------------------------------
'------------------------------┌───────────────┐--------------------------
'------------------------------│ FloatToString │--------------------------
'------------------------------└───────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Converts a HUB/floatV into string within FPU then loads it
'             back into HUB
' Parameters: -Float value
'             -Format code in FPU convention
'    Results: Pointer to string in HUB
'+Reads/Uses: FPUMAT#_FWRITE, FPUMAT#_SELECTA 
'    +Writes: FPU Reg: 127
'      Calls: FPU_Matrix_Driver------->FPUMAT.WriteCmdByte 
'                                      FPUMAT.WriteCmdFloat
'                                      FPUMAT.ReadRaFloatAsStr
'       Note: For debug and test purposes
'-------------------------------------------------------------------------
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdFloat(FPUMAT#_FWRITEA, floatV)
RESULT := FPUMAT.ReadRaFloatAsStr(format) 
'-------------------------------------------------------------------------


DAT '---------------------------MIT License-------------------------------


{{
┌────────────────────────────────────────────────────────────────────────┐
│                        TERMS OF USE: MIT License                       │                                                            
├────────────────────────────────────────────────────────────────────────┤
│  Permission is hereby granted, free of charge, to any person obtaining │
│ a copy of this software and associated documentation files (the        │ 
│ "Software"), to deal in the Software without restriction, including    │
│ without limitation the rights to use, copy, modify, merge, publish,    │
│ distribute, sublicense, and/or sell copies of the Software, and to     │
│ permit persons to whom the Software is furnished to do so, subject to  │
│ the following conditions:                                              │
│                                                                        │
│  The above copyright notice and this permission notice shall be        │
│ included in all copies or substantial portions of the Software.        │  
│                                                                        │
│  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND        │
│ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     │
│ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. │
│ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   │
│ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   │
│ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      │
│ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 │
└────────────────────────────────────────────────────────────────────────┘
}}
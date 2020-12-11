;this program use mitsubishi microcomputers.--M34283*
;all 7x8 KEY matrix
;have to use timer 1 and timer 2 to timing and send code.
;RAM DEFINE

GPORTDATA          .EQU    0,0        
EPORTDATA          .EQU    0,1
ROWNO_NEW          .EQU    0,2        ; KEY ROW NO   (D0_7)
COLNO_NEW          .EQU    0,3        ; KEY COL NO   (G0_3,E0_2)
ROWNO_OLD          .EQU    0,4        ; KEY ROW NO   (D0_7)
COLNO_OLD          .EQU    0,5        ; KEY COL NO   (G0_3,E0_2)
ROWNO_SAE          .EQU    0,6        ; KEY ROW NO   (D0_7)
COLNO_SAE          .EQU    0,7        ; KEY COL NO   (G0_3,E0_2)
ROWNO_CUR          .EQU    0,8
COLNO_CUR          .EQU    0,9
CUR_FLAG           .EQU    0,10
CUR_OK             .EQU    0,11
;=========================

START_BIT	  .EQU	  1,0
TOGGLE_BIT	  .EQU	  1,1
CUSTOMH           .EQU    1,2
CUSTOML           .EQU    1,3
DATAH             .EQU    1,4
DATAL             .EQU    1,5
CUSTOMH_          .EQU    1,6
CUSTOML_          .EQU    1,7
DATAH_            .EQU    1,8
DATAL_            .EQU    1,9

;=========================

COUNTERA          .EQU    2,0
COUNTERB          .EQU    2,1
ROWNO_SEC	  .EQU	  2,2
COLNO_SEC	  .EQU	  2,3
ROWNO_FIRST	  .EQU	  2,4	
COLNO_FIRST	  .EQU	  2,5
COUNTERA_S	  .EQU	  2,6

;=============================

CHESUM_LoBYTELO   .EQU    3,0		;00H
CHESUM_LoBYTEHI	  .EQU    3,1		;
CHESUM_HiBYTELO	  .EQU    3,2		;00H
CHESUM_HiBYTEHI	  .EQU    3,3		;0000H
INDEX		  .EQU    3,4
INDEX_D		  .EQU    3,5
P_INDEX		  .EQU	  3,6 

;=========================
DIGT0   .EQU    0
DIGT1   .EQU    1
DIGT2   .EQU    2
DIGT3   .EQU    3
DIGT4   .EQU    4
DIGT5   .EQU    5
DIGT6   .EQU    6
DIGT7   .EQU    7
DIGT8   .EQU    8
DIGT9   .EQU    9
DIGTA   .EQU    10
DIGTB   .EQU    11
DIGTC   .EQU    12
DIGTD   .EQU    13
DIGTE   .EQU    14
DIGTF   .EQU    15
;=============================
               .ORG    0000H   
START:
                NOP
                CLD                ;clear all D port to 0.
                RCAR               ;enable high level output invaild.

                SNZP               ;if cold start or warm. test flag P.
                BL  COLD_BOOT

WARM_BOOT:
                LA       DIGTF     ;all G/E port set pull-down transistor
                TPU0A              ;and key-on wakeup valid

                LA       DIGT0     ;set D7-D4 port  no pull-down transistor.
                TPU1A              ;and key-on wakeup invalid.                
                                   ;set Timer1
               LA        DIGT1     ;may 32Ms to wait.
               TBA
               LA        DIGT6
               T1AB               
               LA        DIGT3
               TV1A          
               LA        DIGT2
               TBA
               LA        DIGTA
               T1AB
               WRST
RESCAN:
WaitToScan:
               SNZT1
               B       WaitToScan               
              				;send a code,and scan key twice all time(use in)may 32MS              
              				;first scan key, if have key save for second compare.                           
               BML      SCANKEY               
               LXY      COUNTERA
               TAM      0
               SEA      1
               BL       COLD1
               
               LXY      ROWNO_NEW
               TAM      0
               LXY      ROWNO_OLD
               XAM      0
               LXY      COLNO_NEW
               TAM      0
               LXY      COLNO_OLD
               XAM      0
               
               
               BML      SCANKEY
               LXY      COUNTERA
               TAM      0
               SEA      1
               BL       COLD1

               LXY      ROWNO_NEW
               TAM      0
               LXY      ROWNO_OLD
               SEAM
               BL       RESCAN           ;second scan key no equal first key
               LXY      COLNO_NEW
               TAM      0
               LXY      COLNO_OLD        ;second scan key no equal first key
               SEAM
               BL       RESCAN
                                               
;;=======================================================
SEND_IR: 
                  URSC
                  LXY    COLNO_NEW
                  TAM    0
                  TBA
                  LXY    ROWNO_NEW
                  TAM    0
                  TDA
                  TAB
                  TABP       6 
                  TEAB
;-----------------------2006-10-19 8:11------------------------------               
TOSETDATA2:
		  SZC
		  BL	  GET_10_START		;if CY=1,the start bits are 10,ohterwise will be 11.
		  LA	  DIGT3			;CY=0,
                  LXY	  START_BIT 		;
                  XAM	  0                 	 
                  BL	  FETCH_DATA
GET_10_START:      				;CY=1,
		  LA	  DIGT2 		;
                  LXY	  START_BIT 	
                  XAM	  0
                            
FETCH_DATA:	  
		  LA      DIGT0 		;The custom code is 00000.
                  LXY     CUSTOMH
                  XAMI    0
                  LA      DIGT0
                  XAM     0
;-------------------------------------------------------------------                  		  		  
		  TABE				;get the data code from E register.
                  LXY     DATAH
                  XAM 	  0
                  TAB
                  LXY     DATAL
                  XAM 	  0
                	                                                
                  LXY     DATAH
                  TAM 	  0
                  SEA	  DIGTF	
                  BL	  FIND_KEY
                  LXY     DATAL
                  TAM 	  0
                  SEA	  DIGTF	
                  BL	  FIND_KEY
                  BL	  RESCAN
FIND_KEY:		
		  BML     COMP_KEY       	;if equal no skip,else  skip(new key)
                  BL	  HEADER
                  BL	  REP_SE  
REP_SE:
		  LXY	  TOGGLE_BIT
		  SZB	  0
		  BL	  SET1
SET0:		
		  SB	  0
		  BL	  HEADER
SET1:			               
        	  RB	  0                                       
;==============================================================

HEADER:
       ;send   form030  ir code. 
       ;0:889us/889us. 1: 889us/889us.
       
       ;Timer 2 input source use f(Xin). use 0.25us CARR  unit.

       ;set T2 and R2H/R2L.
       ;Timer2 start with R2L.
;==============================================================
               LA         DIGT4
               TBA                  ;the lower time is 18.52us
               LA         DIGT9
               T2AB

               LA         DIGT2
               TBA                  ;the higher time is 9.26us
               LA         DIGT4
               T2HAB

               WRST
               LA         DIGT1     
               TBA                  	;
               LA         DIGTE 
               T1AB	       
               LA         DIGTD      	;
PreSendCode:
               SNZT1
               B          PreSendCode
               TV2A
               
               LA	0	;Stop the timer1 to change the count source to Carrier wave output (CARRY).
               TV1A
               
               LXY        START_BIT	;
               TAM	  0
               RAR
               SZC
               LA	  DIGT5
               LA	  DIGT1
               TV1A
SENDDATA:
               LXY         START_BIT       
               BML         SEND_1BIT       ;
               LXY	   TOGGLE_BIT
               BML	   TOGGLE	       
               LXY         CUSTOMH         ;
               BML         WORD            ;CUSTOM CODE LOW DATA
               LXY         CUSTOML         ;
               BML         SEND_1BIT       ;CUSTOM CODE HIGH DATA
               LXY         DATAH
               BML         WORD            ;LOW DATA CODE
               LXY         DATAL
               BML         SEND_2BIT       ;HIGH DATA CODE

               LA          DIGT5
               TBA
               LA          DIGT7
               T1AB
               LA          DIGT9
WaitEnd:
               SNZT1
               BL           WaitEnd
               TV2A
               LA         DIGT0
               TV2A
               TV1A
               LA          DIGT3
               TV1A
               BL          RESCAN      
                 

;===========================================================

; START SCAN KEY !

SCANKEY:
          WRST
          LXY          0,7
CLSDPORT:
          RD
          DEY
          BL           CLSDPORT
          LXY          ROWNO_NEW    	;CLEAR ROW & COL NO. TO 'F'
          LA           DIGTF
          XAMI         0
          LA           DIGTF
          XAM          0

          LXY          COUNTERA
          LA           0
          XAM          0               	;CLEAR COUNTERA
          LXY          COUNTERA_S
          LA           0
          XAM          0
;;-------------------------------------
          LA           DIGT7           	;DIGT7
          LXY          COUNTERB
          TBA
          XAM          0              	;7==>COUNTERB
          TAB
          TYA
SetPortD1:
          SD                      	;SET Di TO 1
          LA           DIGTF     	;all G/E port set pull-down transistorE0
          TPU0A
          BML          WAIT10
          NOP               
          IAE
          LXY          EPORTDATA      	;save E port data to EPORTDATA.
          XAM          0          
          IAG
          LXY          GPORTDATA      	;save G port data to GPORTDATA.
          XAM          0
          LXY          COUNTERB      	;CLEAR Di TO 0.
          TAM          0
          TYA
          RD
G3_ROW:
          LXY          GPORTDATA
          SZB          3
          BL           G3_KEY
          BL           G2_ROW
G3_KEY:
          BML          INC_COUNTERA
          LXY          ROWNO_NEW
          LA           0
          XAM          0
          BML          COL_TRAN
G2_ROW:
          LXY          GPORTDATA
          SZB          2
          BL           G2_KEY
          BL           G1_ROW
G2_KEY:
          BML          INC_COUNTERA
          LXY          ROWNO_NEW
          LA           0
          XAM          0
          BML          COLADD8         
G1_ROW:
          LXY           GPORTDATA
          SZB           1
          BL            G1_KEY
          BL            G0_ROW
G1_KEY:
          BML           INC_COUNTERA
          LXY           ROWNO_NEW
          LA   		1
          XAM  		0
          BML           COL_TRAN
G0_ROW:
          LXY           GPORTDATA
          SZB           0
          BL            G0_KEY
          BL            E0_ROW		;E2_ROW
G0_KEY:
          BML           INC_COUNTERA
          LXY           ROWNO_NEW
          LA            1
          XAM           0
          BML           COLADD8
;E2_ROW:
;          LXY           EPORTDATA
;          SZB           2
;          BL            E2_KEY
;          BL            E1_ROW
;E2_KEY:
;          BML           INC_COUNTERA
;          LXY           ROWNO_NEW
;          LA            2
;          XAM           0
;          BML           COL_TRAN
;E1_ROW:          
;          LXY           EPORTDATA
;          SZB           1
;          BL            E1_KEY
;          BL            E0_ROW
;E1_KEY:
;          BML           INC_COUNTERA
;          LXY           ROWNO_NEW
;          LA            2
;          XAM           0
;          BML           COLADD8

E0_ROW:
          LXY           EPORTDATA
          SZB           0
          BL            E0_KEY
          BL            NEXT_COL
E0_KEY:
          BML           INC_COUNTERA
          LXY           ROWNO_NEW
          LA            2
          XAM           0
          BML           COL_TRAN

;=====================================================          
NEXT_COL:
          LXY           COUNTERB
          TAM           0
          TYA
          DEY
          BL            DPortNext
          BL            SCANEND

DPortNext:
          TAY
          LXY           COUNTERB
          XAM           0
          TAM           0
          TYA
          BL            SetPortD1

SCANEND:
	  LA		DIGTF
	  TPU0A
	  NOP
	  RT
	  	
;=====================================
INC_COUNTERA:
         LXY            COUNTERA
         TAM            0
         SEA		1
         BL		EAU_2
         LXY		ROWNO_NEW
         TAM		0
         LXY		ROWNO_FIRST
         XAM		0	
         LXY		COLNO_NEW
         TAM		0
         LXY		COLNO_FIRST
         XAM		0
         BL		INC_COUNTER
EAU_2:
	 SEA		2
	 BL		INC_COUNTER
         LXY		ROWNO_NEW
         TAM		0
         LXY		ROWNO_SEC
         XAM		0	
         LXY		COLNO_NEW
         TAM		0
         LXY		COLNO_SEC
         XAM		0
INC_COUNTER:	 
	 LXY            COUNTERA
         TAM            0
         A 1
         NOP
         XAM            0
         RT                  

INC_COUNTERA_S:
         LXY            COUNTERA_S
         TAM            0
         A 1
         NOP
         XAM            0
         RT


COL_TRAN:
         LXY            COUNTERB
         TAM            0
         LXY            COLNO_NEW
         XAM            0
         RT
COLADD8:
         LXY            COUNTERB
         TAM            0
         A              DIGT8
         NOP
         LXY            COLNO_NEW
         XAM            0
         RT
               
;=====================================
;; CODE TABLE.
;=====================================


          .ORG    0300H
                       ;;;;;;;G3
       .DW   11AH       ;K22         ;-----D0
       .DW   13DH       ;K19
       .DW   0FFH       ;K-- 
       .DW   0FFH       ;K21
       .DW   035H   	;K20
       .DW   009H       ;K17
       .DW   03CH       ;K18
       .DW   121H       ;K15          ;-----D7
                       ;;;;;;;G2
       .DW   011H       ;K16
       .DW   024H       ;K13
       .DW   018H       ;K10
       .DW   004H       ;K12
       .DW   000H       ;K14
       .DW   038H       ;K11
       .DW   028H       ;K09
       .DW   008H       ;K08                                       
;============================
          .ORG    0310H
                      ;;;;;G1
       .DW   030H   	;K07
       .DW   025H       ;K04
       .DW   0FFH       ;K--
       .DW   010H       ;K06
       .DW   020H   	;K05
       .DW   02CH       ;K02
       .DW   007H       ;K03
       .DW   00CH       ;K01
                        ;;;G0

       .DW   0FFH   	;K28
       .DW   01CH       ;K25
       .DW   0FFH       ;K--
       .DW   0FFH       ;K24
       .DW   0FFH   	;K26
       .DW   031H       ;K23
       .DW   02DH       ;K27
       .DW   0FFH       ;K--
                       
;=========================
          .ORG    0320H
                       ;;;;E0
       .DW   122H        ;K31
       .DW   11AH        ;K34
       .DW   0FFH        ;K--
       .DW   00DH        ;K33
       .DW   12AH        ;K32
       .DW   102H        ;K29
       .DW   112H        ;K30
       .DW   0FFH        ;K--


;=====================================================
;	RAM CLEAR
;=====================================================
RAMCL0:
        LXY     0,11              ;(X) <- 0 ,(Y) <- 11
RAMCL1:
        LXY     1,11              ;(X) <- 1 ,(Y) <- 11
RAMCL2:
        LXY     2,11              ;(X) <- 2 ,(Y) <- 11
RAMCL3:
        LXY     3,11              ;(X) <- 3 ,(Y) <- 11
RAMCL:
        LA      15                ;(A) <- F
        XAMD    0           	  ;(A) <-> (M) ,Y-1
        BL       RAMCL
        RT

;======================================================
WAIT20:	NOP			;
WAIT19:	NOP			;
WAIT18:	NOP			;
WAIT17:	NOP			;
WAIT16:	NOP			;
WAIT15:	NOP			;
WAIT14:	NOP			;
WAIT13:	NOP			;
WAIT12:	NOP			;
WAIT11:	NOP			;
WAIT10:	NOP			;
WAIT9:	NOP			;
WAIT8:	NOP			;
WAIT7:	NOP			;
WAIT6:	NOP			;
WAIT5:	NOP			;
WAIT4:	RT			;

				
;*******************************************************
;	BIT DATA TRANSMIT
;*******************************************************
BIT2SEND:        
		LA        DIGT1		;BIT=0
                TBA
                LA        DIGTF
                T1AB
                LA   	  DIGTD
Pre2Htime:       
                SNZT1                                                 
                B         Pre2Htime
                TV2A
                LA   	  DIGT5
                TV1A
                LA        DIGT1
                TBA
                LA        DIGTF                
                T1AB                	
                RC
Send2Clow:
                SNZT1
                B         Send2Clow
                RT




BITSEND:        
		SZC	  
		BL	  FIRST_OSC	;BIT=1
                LA        DIGT1		;BIT=0
                TBA
                LA        DIGTF
                T1AB
               
PreHtime:       
                SNZT1                                                 
                B         PreHtime
               
                LA   	  DIGT5
                TV1A
                LA        DIGT1
                TBA
                LA        DIGTF                
                T1AB                	
                RC
SendClow:
                SNZT1
                B         SendClow
                TABE
                RAR	
                SZC
                LA	  DIGT1
                LA	  DIGT5
                TV1A
                RT
;=================================================               
FIRST_OSC:                
                LA        DIGT1
                TBA
                LA        DIGTF
                T1AB
Htime:       
                SNZT1                                                 
                B         Htime
                LA   	  DIGT5
                TV1A
                LA        DIGT1
                TBA
                LA        DIGTF                
                T1AB                
                RC                
                
Sendlow:
                SNZT1
                B         Sendlow
               
                TABE
                RAR	
                SZC	
                LA	    DIGT5	    	
                LA	    DIGT1
                TV1A
                RT
;=======================================================

SEND_1BIT:	
		TAM	    0
                XAMI	    0
                RAR
                SZC	
                BL	    SC_1
                RC		
                BL	    ROT_1
SC_1:
                SC
ROT_1:                	  
		TAM	    0			;The toggle bit is transfered to A.
                TEAB
                BML         BITSEND             ;BIT DATA TRANSMIT
                RT


TOGGLE:        
                TAM	  0
                RAR
		SZC	  
		BL	  TGFIRST_OSC	;BIT=1
                LA        DIGT1		;BIT=0
                TBA
                LA        DIGTF
                T1AB
              
TGPreHtime:       
                SNZT1                                                 
                B         TGPreHtime
                
                LA   	  DIGT5
                TV1A
                LA        DIGT1
                TBA
                LA        DIGTF                
                T1AB                	
                RC
TGSendClow:
                SNZT1
                B         TGSendClow
                LXY	  CUSTOMH
                TAM	  0
                RAR	
                SZC
                LA	  DIGT1
                LA	  DIGT5
                TV1A
                RT
;=================================================               
TGFIRST_OSC:                
                LA        DIGT1
                TBA
                LA        DIGTF
                T1AB
TGHtime:       
                SNZT1                                                 
                B         TGHtime
                LA   	  DIGT5
                TV1A
                LA        DIGT1
                TBA
                LA        DIGTF                
                T1AB                
                RC                
                
TGSendlow:
                SNZT1
                B         TGSendlow
                
                
                LXY	  CUSTOMH
                TAM	  0
                RAR	
                SZC	
                LA	  DIGT5	    	
                LA	  DIGT1
                TV1A
                RT
                                
;*******************************************************
;	WORD DATA TRANSMIT
;*******************************************************
WORD:
                BML	    CHECK_NEXDATBIT
                RAR                        ;0 	;Clear C 
                TEAB                   
                BML         BITSEND             ;BIT DATA TRANSMIT
		TABE
                RAR                        ;1
		TEAB
                BML         BITSEND             ;BIT DATA TRANSMIT
       		TABE
		RAR                        ;2
		TEAB
                BML         BITSEND             ;BIT DATA TRANSMIT
		TABE
                RAR                        ;3
		TEAB
                BML         BITSEND             ;BIT DATA TRANSMIT
		TABE
                RT  
                
SEND_2BIT:
                BML	    CHECK_NEXDATBIT
                RAR                        ;0   ;Clear C 
                TEAB                   
                BML         BITSEND             ;BIT DATA TRANSMIT
		TABE
                RAR                        ;1
                LA	    1
		TEAB
                BML         BITSEND             ;BIT DATA TRANSMIT
       		TABE                 
                RT
                
;==================================================                	
CHECK_NEXDATBIT:
		TAM	    0
                XAMI	    0
                TEAB
                TAM	    0
                RAR
                SZC	
                BL	    SC_BIT
                RC		
                BL	    ROT_DATA
SC_BIT:
                SC	
ROT_DATA:
		TABE                
		RT
;==================================================
;this program compare twice key if equal.
;if equal,return and  skip
;if no equal, save new scan key and no skip
;==================================================
COMP_KEY:
                   LXY     ROWNO_NEW
                   TAM     0
                   LXY     ROWNO_SAE
                   SEAM
                   BL      NoEqual
                   LXY     COLNO_NEW
                   TAM     0
                   LXY     COLNO_SAE
                   SEAM
                   BL      NoEqual
                   RT
NoEqual:
                   LXY     ROWNO_NEW
                   TAM     0
                   LXY     ROWNO_SAE
                   XAM     0
                   LXY     COLNO_NEW
                   TAM     0
                   LXY     COLNO_SAE
                   XAM     0
                   
                   RTS
                   
;=================================================
;;================================================

COLD1:
        SEA   0
        BL    RESCAN2       
        BL    WAITKEY       
RESCAN2:
        LXY    ROWNO_OLD
        LA     DIGTF
        XAMI   0            ;ROWNO_OLD
        LA     DIGTF
        XAMI   0            ;COLNO_OLD
        LA     DIGTF
        XAMI   0            ;ROWNO_SAE
        LA     DIGTF
        XAM    0            ;COLNO_SAE   
               
        BL     RESCAN
        



;============================================================  

COLD_BOOT:                
                BML     RAMCL0          ;RAM CLEAR TO F
                BML     RAMCL1          ;RAM CLEAR
                BML     RAMCL2          ;RAM CLEAR
                BML     RAMCL3
                
WAITKEY:

                LXY      0,7                 
SETD_H:         SD
                DEY
                BL      SETD_H          ;SET D0-D7=1.
                LXY     ROWNO_CUR
                LA      DIGTF
                XAMI    0
                LA      DIGTF
                XAM     0

                LXY     ROWNO_SAE
                LA      DIGTF
                XAMI    0
                LA      DIGTF
                XAM     0

                LA       DIGTF     ;all G/E port expect E0!!!set pull-down transistor
                TPU0A              ;and key-on wakeup valid
                LA       DIGT0     ;set D7-D4 port  no pull-down transistor.
                TPU1A              ;and key-on wakeup invalid.
                POF                ; WAIT FOR PRESS KEY
                

       .END
;======================================================

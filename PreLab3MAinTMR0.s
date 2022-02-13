;Laboratorio #3 
    
    PROCESSOR 16F887
    

; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_CLKOUT   ; Oscillator Selection bits (INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>

PSECT resVect, class=CODE, abs, delta=2
ORG 00h	    ; posición 0000h para el reset
;------------ VECTOR RESET --------------
resetVec:
    PAGESEL MAIN	; Cambio de banco
    GOTO    MAIN
    
PSECT code, delta=2, abs
ORG 100h    ; posición 100h para el codigo
;------------- CONFIGURACION ------------
MAIN:
    CALL    CONFIG_RELOJ    ; Configuración de Oscilador
    CALL    CONFIG_IO	    ; Configuración de IO
    CALL    TIMER0	    ; Configuración de TMR0
    banksel PORTA
Loop:
    btfss   T0IF
    goto    $-1
    call    Reset_tmr0
    incf    PORT
    goto    Loop
    
    
;___________CONFIGURACIONES_______________
    
    

CONFIG_RELOJ:
    banksel OSCCON
    bcf	    IRCF2	    ;IRCF 010 250Khz
    bsf	    IRCF1
    bcf	    IRCF0
    bsf	    SCS		    ;reloj interno
    
    return
    
CONFIG_IO:
    banksel ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISA	    ;Puerto A como salida
    clrf    TRISA
   ; clrf    TRISC	    ;Puerto C salida Display
    
   ; bcf	    STATUS, 5	    ;Banco 00
   ; bcf	    STATUS, 6
   ; clrf
    
    banksel PORTA
    clrf    TRISA
    
    
    
    return

TIMER0:
    banksel TRISA
    bcf	    T0CS	;reloj interno
    bcf	    PSA		;prescaler
    bsf	    PS2
    bsf	    PS1
    bcf	    PS0		;prescaler 110
    
    banksel PORTA
    call Reset_tmr0
    return
    
Reset_tmr0:
    movlw   50
    movwf   TMR0
    bcf	    T0IF	;limpiamos la bandera del timer 0
    
    return
    
 
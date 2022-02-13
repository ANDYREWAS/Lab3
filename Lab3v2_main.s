
//  Archivo: Laboratorio1.s
//  Dispositivo: PIC16F887
//  Creado : 2/02/2022
    

// PIC16F887 Configuration Bit Settings

// CONTADOR PARA EL PUERTO A
// 
    
// 'C' source line config statements
PROCESSOR 16F887
#include <xc.inc>
// CONFIG1
CONFIG FOSC=INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
CONFIG WDTE=OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
CONFIG PWRTE=ON       // Power-up Timer Enable bit (PWRT enabled)
CONFIG MCLRE=OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
CONFIG CP=OFF         // Code Protection bit (Program memory code protection is disabled)
CONFIG CPD=OFF        // Data Code Protection bit (Data memory code protection is disabled)

CONFIG BOREN=OFF      // Brown Out Reset Selection bits (BOR disabled)
CONFIG IESO=OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
CONFIG FCMEN=OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
CONFIG LVP=ON         // Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

// CONFIG2

CONFIG WRT=OFF        // Flash Program Memory Self Write Enable bits (Write protection off)
CONFIG BOR4V=BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
    
// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.


PSECT udata_bank0
    cont_small: DS  1 ;1 byte
    cont_big:	DS  1 
    cont:	DS  1
    
    UP	    EQU  0
    DOWN    EQU	 1
    
PSECT udata_shr ;memoria común
 W_TEMP:	DS	1   ;1byte
 STATUS_TEMP:   DS	1
    
;----------------Vector reset--------------

 PSECT resVect, class=CODE, abs, delta=2
   
ORG 00h
resesVec:
    PAGESEL main
    goto    main

 ;----------------Vector interrupción--------------
   
PSECT	intVect, class=CODE,abs, delta = 2
ORG 04h
push:
    movwf   W_TEMP
    swapf   STATUS, W	;No afecta banderas
    movwf   STATUS_TEMP
    
isr:
    btfss   T0IF
    call    T0_int
pop:
    swapf   STATUS_TEMP,W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
 
    retfie
 
;-----------Config,int------------------------
    
T0_int:
    call    Reset_tmr0
    incf    cont
    movf    cont,w
    sublw   10	    ;como el tmr0 está con un periodo de 100ms * 10 = 1s
    btfss   ZERO    ;STATUS2
    goto    return_t0
    clrf    cont
    incf    PORTD
return_t0:
    return
    
PSECT code, delta=2, abs
ORG 100h  ;posicion del codigo

tabla:
    clrf    PCLATH
    bsf     PCLATH,0
    andlw   0x0f
    addwf   PCL	    ;
    retlw   00111111B	;0
    retlw   00000110B	;1
    retlw   01011011B	;2
    retlw   01001111B	;3
    retlw   01100110B	;4
    retlw   01101101B	;5
    retlw   01111101B	;6
    retlw   00000111B	;7
    retlw   01111111B	;8
    retlw   01101111B	;9
    retlw   01110111B	;A
    retlw   01111100B	;B
    retlw   00111001B	;C
    retlW   01011110B	;d
    retlw   01111001B	;E
    retlw   01110001B	;F
    
    
 
;--------------configuración---------------------
    
main:
   
    call    config_io
    call    config_reloj
    CALL    TIMER0
    Call    interrupcion_tmr0
    banksel PORTA
    clrf    PORTA
    
    
     
;-----------------Loop principal-------------------

loop:
 
   movf	    PORTA, w
   call	    tabla
   movwf    PORTC
   
  
   btfsc	PORTB,	UP
   call	inc_porta
   btfsc	PORTB,	DOWN
   call	dec_porta
  
   
/*componentes del loop para timer0
   
   btfss   T0IF
   goto    $-1
   call    Reset_tmr0
   incf    PORTD
    
   goto	    loop
  
*/   

    
inc_porta:
    call    delay_small
    btfsc   PORTB,0
    goto    $-1
    btfsc   PORTA, 4	;verifica si se enciende el 4to bit
    clrf    PORTA	;reinicia el contador
    incf    PORTA
    return    
    
dec_porta:
    call    delay_small
    btfsc   PORTB,1
    goto    $-1
    decf    PORTA
    btfsc   PORTA, 6
    clrf    PORTA
    return
    
config_io:
   banksel  ANSEL
   clrf    ANSEL
   clrf    ANSELH
    
   banksel TRISA	    ;Puerto A como salida
   clrf    TRISA
   clrf    TRISC	    ;Puerto C salida Display
   bsf	    TRISB,  0
   bsf	    TRISB,  1
    
   Banksel PORTA
   clrf    PORTA
   clrf    PORTC
    
   banksel TRISD	    ;Puerto D como salida del contador de timer0
   clrf    TRISD
   banksel PORTD
   clrf    TRISD
    
   return

    
config_reloj:
   banksel OSCCON
   bsf	    IRCF2	    ;IRCF 100 1Mhz
   bcf	    IRCF1
   bcf	    IRCF0
   bsf	    SCS		    ;reloj interno
    
   return
    
    
;-----------------SubRutina------------------------

    
delay_small:
   movlw   50		    ;Valor inicial del contador
   movwf   cont_small
   decfsz  cont_small,	1   ;decrementar el contador
   goto    $-1		    ;ejecutar línea anterior
   return
    
 
TIMER0:
   banksel TRISA
   bcf	    T0CS	;reloj interno
   bcf	    PSA		;prescaler
 
   bsf	    PS2
   bsf	    PS1
   bsf	    PS0		;prescaler 111
 
   movlw    1580	;ciclo 100ms
   bcf	    T0IF
   
   banksel PORTA
   call Reset_tmr0
   return

interrupcion_tmr0:
   bsf	GIE	;INTCON
   bsf	T0IE
   bcf	T0IE    
   
   return
   
Reset_tmr0:
   movlw   158
   movwf   TMR0
   bcf	   T0IF	;limpiamos la bandera del timer 0
    
   return
    
    
END



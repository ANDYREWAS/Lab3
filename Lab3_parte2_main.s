
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
    UP	    EQU  0
    DOWN    EQU	 1
PSECT resVect, class=CODE, abs, delta=2

    ;----------------Vector reset--------------
    
ORG 00h
resesVec:
    PAGESEL main
    goto    main
	
	
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
   
    call config_io
    call config_reloj
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
   
   
   goto	    loop
    
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
    
    
    return

    
config_reloj:
    banksel OSCCON
    bcf	    IRCF2	    ;IRCF 010 250Khz
    bsf	    IRCF1
    bsf	    IRCF0
    bsf	    SCS		    ;reloj interno
    
    return
;-----------------SubRutina------------------------

    
delay_small:
    movlw   50		    ;Valor inicial del contador
    movwf   cont_small
    decfsz  cont_small,	1   ;decrementar el contador
    goto    $-1		    ;ejecutar línea anterior
    return
    
 
END



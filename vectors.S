#include "include/asm_defs.inc"

.section .vectors, "ax", @progbits
    rjmp __reset        ; 0  RESET
    rjmp bad_isr        ; 1  INT0
    rjmp bad_isr        ; 2  PCINT0
    rjmp bad_isr        ; 3  TIMER1_COMPA
    rjmp bad_isr        ; 4  TIMER1_OVF
    rjmp bad_isr        ; 5  TIMER0_OVF
    rjmp bad_isr        ; 6  EE_RDY
    rjmp bad_isr        ; 7  ANA_COMP
    rjmp bad_isr        ; 8  ADC
    rjmp bad_isr        ; 9  TIMER1_COMPB
    rjmp __t0_compa_isr ; 10 TIMER0_COMPA
    rjmp bad_isr        ; 11 TIMER0_COMPB
    rjmp bad_isr        ; 12 WDT
    rjmp bad_isr        ; 13 USI_START
    rjmp bad_isr        ; 14 USI_OVF

.section .text
bad_isr:
    reti


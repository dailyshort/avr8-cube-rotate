#include "include/asm_defs.inc"

.section .text
.global __reset
.global __t0_compa_isr

.section .bss
angle_x: .space 1
angle_y: .space 1
angle_z: .space 1

.section .text
__t0_compa_isr:
    sbi PINB, PB4
	reti

__reset:
    ;MCU clock speed to 2MHz
    ldi  r16, (1<<CLKPCE)
    ldi  r17, 2
    out  CLKPR, r16
    out  CLKPR, r17
     
    ;pull-up unused gpio
    sbi PORTB, PB3
    sbi DDRB, DDB4

    ;disable ADC
    cbi ADCSRA, ADEN
    ldi r16, (1 << PRADC)
    out PRR, r16

    ;disable timer1
    ;di implementation

    ;enable timer0 with heartbeat ISR
    ldi r16, (1 << WGM01)
    out TCCR0A, r16
    ldi r16, (1 << CS02) | (1 << CS00)
    out TCCR0B, r16
    ldi r16, 243
    out OCR0A, r16
    ldi r16, (1 << OCIE0A)
    out TIMSK, r16

    ;init SP
    ldi  r16, lo8(RAMEND)
    out  SPL, r16
    ldi  r16, hi8(RAMEND)
    out  SPH, r16

    sei
__main:
    clr zero
    rcall display_init
    sts angle_x, zero
    sts angle_y, zero
    sts angle_z, zero

frame:
    lds tmp, angle_x
    lds arg, angle_y
    lds cnt, angle_z
    rcall pipeline_begin_frame
    clr page
page_loop:
    rcall pipeline_render_page
    rcall display_push_page
    inc page
    cpi page, 8
    brne page_loop

    lds tmp, angle_x
    subi tmp, -2
    sts angle_x, tmp
    lds tmp, angle_y
    subi tmp, -3
    sts angle_y, tmp
    lds tmp, angle_z
    subi tmp, -1
    sts angle_z, tmp
    rjmp frame

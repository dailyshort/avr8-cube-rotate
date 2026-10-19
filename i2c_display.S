#include "include/asm_defs.inc"

.equ P_SDA, PB0
.equ P_SCL, PB2
.equ I2C_ADDR, 0x78

.equ USISR_8BIT, (1 << USISIF) | (1 << USIOIF) | (1 << USIPF) | (1 << USIDC)
.equ USISR_1BIT, (1 << USISIF) | (1 << USIOIF) | (1 << USIPF) | (1 << USIDC) | (0xE << USICNT0)

.text
.global display_init
.global display_push_page

display_init:
    clr  zero
    push r16
    push r17
    sbi  PORTB, P_SCL
    sbi  PORTB, P_SDA
    sbi  DDRB, P_SCL
    sbi  DDRB, P_SDA

    ldi  r16, 0xFF
    out  USIDR, r16
    ldi  r16, (1 << USIWM1) | (1 << USICS1) | (1 << USICLK)
    out  USICR, r16
    ldi  r16, USISR_8BIT
    out  USISR, r16

    ldi  ZL, lo8(init_seq)
    ldi  ZH, hi8(init_seq)
    ldi  cnt, INIT_LEN
    rcall display_send
    ldi  ZL, lo8(win_seq)
    ldi  ZH, hi8(win_seq)
    ldi  cnt, WIN_LEN
    rcall display_send

    pop  r17
    pop  r16
    ret

display_begin:
    push arg
    rcall i2c_start
    ldi  arg, I2C_ADDR
    rcall i2c_write
    pop  arg
    rcall i2c_write
    ret

display_send:
    ldi  arg, 0x00
    rcall display_begin
1:  lpm  arg, Z+
    rcall i2c_write
    dec  cnt
    brne 1b
    rcall i2c_stop
    ret

display_push_page:
    rcall i2c_start
    WR   I2C_ADDR
    WR   0x00
    WR   0x22
    mov  arg, page
    rcall i2c_write
    mov  arg, page
    rcall i2c_write
    WR   0x21
    WR   0
    WR   127
    rcall i2c_stop

    rcall i2c_start
    WR   I2C_ADDR
    WR   0x40
    ldi  cnt, 128
1:  ld   arg, Y+
    rcall i2c_write
    dec  cnt
    brne 1b
    rcall i2c_stop
    ret

i2c_start:
    sbi  PORTB, P_SDA
    sbi  PORTB, P_SCL
1:  sbis PINB, P_SCL
    rjmp 1b
    cbi  PORTB, P_SDA
    cbi  PORTB, P_SCL
    sbi  PORTB, P_SDA
    ret

i2c_write:
    out  USIDR, arg
    ldi  r16, USISR_8BIT
    out  USISR, r16
    rcall i2c_clock
    cbi  DDRB, P_SDA
    ldi  r16, USISR_1BIT
    out  USISR, r16
    rcall i2c_clock
    ldi  r16, 0xFF
    out  USIDR, r16
    sbi  DDRB, P_SDA
    ret

i2c_clock:
    ldi  r16, (1 << USIWM1) | (1 << USICS1) | (1 << USICLK) | (1 << USITC)
2:  out  USICR, r16
1:  sbis PINB, P_SCL
    rjmp 1b
    out  USICR, r16
    sbis USISR, USIOIF
    rjmp 2b
    ret

i2c_stop:
    cbi  PORTB, P_SDA
    sbi  PORTB, P_SCL
1:  sbis PINB, P_SCL
    rjmp 1b
    sbi  PORTB, P_SDA
    ret

init_seq:
    .byte 0xAE, 0xD5,0x80, 0xA8,0x3F, 0xD3,0x00, 0x40
    .byte 0x8D,0x14, 0x20,0x00, 0xA1, 0xC8, 0xDA,0x12
    .byte 0x81,0xCF, 0xD9,0xF1, 0xDB,0x40, 0xA4, 0xA6, 0x2E, 0xAF
init_end:
win_seq:
    .byte 0x21, 0x00, 0x7F, 0x22, 0x00, 0x07
win_end:
    .balign 2
.equ INIT_LEN, init_end - init_seq
.equ WIN_LEN, win_end - win_seq

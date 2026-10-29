#include "include/asm_defs.inc"

.macro ROTATE u, v
    mov  tmp, arg
    rcall sin8
    mov  rsn, arg
    mov  arg, tmp
    rcall cos8
    mov  rcs, arg
    mov  ma, \u
    mov  mb, rcs
    rcall fmul
    mov  t1, mhi
    mov  ma, \v
    mov  mb, rsn
    rcall fmul
    sub  t1, mhi
    mov  ma, \u
    mov  mb, rsn
    rcall fmul
    mov  t2, mhi
    mov  ma, \v
    mov  mb, rcs
    rcall fmul
    add  t2, mhi
    mov  \u, t1
    mov  \v, t2
.endm

.section .bss
pagebuf: .space 128
proj:    .space 16
rot_x:   .space 1
rot_y:   .space 1

.section .text
.global pipeline_begin_frame
.global pipeline_render_page

pipeline_begin_frame:
    sts  rot_x, tmp
    sts  rot_y, arg
    rcall transform
    ret

pipeline_render_page:
    rcall buf_clear
    rcall draw_cube
    ldi  YL, lo8(pagebuf)
    ldi  YH, hi8(pagebuf)
    ret

transform:
    ldi  YL, lo8(proj)
    ldi  YH, hi8(proj)
    clr  idx
tv_loop:
    mov  tmp, idx
    lsl  tmp
    add  tmp, idx
    ldi  ZL, lo8(verts)
    ldi  ZH, hi8(verts)
    add  ZL, tmp
    adc  ZH, zero
    lpm  vx, Z+
    lpm  vy, Z+
    lpm  vz, Z

    lds  arg, rot_x
    ROTATE vy, vz
    lds  arg, rot_y
    ROTATE vz, vx

    ldi  ZH, hi8(persp)
    mov  ZL, vz
    subi ZL, -64
    lpm  arg, Z
    mov  ma, vx
    mov  mb, arg
    rcall fmul6
    ldi  tmp, 64
    add  tmp, mhi
    st   Y+, tmp
    mov  ma, vy
    mov  mb, arg
    rcall fmul6
    ldi  tmp, 32
    sub  tmp, mhi
    st   Y+, tmp

    inc  idx
    cpi  idx, 8
    breq tv_done
    rjmp tv_loop
tv_done:
    ret

draw_cube:
    clr  idx
dc_loop:
    mov  tmp, idx
    lsl  tmp
    ldi  ZL, lo8(edges)
    ldi  ZH, hi8(edges)
    add  ZL, tmp
    adc  ZH, zero
    lpm  arg, Z+
    lpm  tmp, Z

    lsl  arg
    ldi  YL, lo8(proj)
    ldi  YH, hi8(proj)
    add  YL, arg
    adc  YH, zero
    ld   px, Y+
    ld   py, Y

    lsl  tmp
    ldi  YL, lo8(proj)
    ldi  YH, hi8(proj)
    add  YL, tmp
    adc  YH, zero
    ld   x1, Y+
    ld   y1, Y

    rcall line
    inc  idx
    cpi  idx, 12
    brne dc_loop
    ret

line:
    mov  tmp, py
    lsr  tmp
    lsr  tmp
    lsr  tmp
    mov  arg, y1
    lsr  arg
    lsr  arg
    lsr  arg
    cp   page, tmp
    brcc 3f
    cp   page, arg
    brcs reject
3:  cp   tmp, page
    brcc line_ok
    cp   arg, page
    brcc line_ok
reject:
    ret
line_ok:
    mov  dx, x1
    sub  dx, px
    ldi  tmp, 1
    brcc 1f
    neg  dx
    ldi  tmp, -1
1:  mov  sx, tmp
    mov  dy, y1
    sub  dy, py
    ldi  tmp, 1
    brcc 2f
    neg  dy
    ldi  tmp, -1
2:  mov  sy, tmp
    cp   dx, dy
    brcs y_major
x_major:
    mov  cnt, dx
    mov  acc, dx
    lsr  acc
x_loop:
    rcall plot
    tst  cnt
    breq line_done
    dec  cnt
    add  px, sx
    add  acc, dy
    cp   acc, dx
    brcs x_loop
    sub  acc, dx
    add  py, sy
    rjmp x_loop
y_major:
    mov  cnt, dy
    mov  acc, dy
    lsr  acc
y_loop:
    rcall plot
    tst  cnt
    breq line_done
    dec  cnt
    add  py, sy
    add  acc, dx
    cp   acc, dy
    brcs y_loop
    sub  acc, dy
    add  px, sx
    rjmp y_loop
line_done:
    ret

buf_clear:
    ldi  YL, lo8(pagebuf)
    ldi  YH, hi8(pagebuf)
    ldi  cnt, 128
1:  st   Y+, zero
    dec  cnt
    brne 1b
    ret

plot:
    mov  tmp, py
    lsr  tmp
    lsr  tmp
    lsr  tmp
    cp   tmp, page
    brne 9f
    mov  tmp, py
    andi tmp, 7
    ldi  ZL, lo8(bitmask)
    ldi  ZH, hi8(bitmask)
    add  ZL, tmp
    adc  ZH, zero
    lpm  tmp, Z
    ldi  YL, lo8(pagebuf)
    ldi  YH, hi8(pagebuf)
    add  YL, px
    adc  YH, zero
    ld   arg, Y
    or   arg, tmp
    st   Y, arg
9:  ret

.equ HALF, 13
verts:
    .byte -HALF,-HALF,-HALF,   HALF,-HALF,-HALF
    .byte -HALF, HALF,-HALF,   HALF, HALF,-HALF
    .byte -HALF,-HALF, HALF,   HALF,-HALF, HALF
    .byte -HALF, HALF, HALF,   HALF, HALF, HALF

edges:
    .byte 0,1, 2,3, 4,5, 6,7
    .byte 0,2, 1,3, 4,6, 5,7
    .byte 0,4, 1,5, 2,6, 3,7

.balign 256
persp:
    .byte 40, 41, 41, 41, 41, 42, 42, 42, 42, 43, 43, 43, 43, 44, 44, 44
    .byte 45, 45, 45, 45, 46, 46, 46, 47, 47, 47, 48, 48, 48, 49, 49, 49
    .byte 50, 50, 50, 51, 51, 51, 52, 52, 53, 53, 53, 54, 54, 55, 55, 55
    .byte 56, 56, 57, 57, 58, 58, 59, 59, 60, 60, 61, 61, 62, 62, 63, 63
    .byte 64, 65, 65, 66, 66, 67, 68, 68, 69, 70, 70, 71, 72, 73, 73, 74
    .byte 75, 76, 77, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89
    .byte 90, 91, 93, 94, 95, 96, 98, 99, 101, 102, 104, 105, 107, 108, 110, 112
    .byte 114, 115, 117, 119, 121, 124, 126, 127, 127, 127, 127, 127, 127, 127, 127, 127

bitmask:
    .byte 1, 2, 4, 8, 16, 32, 64, 128

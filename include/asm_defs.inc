#ifndef CUBE_ROTATE_ASM_DEFS_INC
#define CUBE_ROTATE_ASM_DEFS_INC

#define __SFR_OFFSET 0
#include <avr/io.h>

#define tmp r16
#define arg r17
#define cnt r18
#define cnt2 r19

#define zero r1
#define page r22
#define px   r23
#define py   r24

#define x1   r20
#define y1   r21
#define dx   r4
#define dy   r5
#define sx   r6
#define sy   r7
#define acc  r8

#define ma   r26
#define mb   r27
#define mlo  r12
#define mhi  r13
#define sgn  r14
#define ang  r25

#define vx   r2
#define vy   r3
#define vz   r9
#define rsn  r10
#define rcs  r11
#define t1   r15
#define t2   r0
#define idx  r19

.macro WR byte
	ldi  arg, \byte
	rcall i2c_write
.endm

.macro DRAW xa, ya, xb, yb
	ldi  px, \xa
	ldi  py, \ya
	ldi  x1, \xb
	ldi  y1, \yb
	rcall line
.endm

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

#endif

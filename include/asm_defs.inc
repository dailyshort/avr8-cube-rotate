#ifndef AVR8_CUBE_ROTATE_ASM_DEFS_INC
#define AVR8_CUBE_ROTATE_ASM_DEFS_INC

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

#endif

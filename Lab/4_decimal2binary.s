.data
output:
    .space 33
.text
.align 2
.global _start
_start:
    mov     r0, #56
    mov     r1, r0
    mov     r2, #0
	ldr     r4, =output
convert:
    cmp     r1, #0
    beq     result     
    and     r3, r1, #1
    push    {r3}        @ from LSB to MSB
    lsrs    r1, r1, #1
    add     r2, r2, #1
    b       convert
result:
    cmp     r2, #0
    beq     done       
    pop     {r3}        @ FROM MSB TO LSB
    add     r3, r3, #'0'@ ascii
    strb    r3, [r4], #1
    subs    r2, r2, #1
    bne     result  

    mov     r3, #0      
    strb    r3, [r4]

done:
    b       .
.data
.align 2
VAL_BCD:
    .byte   0x29
VAL_BIN:
    .byte   0x00
.text
.align 2
.global _start
_start:
    LDR R0, =VAL_BCD
    LDRB R1, [R0] @ load a byte from the packed bcd 
    MOV R2, R1, LSR #4 @ دهگان
    AND R3, R1, #0x0F @ یکان
    MOV R4, #10 @ can't appear as a constant in the middle of MLA
    MLA R2, R2, R4, R3 @ خروجی= یکان + دهگان * 10
    LDR R5, =VAL_BIN
    STRB R2, [R5]
    B       end
end: 
	B end
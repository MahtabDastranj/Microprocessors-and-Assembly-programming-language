.global _start
_start:
	MOVW  R0, #0x5678     
    MOVT  R0, #0x1234 
	MOV R3, R0 @ copy of input
	MOV R1, #0 @ Output
	MOV R2, #32 @  counter
	B reversal
reversal:
	AND R4, R3, #1 @ obtaining the least significant bit
	LSL R1, R1, #1 @ shift to left so there's space for the new bit to be stored
	ORR R1, R1, R4 @ Using OR to add the new bit to the output (could also use add)
	LSR R3, R3, #1 @ a shift to right so there's a new bit in LSB location
	SUBS R2, R2, #1 @ decreasing the counter
	BEQ end
	B reversal
end:
	b end

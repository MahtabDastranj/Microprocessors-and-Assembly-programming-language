.global _start
_start:
	MOV R0, #5
	BL factorial
end:
	 B end
factorial:
	PUSH {R0, R2, LR}
	CMP R0, #1
	MOVEQ R1, #1
	POPEQ {R0, R2, LR} @ All the registers that change through the recursion except from the result must be pushed. 
	BXEQ LR
	
	MOV R2, R0
	SUB R0, R0, #1
	BL factorial
	MUL R1, R1, R2
	POP {R0, R2, LR}
	BX LR
	
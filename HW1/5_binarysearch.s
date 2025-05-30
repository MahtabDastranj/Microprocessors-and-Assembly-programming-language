.global _start
_start:
.data
	array: .word 1, 4, 7, 13, 19, 56, 73, 81, 84, 98
	target: .word 14
.text
	LDR R0, =array
	LDR R1, =target
	LDR R1, [R1] @ LOADING 13
	MOV R2, #9 @ INDEX 
	MOV R3, #0 @ OUTPUT
	MOV R4, #1 @ COUNTER
	LSR R6, R2, R4
loop:
	LDR R7, [R0, R6, LSL #2] @ FINDING THE ADDRESS OF MID (LSL2 = each byte)
	CMP R1, R7
	BEQ found
	B check
check:
	LSR R9, R2, R4 @ WIDTH OD EACH JUMP (TO UNDERSTAND WHETHER WE'VE REACHED THE END)
	CMP R9, #1
	BLT not_found @ IF R0 = 0 it shouldn't get stuck in the loop
	ADD R4, R4, #1 
	CMP R1, R7
	BLT down
	B up
down: 
	SUB R8, R6, #1 @ NEW END
	SUB R6, R8, R2, LSR R4 @ NEW MID
	B loop
up:
	ADD R8, R6, #1 @ NEW START
	ADD R6, R8, R2, LSR R4 @ NEW MID
	B loop
found: 
	MOV R3, R6
	B end
not_found:
	MOV R3, #0xFFFFFFFF
end:
	B end
	
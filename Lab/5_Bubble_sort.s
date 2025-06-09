.global _start
_start:
	.equ address, 0x8000
	MOV R2, #4 
	LDR R1, =address
	LDR R1, [R1]
	MOV R4, #0
	B outer
outer:
	SUBS R2, R2, #1
	BEQ end
	SUBS R0, R2, #1
	MOV R3, #0
	B inner
inner:
	ADD R4, R1, R3, LSL#2
	LDR R5, [R4]
	LDR R6, [R4, #4]
	CMP R5, R6
	BLE control
	STR R5, [R4, #4]
	STR R6, [R4]
	B control
control:
	ADD R3, R3, #1
	CMP R3, R0
	BGT outer
	B inner
end:
	b end
	
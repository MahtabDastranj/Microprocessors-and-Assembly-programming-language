.data
input:
	.word 10, 20, 30, 40, 50
sample:
	.word 1
target:
	.word 90
.text
.global _start
_start:
	LDR R7, =input
	LDR R8, =sample 
	SUB R8, R8, R7 @ INPUT'S BYTES
	LSR R8, R8, #2 @ number's quantity
	LDR R2, =target
	LDR R2, [R2] @ target amount
	MOV R0, #0 @ INDEX
	MOV R1, #0 @ SUM
	BL rec
	B .
rec:
	PUSH {R4, R5, LR}
	MOV R4, R0 @ LOCAL INDEX, R4 IS FIXED AND R0 CHANGES INSTEAD
	MOV R5, R1
	CMP R5, R2 
	BEQ true @ 1st condition :found
	BGE false @ 2nd condition : sum is higher than target
	CMP R4, R8
	BGE false @ 3rd condition: all numbers have been tested for a specific subset
	@ exclude a number:
	ADD R0, R4, #1 @ INCREASE INDEX
	MOV R1, R5 @ EXCLUDE THE NUMBER, RELOAD PREVIOUS SUM
	BL rec @ test
	CMP R0, #1
	BEQ true
	@ include:
	ADD R0, R4, #1 @ INCREASE INDEX
	LDR R3, [R7, R0, LSL #2] @ loading the amount of the address
	ADD R1, R5, R3 @ new sum
	BL rec
	CMP R0, #1
	BEQ true
true:
	MOV R0, #1
	POP {R4, R5, PC}
false:
	MOV R0, #0
	POP {R4, R5, PC}
	
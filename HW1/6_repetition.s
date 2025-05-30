.data
input:
	.word 5, 6, 5, 7, 32, 32, 64, 32, 9, 32
target:
	.word 20
.text
.global _start
_start:
	LDR R0, =input
	LDR R2, =target
	LDR R2, [R2]
	MOV R1, #0 @ OUTPUT
	MOV R3, #10 @ NUM
	MOV R4, #0 @ COUNTER
loop:
	LDR R4, [R0], #4
	CMP R4, R2
	ADDEQ R1, R1, #1
	SUBS R3, R3, #1
	BEQ end
	B loop
end:
	B end
	
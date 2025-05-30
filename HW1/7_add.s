.data
input: .word 25, 46, 78, 101, 559
output: .word 0 
.text
.global _start
_start:
	@ I did not consider the result's required bits to exceed 32 bits as the question mentioned only 1 register as the output
	LDR R0, =input @ first cell of input's address
	LDR R1, =output @ first cell of output's address
	MOV R2, #0 @ result
	MOV R3, #5 @ counter
loop:
	LDR R4, [R0], #4 @ load the first number and update address to jump to the next word
	ADD R2, R2, R4 @ add the number to the previous obtained result
	SUBS R3, R3, #1 @ reduce counter by 1 for the next loop,
	BEQ result @ if R3 is 0, adding is finished
	B loop
result:
	STR R2, [R1] @ store result in the address pointed by r1 (output)
	B end
end:
	 B end
	
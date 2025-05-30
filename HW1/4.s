.data
input:
        .word 32       

array:
		.align 2
        .fill 10,4,0  
.text		
.global _start
_start:
	LDR R0, =input @ ADDRESS
	LDR R0, [R0] @ input 
	LDR R2, =array @ array address
	MOV R6, #0 @ خارج قسمت
	CMP R0, #0
	RSBMI R5, R0, #0 @ ABSOLUTE val for - ones (reverse subtract if r1 is negative)
	MOVPL R5, R0
	B loop
loop:
	CMP R5, #10 @ check whether it's less than 10
	BLT index
	SUBS R5, R5, #10 @ to obtain the final residual
	ADD R6, R6, #1
	B loop
index:
	LSL R4, R5, #2 @ loading the shift required to get to the demanded cell
	LDR R3, [R2, R4] @loading previous amount of repetition of a specific number
	ADD R3, R3, #1 @ adding it by 1
	STR R3, [R2, R4] @ store
	CMP R6, #0 
	BEQ end
	MOV R5, R6 @ quotient becomes the number to be devided by 10
	MOV R6, #0 @ clearing quetient so new quetient can be stored in it
	B loop
end:
 	B end
	
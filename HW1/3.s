.global _start
_start:
	MOV R0, #1
	MOV R1, #13 @ limit
	B loop
loop:
	LSL R2, R0, #1 @ multiplying R0 by 2 and storing it in R2
	CMP R2, R1 @ while loop
	BGT end @ If greater, R0 doesn't change
	MOV R0 , R2 @ If not, saving new R0
	B loop
end:
	b end
.global _start
_start:
  LDR R0, =0x00000009
  MOV R1, #1 @ Setting the number's defualt as a prime one
  MOV R3, R0
  MOV R2, R0
  CMP R0, #2 @ inputs less that 2 are not prime
  BLT not_prime
square_finder:
  MUL R4, R3, R3 @ I started multipling the input and decrease by 1 so that I find a number whose power's is less or equal to the input
  CMP R4, R0
  BLE remainder @ when i find the number i branch to remainder
  SUB R3, R3, #1
  B square_finder
remainder:
  CMP R3, #1 @ the first 2 line is to check whether the input is 2 or 3
  BEQ end
  SUBS R2, R2, R3 @in this loop i subtract r2 by r3 each time until the remainder is less than r3
  BEQ not_prime
  CMP R2, R3
  BLT loop
  B remainder
loop: 
  MOV R2, R0 @ I reset r2 here otherwise, further operations are gonna be applied on the previous r2 which is less than previous r3
  CMP R3, #2
  BEQ end
  SUB R3, R3, #1 @ decreasing 1 step in each iteration
  B remainder
not_prime:
  MOV R1, #0
end:
    B end

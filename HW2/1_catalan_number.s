.text
.align 2

.global _start
_start:
    MOV   R0, #5        @ n = 5
    BL    Catalan       @ 
    B     .             @ 

    @Catalan(n): R0=n → R1=Cat(n)
    .global Catalan
Catalan:
    PUSH  {LR}
    CMP   R0, #0
    BEQ   c_base
    MOV   R1, #0       @ i = 0
    BL    Summation    @ R1 = Σ_{k=0..n-1} Cat(k)*Cat(n-1-k)
    POP   {PC}

c_base:
    MOV   R1, #1       @ Cat(0) = 1
    POP   {PC}


    @ Summation(n,i): R0=n, R1=i → R1=sum_{k=i..n-1} Cat(k)*Cat(n-1-k) 
    .global Summation
Summation:
    PUSH  {R4,R5,R6,LR}
        MOV   R4, R0   @ R4 ← n
        MOV   R5, R1   @ R5 ← i
        CMP   R5, R4
        BGE   sum_base @ i>=n → 0

        @ Cat(i)
        MOV   R0, R5
        BL    Catalan
        MOV   R6, R1   @ R6 = Cat(i)

        @ Cat(n-1-i)
        MOV   R0, R4
        SUB   R0, R0, #1
        SUB   R0, R0, R5
        BL    Catalan
        MOV   R2, R1   @ R2 = Cat(n-1-i)

        @ MULTIPLY
        MUL   R6, R6, R2   @ R6 = Cat(i)*Cat(n-1-i)

        @ Sum
        ADD   R5, R5, #1   @ i++
        MOV   R0, R4       @ n
        MOV   R1, R5       @ i
        BL    Summation    @ R1 = Σ_{k=i..n-1}
        ADD   R1, R1, R6  

        B     sum_end

sum_base:
        MOV   R1, #0

sum_end:
    POP   {R4,R5,R6,PC}

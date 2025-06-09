.text
.align 2

.global _start
_start:
    MOV     R0, #20      @ a = 20
    MOV     R1, #5       
    BL      divide       
    B       .            

    .global divide
divide:
    PUSH    {LR}         
    CMP     R0, R1
    BLT     div_base  

    SUB     R0, R0, R1   @ a ← a – b
    BL      divide       
    ADD     R2, R2, #1   @ q_child + 1 → q_parent
    POP     {PC}       

div_base:
    MOV     R2, #0   
    MOV     R3, R0   
    POP     {PC}     

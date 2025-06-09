.global _start
_start:

    MOV     R0, #6              @ Compute T(6): Minimum moves for 6 disks using 4 pegs
    BL      hanoi_4             @ Call recursive function hanoi_4(n)
    B       end                 @ Infinite loop after calculation

end: 
    B end                    

@ Function: power_of_two
@ Calculates 2^n
@ Input:  R0 = n
@ Output: R1 = 2^n

power_of_two:
    MOV     R1, #1              @ R1 = 1 (base value)
pow_loop:
    CMP     R0, #0              @ while n > 0
    BEQ     pow_done            @ if n == 0, done
    LSL     R1, R1, #1          @ R1 *= 2 (equivalent to left shift)
    SUB     R0, R0, #1          @ n -= 1
    B       pow_loop
pow_done:
    BX      LR                  @ return to caller


@ Function: hanoi_4
@ Recursive solution for 4-peg Tower of Hanoi using Frame–Stewart algorithm
@ T(n) = min_{1 <= k < n} [ 2*T(k) + 2^(n-k) - 1 ]
@ Input:  R0 = n
@ Output: R1 = T(n)

hanoi_4:
    PUSH    {R4-R7, LR}         @ Save registers for recursion

    CMP     R0, #0
    BEQ     h4_base_zero        @ Base case: T(0) = 0

    CMP     R0, #1
    BEQ     h4_base_one         @ Base case: T(1) = 1

    MOV     R5, R0              @ R5 = n (store original input)
    MOV     R6, #0x7FFFFFFF     @ R6 = min_moves

    MOV     R4, #1              @ R4 = k = 1 (loop counter)

h4_loop:
    CMP     R4, R5              @ while k < n
    BGE     h4_done

    @ Compute T(k)
    MOV     R0, R4              @ R0 = k
    BL      hanoi_4             @ Recursive: T(k)
    MOV     R7, R1              @ Save T(k) in R7

    LSL     R7, R7, #1          @ R7 = 2*T(k)

    @ Compute 2^(n-k) - 1 
    MOV     R0, R5              @ R0 = n
    SUB     R0, R0, R4          @ R0 = n - k
    BL      power_of_two        @ Call power_of_two(n-k)
    SUB     R1, R1, #1          @ R1 = 2^(n-k) - 1

    ADD     R7, R7, R1          @ total_moves = 2*T(k) + 2^(n-k) - 1

    @ check
    CMP     R7, R6
    MOVLT   R6, R7              @ If total_moves < min_moves, update min_moves

    ADD     R4, R4, #1          @ k += 1
    B       h4_loop

h4_done:
    MOV     R1, R6              @ R1 = result T(n)
    POP     {R4-R7, LR}         @ Restore registers
    BX      LR                  @ Return to caller

@ Base case: T(0) = 0
h4_base_zero:
    MOV     R1, #0
    POP     {R4-R7, LR}
    BX      LR

@ Base case: T(1) = 1 
h4_base_one:
    MOV     R1, #1
    POP     {R4-R7, LR}
    BX      LR

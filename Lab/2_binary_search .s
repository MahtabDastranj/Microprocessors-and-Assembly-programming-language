.data
array:      .word 1, 3, 5, 7, 9, 11, 13
array_size: .word 7
target:     .word 3
result:     .word 1

.text
.global _start
_start:
    LDR R0, =array         @ R0 ← base address of array
    LDR R1, =array_size    @ R1 ← address of array_size
    LDR R1, [R1]           @ R1 ← value in array_size
    LDR R2, =target
    LDR R2, [R2]           @ R2 ← target value

    MOV R3, #0             @ low = 0
    SUB R4, R1, #1         @ high = size - 1
    MOV R5, #-1            @ result = -1(not found)

binary_loop:
    CMP R3, R4			   @ یعنی تمام آرایه بررسی شده و عدد پیدا نشده 
    BGT end_search

    ADD R6, R3, R4
    LSR R6, R6, #1         @ mid = (low + high) / 2, MSB = 0 = half

    LSL R7, R6, #2         @ R7 = mid * 4
    ADD R7, R0, R7         @ R7 = &array[mid]
    LDR R8, [R7]           @ R8 = array[mid]

    CMP R2, R8
    BEQ found
    BLT go_left

go_right:
    ADD R3, R6, #1
    B binary_loop

go_left:
    SUB R4, R6, #1
    B binary_loop

found:
    MOV R5, R6 @ index

end_search:
    LDR R9, =result
    STR R5, [R9]

end:
    B end

	
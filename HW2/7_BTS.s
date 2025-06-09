.data

tree:	@ Root node: value = 10, left = node1, right = node2
    .word node1, 10, node2

node1:	@ Left leaf: value = 7
    .word 0, 7, 0

node2:	@ Right leaf: value = 15
    .word 0, 15, 0

.text
.global _start
_start:

    LDR     R0, =7           @ Target value to search (e.g., 7)
    LDR     R2, =tree        @ Address of the root node
    BL      search_bst       @ Call recursive search function
    B       end              @ Stop program

end:
    B end

@ Recursive BST Search Function
@ Input:
@   R0 = value to search
@   R2 = address of current node
@ Output: R1 = 1 if found, 0 if not found
@ Temporary registers: R3, R4, R5

search_bst:
    PUSH {R4, R5, LR}         @ Save temporary registers and link register

    CMP     R2, #0
    MOVEQ   R1, #0            @ If node is NULL => not found
    BEQ     ret

    LDR     R3, [R2, #4]      @ Load node value from [R2 + 4]
    CMP     R0, R3
    MOVEQ   R1, #1            @ If equal => found
    BEQ     ret

    BLT     go_left
    BGT     go_right

go_left:
    LDR     R4, [R2]          @ Load left child address from [R2 + 0]
    MOV     R2, R4
    BL      search_bst
    B       ret

go_right:
    LDR     R5, [R2, #8]      @ Load right child address from [R2 + 8]
    MOV     R2, R5
    BL      search_bst

ret:
    POP {R4, R5, LR}
    BX LR           

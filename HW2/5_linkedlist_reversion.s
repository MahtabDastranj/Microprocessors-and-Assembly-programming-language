.data
    .align 2
node1:
    .word  1          
    .word  node2      
node2:
    .word  2
    .word  node3
node3:
    .word  3
    .word  0           
    .text
    .align 2
    .global _start
_start:
    ldr   r0, =node1  
    bl    reverse   
    b     .        

    .global reverse
reverse:
    push  {r4, lr}      

    mov   r4, r0        
    cmp   r4, #0
    beq   _rev_null   

    ldr   r0, [r4, #4]  
    cmp   r0, #0
    beq   _rev_one     

    bl    reverse        @ rest = reverse(head->next)  (returns in R1)

    mov   r2, r1         @ r2 = rest
    ldr   r0, [r4, #4]   @ r0 = head->next 
    str   r4, [r0, #4]   @ head->next->next = head
    mov   r0, #0
    str   r0, [r4, #4]   @ head->next = NULL

    mov   r1, r2         @ new_head = rest
    b     _rev_done

_rev_one:
    mov   r1, r4        
    b     _rev_done

_rev_null:
    mov   r1, #0    

_rev_done:
    pop   {r4, pc}   

.data
.align 2
node1:
    .word  7
    .word  node2
node2:
    .word  3
    .word  0
.text
.align 2

.globl _start
_start:
    ldr   r0, =node1
    bl    mergeSort
    b     .

    .globl mergeSort
mergeSort:
    push  {r4, lr}
    cmp   r0, #0
    beq   ms_done
    ldr   r1, [r0, #4]
    cmp   r1, #0
    beq   ms_done

    bl    splitList
    push  {r1}
    bl    mergeSort
    mov   r4, r0
    pop   {r1}
    mov   r0, r1
    bl    mergeSort
    mov   r1, r0
    mov   r0, r4
    bl    sortedMerge

ms_done:
    pop   {r4, pc}


    .globl splitList
splitList:
    push  {r3, r4, r5, lr}
    cmp   r0, #0
    beq   sl_base
    ldr   r4, [r0, #4]
    cmp   r4, #0
    beq   sl_base

    mov   r3, r0
    mov   r5, r4

sl_loop:
    ldr   r4, [r5, #4]
    cmp   r4, #0
    beq   sl_done
    ldr   r4, [r4, #4]
    cmp   r4, #0
    beq   sl_done

    ldr   r3, [r3, #4]
    mov   r5, r4
    b     sl_loop

sl_done:
    ldr   r1, [r3, #4]    @ r1 = back
    mov   r2, #0
    str   r2, [r3, #4]    @ slow->next = NULL
    mov   r0, r0          @ front = original head
    b     sl_ret

sl_base:
    mov   r1, #0
    mov   r0, r0

sl_ret:
    pop   {r3, r4, r5, pc}


    .globl sortedMerge
sortedMerge:
    push  {lr}
    cmp   r0, #0
    beq   sm_take_b
    cmp   r1, #0
    beq   sm_take_a

    ldr   r2, [r0]
    ldr   r3, [r1]
    cmp   r2, r3
    BLE   sm_choose_a

    @ take b
    mov   r2, r1
    ldr   r1, [r1, #4]
    push  {r0}
    bl    sortedMerge
    pop   {r3}
    str   r0, [r2, #4]
    mov   r0, r2
    pop   {pc}

sm_choose_a:
    @ take a
    mov   r2, r0
    ldr   r0, [r0, #4]
    bl    sortedMerge
    str   r0, [r2, #4]
    mov   r0, r2
    pop   {pc}

sm_take_a:
    pop   {pc}

sm_take_b:
    mov   r0, r1
    pop   {pc}

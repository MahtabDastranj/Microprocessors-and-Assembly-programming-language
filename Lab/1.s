.data
.balign 4
input:  .asciz "sIB Whi\0Te MamM?D CI3Y sa:)LAM"
.balign 4
len_finder: .asciz "len"
.balign 16
output: .space 100

    .text @This is neccessary to make the assembler undrestand the followings are code sections.
    .global _start
_start:
    ldr   r0, =input
	ldr   r6, =len_finder
	sub   r2, r6, r0
	
reversal:
    ldr   r4, =output
    mov   r5, #0
    mov   r3, r2 @ r3 is the length counter

rev_loop:
    subs  r3, r3, #1 @ Starting from last bit, preserves the flag for controlling
    ldrb  r1, [r0, r3]
    cmp   r1, #'A' @ r1-'A', it sets Z, N flags.
    blt   ck_lower @ If r1<'A' (branch if less), jump to ck_lower
    cmp   r1, #'Z' @ If not(r1>'A'), obtain r1- 'Z'
    ble   do_lower @ Branch to do_lower if r1 is less or equal to 'z'.
    b     ck_lower @ Branch to ck_lower

do_lower:
    orr   r1, r1, #0x20 @ When we want to change bit by bit. Here we want to have percise bit manipulation. Still confusing!
    b     store

ck_lower:
    cmp   r1, #'a'
    blt   store
    cmp   r1, #'z'
    bgt   store
    bic   r1, r1, #0x20 @ Clears the 5th bit which is responsible for capitalizing letters

store:
    strb  r1, [r4, r5] @ Store the r1 bit in r4+r5 address
    add   r5, r5, #1
    bne   rev_loop @ If r3 is not zero, branch to rev_loop to do the same for other characters

    mov   r1, #0 @ The null terminator
    strb  r1, [r4, r5]

end:
    b     end @ once execution reaches this point, the CPU will repeatedly jump to end, doing nothing else.
	
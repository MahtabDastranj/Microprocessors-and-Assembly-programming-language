.data
output:
    .space 33           @ ذخیره حداکثر 32 بیت + خاتمه دهنده null
.text
.align 2
.global _start
_start:
    mov     r0, #56      @ ورودی دسیمال ثابت 56
    mov     r1, r0       @ کپی عدد ورودی به R1 برای پردازش
    mov     r2, #0       @ شمارنده تعداد بیت ها
	ldr     r4, =output @ آدرس بافر برای ذخیره ASCII
convert:
    cmp     r1, #0      @ اگر عدد صفر نشد
    beq     result     
    and     r3, r1, #1  @ R3 ← بیت کم ارزش (0 یا 1)
    push    {r3}        @ from LSB to MSB
    lsrs    r1, r1, #1  @ تقسیم عدد بر 2 (شیفت راست)
    add     r2, r2, #1  @ افزایش شمارنده بیت ها
    b       convert     @ تکرار تا وقتی R1 == 0
result:
    cmp     r2, #0      @ اگر هیچ بیتی برای چاپ نیست
    beq     done       
    pop     {r3}        @ FROM MSB TO LSB
    add     r3, r3, #'0'@ ascii
    strb    r3, [r4], #1
    subs    r2, r2, #1  @ کاهش شمارنده بیت ها
    bne     result  

    mov     r3, #0      
    strb    r3, [r4]

done:
    b       .
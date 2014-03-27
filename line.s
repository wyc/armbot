.text

.global get_line
get_line:
    @ parameters: r0 = sockfd, r1 = outbuf, r2 = outbuf_len
    @ return: r0 = strlen
    mov     ip, sp
    stmfd   sp!, {fp, ip, lr}
    sub     fp, ip, #4
    push    {r0-r7}

    sub     r2, r2, #1      @ reduce outbuf_len by 1
    mov     r3, #0x02       @ int flags = MSG_PEEK
    ldr     r7, =recv_call
    ldr     r7, [r7]
    swi     #0
    cmp     r0, #2
    blt     gl_exit
    ldr     r1, [sp, #4] @ load outbuf
    mov     r2, #0        @ idx = 0
gl_check_end:
    ldrb    r3, [r1, r2]  @ get value at r1[idx]
    cmp     r3, #'\r'
    bne     gl_continue
    add     r2, r2, #1
    ldrb    r3, [r1, r2]  @ get value at r1[idx+1]
    cmp     r3, #'\n'
    mov     r4, #1        @ terminated!
    beq     gl_terminate_outbuf
    sub     r2, r2, #1
gl_continue:
    mov     r4, #0
    add     r2, r2, #1    @ idx++
    add     r3, r2, #1
    cmp     r3, r0        @ idx + 1 < len?
    blt     gl_check_end
gl_terminate_outbuf:
    add     r2, r2, #1
    mov     r3, #0
    strb    r3, [r1, r2]
    mov     r5, r2            @ save amount
    mov     r1, r2            @ amount (kill_line) = amount
    cmp     r4, #1            @ did we find "\r\n"?
    beq     gl_kill_line      @ if so, then let's just call kill_line
    mov     r1, #-1           @ otherwise, amount = -1
gl_kill_line:
    ldr     r0, [sp, #0]      @ load sockfd
    bl      kill_line
    mov     r0, r5        @ rv = amount
gl_exit:
    pop     {r1}          @ don't overwrite r0
    pop     {r1-r7}
    ldmfd   sp!, {fp, ip, lr}
    mov     sp, ip
    bx      lr

.global kill_line
kill_line:
    @ read until amount or "\r\n" if amount < 0
    @ parameters: r0 = sockfd, r1 = amount
    mov     ip, sp
    stmfd   sp!, {fp, ip, lr}
    sub     fp, ip, #4
    sub     sp, sp, #512
    push    {r0, r4-r7}
    mov     r4, r1      @ r4 = amount left
    cmp     r4, #0
    beq     kl_exit
    add     r1, sp, #20 @ void *buf
    mov     r2, #512    @ size_t len = 512
    cmn     r4, #0
    blt     kl_until_token     @ amount < 0
kl_amount:
    cmp     r4, #512
    bgt     kl_read_amount
    mov     r2, r4        @ size_t len = amount left
kl_read_amount:
    ldr     r7, =read_call
    ldr     r7, [r7]
    swi     #0
    sub     r5, r4, r0
    ldr     r0, [sp, #0]  @ load sockfd
    cmp     r5, #0
    bgt     kl_read_amount
    mov     r0, r4        @ rv = amount read
    b       kl_exit
kl_until_token:
    mov     r3, #0x02   @ int flags = MSG_PEEK
    ldr     r7, =recv_call
    ldr     r7, [r7]
    swi     #0
    mov     r3, #0          @ idx = 0
    mov     r4, #0          @ total = 0
    mov     r6, #1          @ done = true
    cmp     r0, #1
    blt     kl_exit         @ if bytes read < 1 exit
    ble     kl_recurse      @ if bytes read <= then recurse and exit
kl_check_end:
    ldrb    r5, [r1, r3]
    cmp     r5, #'\r'
    bne     kl_continue
    add     r5, r5, #1
    ldrb    r5, [r1, r3]
    cmp     r5, #'\n'
    bne     kl_continue
    mov     r6, #1          @ done = true
    add     r0, r3, #2      @ account for "\r\n"
    b       kl_recurse
kl_continue:
    mov     r6, #0          @ done = false
kl_increment:
    add     r3, r3, #1
    add     r5, r3, #1
    cmp     r5, r0
    blt     kl_check_end
kl_recurse:
    add     r4, r4, r0    @ total += amount
    mov     r1, r0        @ (kill_line) amount = amount read
    ldr     r0, [sp, #0]  @ load sockfd
    bl      kill_line
    ldr     r0, [sp, #0]  @ load sockfd
    mov     r1, #-1       @ load amount = -1
    cmp     r6, #1        @ are we done?
    bne     kl_until_token @ if not, go back for more
    mov     r0, r4        @ rv = total
kl_exit:
    pop     {r1, r4-r7}   @ preserve r0
    add     sp, sp, #512
    ldmfd   sp!, {fp, ip, lr}
    mov     sp, ip
    bx      lr

.data
read_call:      .long 3
recv_call:      .long 291


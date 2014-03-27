.text

.global string_match
string_match:
@ string match tries to match two string prefixes. if one string ends without
@ a mismatched character, then it is considered a success
@ params: r0 = string1, r1 = string2
@ return: r0 = 0 success, -1 otherwise
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4
    push    {r4-r6}
    mov     r3, #0
    mov     r6, #0
sm_loop:
    ldrb    r4, [r0, r3]
    ldrb    r5, [r1, r3]
    cmp     r4, #0
    beq     sm_exit
    cmp     r5, #0
    beq     sm_exit
    add     r3, r3, #1
    cmp     r4, r5
    beq     sm_loop
    mov     r6, #-1
sm_exit:
    mov     r0, r6
    pop     {r4-r6}
    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.global substring_match
substring_match:
@ does r0 contain r1?
@ params: r0 = string1, r1 = string2
@ return: r0 = 0 success, -1 otherwise
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4
    push    {r4-r6}
    mov     r6, #-1
    mov     r2, #0
ssm_next_char:
    mov     r3, #0
ssm_loop:
    ldrb    r4, [r0, r2]
    ldrb    r5, [r1, r3]
    cmp     r4, #0          @ r0 ended
    beq     ssm_exit
    cmp     r5, #0          @ r1 ended
    beq     ssm_success     
    add     r2, r2, #1
    add     r3, r3, #1
    cmp     r4, r5
    bne     ssm_next_char
    b       ssm_loop
ssm_success:
    mov     r6, #0
ssm_exit:
    mov     r0, r6
    pop     {r4-r6}
    mov     sp, ip
    bx      lr

.global find_char_idx
find_char_idx:
@ find the first index that a character is present
@ params: r0 = string, r1 = char
@ return: r0 = char idx success, -1 otherwise
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4

    mov     r2, #0
fci_loop:
    ldrb    r3, [r0, r2]
    cmp     r3, r1
    beq     fci_exit
    add     r2, r2, #1
    cmp     r3, #0
    bne     fci_loop
    mov     r2, #-1
fci_exit:
    mov     r0, r2
    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.global echo_write
echo_write:
@ write data to stdout (1) before writing to the fd in r0
@ params: r0 = fd, r1 = buf, r2 = buf_len
@ return: r0 = write() rv for fd
    mov     ip, sp
    push    {fp, ip, lr}
    push    {r1, r2, r7}

    ldr     r7, =write_call
    ldr     r7, [r7]
    swi     #0

    pop     {r1, r2}
    push    {r0}
    mov     r0, #1
    swi     #0
    pop     {r0}

    pop     {r7}
    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.global wait_one_second
wait_one_second:
    mov     r0, #0
    push    {r0}
    mov     r0, #1
    push    {r0}
    mov     r0, sp
    ldr     r7, =nanosleep_call
    ldr     r7, [r7]
    swi     #0
    pop     {r1, r2}

.data
write_call:             .long 4
nanosleep_call:         .long 162


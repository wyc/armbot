.text

.global handler
handler:
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4
    push    {r4, r7}
    sub     sp, sp, #512
    mov     r4, r0      @ save r0
loop:
    mov     r1, sp
    mov     r2, #512
    bl      get_line
    mov     r2, r0
    mov     r0, r4
    bl      try_handler
    mov     r0, r4
    cmp     r0, #0
    beq     loop
    b       loop        @ lol error handling
    add     sp, sp, #512
    pop     {r4, r7}
    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

try_handler:
    @ parameters: r0 = sockfd, r1 = line, r2 = line_len
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4
    push    {r0-r7}

    mov     r0, #1
    ldr     r7, =write_call
    ldr     r7, [r7]
    swi     #0

th_ping:
    ldr     r0, [sp, #4]
    bl      detect_ping
    
    cmp     r0, #0
    bne     th_msg

    ldr     r0, [sp, #0]
    ldr     r1, [sp, #4]
    ldr     r2, [sp, #8]
    bl      handle_ping
    b       th_exit
th_msg:
    ldr     r0, [sp, #4]
    bl      detect_msg

    cmp     r0, #0
    bne     th_ident

    ldr     r0, [sp, #0]
    bl      handle_msg
    b       th_exit
th_ident:
    ldr     r0, [sp, #4]
    bl      detect_ident

    cmp     r0, #0
    bne     th_exit

    ldr     r0, [sp, #0]
    bl      handle_ident
    b       th_exit
th_exit:
    add     sp, sp, #4
    pop     {r1-r7}
    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.data
write_call:     .long   4
dbstring:       .string "foobar\n"
dbstring.len    = . - dbstring


.text

.global detect_ident
detect_ident:
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4
    b       di_hack
di_heisenbug:
    push    {r0}
    mov     r1, #' '
    bl      find_char_idx
    cmp     r0, #0
    blt     di_exit
    pop     {r1}
    add     r0, r1, r0
    add     r0, r0, #1
    ldr     r1, =ident_head
    bl      string_match
    b       di_exit
di_hack:
    ldr     r1, =ident_head
    bl      substring_match
di_exit:
    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.global handle_ident
handle_ident:
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4
    push    {r7}   @ r4-r8 are callee-save

    push    {r0}
    @ r0 should already contain sockfd
    ldr     r1, =nick_line
    ldr     r2, =nick_line.len
    bl      echo_write

    ldr     r0, [sp]
    ldr     r1, =ident_line
    ldr     r2, =ident_line.len
    bl      echo_write

    pop     {r0}
    ldr     r1, =channel_line
    ldr     r2, =channel_line.len
    bl      echo_write

    mov     r0, #0

    pop     {r7}
    pop     {fp, ip, lr}
    mov     sp, ip
    bx lr

.data
ident_head:             .string "NOTICE * :*** Checking Ident"
nick_line:              .string "NICK armbot\r\n"
nick_line.len           = . - nick_line - 1
ident_line:             .string "USER armbot 8 * :armbot\r\n"
ident_line.len          = . - ident_line - 1
channel_line:           .string "JOIN #btest\r\n"
channel_line.len        = . - channel_line - 1


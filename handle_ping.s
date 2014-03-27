.text

.global detect_ping
detect_ping:
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4

    ldr     r1, =ping_head
    bl      string_match

    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.global handle_ping
handle_ping:
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4
    push    {r4, r7}

    mov     r4, #'O'
    strb    r4, [r1, #1] @ "PING" -> "PONG"
    bl      echo_write

    pop     {r4, r7}
    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.data
ping_head:      .string "PING "
ping_head.len   = . - ping_head - 1


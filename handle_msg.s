.text

.global detect_msg
detect_msg:
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4

    ldr     r1, =msg_head
    bl      substring_match

    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.global handle_msg
handle_msg:
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4

    ldr     r1, =msg_line  
    ldr     r2, =msg_line.len
    sub     r2, r2, #1
    bl      echo_write

    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.data
msg_head:       .string "armbot: source"
msg_line:       .string "PRIVMSG #btest :https://github.com/wyc/armbot\r\n"
msg_line.len    = . - msg_line

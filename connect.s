.text

.global connect
connect:
    mov     ip, sp
    push    {fp, ip, lr}
    sub     fp, ip, #4
    push    {r7}   @ r4-r8 are calee-save

    mov     r0, #2 @ int domain = AF_INET
    mov     r1, #1 @ int type = SOCK_STREAM
    mov     r2, #0 @ int protocol = 0
    ldr     r7, =socket_call
    ldr     r7, [r7]
    swi     #0

    @ sockfd is now in r0
    push    {r0}        @ push sockfd

    mov     r2, #16     @ socklen_t addrlen = 16
    sub     sp, sp, #16 @ sp -= sizeof(struct sockaddr_in) 

    @ populate sockaddr_in

    @ s->sin_family = AF_INET
    mov     r3, #2 
    strh    r3, [sp]
    @ s->sin_port = server_port
    ldr     r3, =server_port
    ldr     r3, [r3]
    strh    r3, [sp, #2]
    @ s->sin_addr = server_addr
    ldr     r3, =server_addr
    ldr     r3, [r3]
    str     r3, [sp, #4]
    @ bzero(&s->sin_zero)
    mov     r3, #0
    str     r3, [sp, #8]
    str     r3, [sp, #12]
    mov     r1, sp      @ const struct sockaddr *addr = sp

    ldr     r7, =connect_call
    ldr     r7, [r7]
    swi     #0

    add     sp, sp, #16
    pop     {r0}        @ pop sockfd

    pop     {r7}
    pop     {fp, ip, lr}
    mov     sp, ip
    bx      lr

.data
socket_call:   .long 281
connect_call:  .long 283

@ all addreses are network byte-order (big-endian)
server_addr:            .long 0x0100007f @ localhost
@server_addr:            .long 0xf949aa53 @ freenode
server_port:            .hword 0x0b1a


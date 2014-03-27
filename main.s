.text

.global	_start
.global exit
_start:
    bl      connect
    bl      handler
    b       exit
exit:
    mov     r0, #0    @ int status = 0
    mov     r7, #1    @ _exit() syscall
    swi     #0

.data


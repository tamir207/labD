section .data
    fmt_int db "%d", 10, 0

section .text
    global main
    extern printf
    extern puts

main:
    push ebp
    mov  ebp, esp

    push dword [ebp+8]
    push fmt_int
    call printf
    add  esp, 8

    mov  ecx, [ebp+8]
    mov  esi, [ebp+12]

.loop:
    cmp  ecx, 0
    je   .done

    push ecx
    push dword [esi]
    call puts
    add  esp, 4
    pop  ecx

    add  esi, 4
    dec  ecx
    jmp  .loop

.done:
    mov  eax, 0
    mov  esp, ebp
    pop  ebp
    ret
section .data
    fmt_int  db "%d", 10, 0
    fmt_hex  db "%02hhx", 0
    newline  db 10, 0
    x_struct db 5
    x_num    db 0xaa, 1, 2, 0x44, 0x4f

section .text
    global main
    extern printf
    extern puts

print_multi:
    push ebp
    mov  ebp, esp
    push ebx
    push esi
    mov  esi, [ebp+8]
    xor  ebx, ebx
    mov  bl, [esi]
    add  esi, ebx
.print_loop:
    cmp  ebx, 0
    je   .print_done
    xor  eax, eax
    mov  al, [esi]
    push eax
    push fmt_hex
    call printf
    add  esp, 8
    dec  esi
    dec  ebx
    jmp  .print_loop
.print_done:
    push newline
    call printf
    add  esp, 4
    pop  esi
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret

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
    push x_struct
    call print_multi
    add  esp, 4
    mov  eax, 0
    mov  esp, ebp
    pop  ebp
    ret
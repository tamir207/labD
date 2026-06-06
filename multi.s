section .data
    fmt_int    db "%d", 10, 0
    fmt_hex    db "%02hhx", 0
    newline    db 10, 0
    x_struct   db 5
    x_num      db 0xaa, 1, 2, 0x44, 0x4f

section .bss
    buffer     resb 500

section .text
    global main
    extern printf
    extern puts
    extern fgets
    extern stdin
    extern strlen
    extern malloc
    extern sscanf

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

getmulti:
    push ebp
    mov  ebp, esp
    push ebx
    push esi
    push edi

    push dword [stdin]
    push 500
    push buffer
    call fgets
    add  esp, 12

    push buffer
    call strlen
    add  esp, 4
    cmp  eax, 0
    je   .error

    dec  eax
    mov  byte [buffer + eax], 0
    mov  ecx, eax

    test ecx, 1
    jnz  .error

    shr  ecx, 1
    mov  ebx, ecx

    lea  eax, [ecx + 1]
    push eax
    call malloc
    add  esp, 4
    cmp  eax, 0
    je   .error

    mov  [eax], bl
    mov  edi, eax

    xor  esi, esi
.sscanf_loop:
    cmp  esi, ebx
    jge  .getmulti_done

    mov  eax, ebx
    sub  eax, esi
    lea  eax, [edi + eax]
    push eax

    push fmt_hex

    mov  eax, esi
    add  eax, eax
    lea  eax, [buffer + eax]
    push eax

    call sscanf
    add  esp, 12

    inc  esi
    jmp  .sscanf_loop

.getmulti_done:
    mov  eax, edi
    pop  edi
    pop  esi
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret
.error:
    mov  eax, 0
    pop  edi
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
    call getmulti
    cmp  eax, 0
    je   .skip_print
    push eax
    call print_multi
    add  esp, 4
.skip_print:
    mov  eax, 0
    mov  esp, ebp
    pop  ebp
    ret
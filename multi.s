section .data
    fmt_int    db "%d", 10, 0
    fmt_hex    db "%02hhx", 0
    newline    db 10, 0
    x_struct   db 5
    x_num      db 0xaa, 1, 2, 0x44, 0x4f
    y_struct   db 6
    y_num      db 0xaa, 1, 2, 3, 0x44, 0x4f
    STATE      dw 0x1234
    MASK       dw 0x002D

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


get_maxmin:
    push ecx
    push edx
    xor  ecx, ecx
    mov  cl, [eax]
    xor  edx, edx
    mov  dl, [ebx]
    cmp  cl, dl
    jge  .done
    xchg eax, ebx
.done:
    pop  edx
    pop  ecx
    ret


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
    xor  eax, eax
    pop  edi
    pop  esi
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret


add_multi:
    push ebp
    mov  ebp, esp
    push ebx
    push esi
    push edi

    mov  eax, [ebp+8]
    mov  ebx, [ebp+12]
    call get_maxmin

    mov  esi, eax

    xor  ecx, ecx
    mov  cl, [esi]
    xor  edx, edx
    mov  dl, [ebx]

    mov  eax, ecx
    inc  eax
    cmp  eax, 255
    jle  .size_ok
    mov  eax, 255

.size_ok:
    push ecx
    push edx
    push eax
    inc  eax
    push eax
    call malloc
    add  esp, 4

    mov  edi, eax
    pop  eax
    mov  [edi], al
    pop  edx
    pop  ecx

    push edi

    lea  esi, [esi+1]
    lea  ebx, [ebx+1]
    lea  edi, [edi+1]

    push ecx
    mov  eax, ecx
    sub  eax, edx
    push eax
    mov  ecx, edx
    clc

.add_loop:
    mov  al, [esi]
    adc  al, [ebx]
    mov  [edi], al
    inc  esi
    inc  ebx
    inc  edi
    dec  ecx
    jnz  .add_loop

    pop  ecx
    jecxz .carry_byte

.carry_loop:
    mov  al, [esi]
    adc  al, 0
    mov  [edi], al
    inc  esi
    inc  edi
    dec  ecx
    jnz  .carry_loop

.carry_byte:
    mov  al, 0
    adc  al, 0
    pop  edx
    cmp  edx, 255
    je   .no_extra
    mov  [edi], al

.no_extra:
    pop  eax
    pop  edi
    pop  esi
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret


rand_num:
    push ebx

    mov  ax, [STATE]
    mov  bx, ax
    and  bx, [MASK]

    mov  bx, 0
    jp   .even
    mov  bx, 0x8000
.even:
    shr  ax, 1
    or   ax, bx
    mov  [STATE], ax

    xor  eax, eax
    mov  al, [STATE]

    pop  ebx
    ret


PRmulti:
    push ebp
    mov  ebp, esp
    push ebx
    push esi

.get_len:
    call rand_num
    cmp  al, 0
    je   .get_len
    xor  ebx, ebx
    mov  bl, al

    lea  eax, [ebx + 1]
    push eax
    call malloc
    add  esp, 4
    cmp  eax, 0
    je   .pr_error

    mov  esi, eax
    mov  [esi], bl

    xor  ecx, ecx
.fill_loop:
    cmp  ecx, ebx
    jge  .pr_done
    push ecx
    call rand_num
    pop  ecx
    mov  [esi + ecx + 1], al
    inc  ecx
    jmp  .fill_loop

.pr_done:
    mov  eax, esi
    pop  esi
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret

.pr_error:
    xor  eax, eax
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

    push y_struct
    call print_multi
    add  esp, 4

    push y_struct
    push x_struct
    call add_multi
    add  esp, 8

    push eax
    call print_multi
    add  esp, 4

    call PRmulti
    push eax
    call print_multi
    add  esp, 4

    xor  eax, eax
    mov  esp, ebp
    pop  ebp
    ret
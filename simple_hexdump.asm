; simple_hexdump.asm - Assemble with NASM
; Compile instructions in Makefile

section .data
    ; Simply a 1 Byte Buffer
    buffer  db "0"

    ; Arrays to Hold Hex and Powers of Two
    hex     db "0123456789abcdef"
    powr_2  db 128,64,32,16,8,4,2,1

    ; Switch to Know the First and Second Character for Hex
    switch  db 0

    ; For Making Output Look Nice
    space   db " "
    newline db 0x0A
    column  db 0

section .text
    global  _start

; Output to STDOUT
output:
    push    rdx
    push    rsi
    push    rdi
    push    rax
    pushf

    mov     rax,    0x01    ;   SYS_WRITE
    mov     rdi,    0x01    ;   STDOUT
    mov     rsi,    rbx
    mov     rdx,    0x01
    syscall

    popf
    pop     rax
    pop     rdi
    pop     rsi
    pop     rdx
    ret

; Find Hex Equivalent of a Character
find_hex:
    push    rsi
    push    rdx
    push    rcx
    push    rbx
    push    rax
    pushf

    xor     rax,    rax
    xor     rcx,    rcx
    xor     rdx,    rdx
    mov     dl,     byte[buffer]
; Find Binary of a Character
; Consecutively subtracts powers of 2
find_binary:
    cmp     cl,     8
    jg      split_hex
    xor     rbx,    rbx
    mov     bl,     byte[powr_2+rcx]
    cmp     rdx,    rbx
    jl      skip_power
    add     al,     bl
    sub     dl,     bl
; Don't subtract if bigger than current value
skip_power:
    inc     rcx
    jmp     find_binary
; Split AL Register into AH and AL Registers
; Each register gets 4 bytes
split_hex:
    mov     ah,     al
    and     ah,     0xf0
    shr     ah,     4
    and     al,     0x0f
; Output Hex Equivalent to Character
; If it's the first hex of the pair - jmp and output
; If its second hex of the pair - output and prep for next pair
output_hex:
    xor     rbx,    rbx
    xor     rdx,    rdx
    mov     bl,     byte[switch]
    cmp     rbx,    rdx
    je      print_part_1
    xor     rdx,    rdx
    mov     [switch],   dl
    xor     rdx,    rdx
    mov     rdx,    hex
    xor     rbx,    rbx
    mov     bl,     al
    add     rdx,    rbx
    mov     rbx,    rdx
    call    output
    jmp     finalize
; Print first character in hex pair
print_part_1:
    mov     rdx,    1
    mov     [switch],   dl
    xor     rdx,    rdx
    mov     rdx,    hex
    xor     rbx,    rbx
    mov     bh,     ah
    add     dl,     bh
    mov     rbx,    rdx
    call    output
    jmp     output_hex
; Prepare for Next Hex Pair
; Check if a space or a newline is needed
finalize:
    xor     rbx,    rbx
    xor     rcx,    rcx
    mov     bl,     7
    mov     cl,     byte[column]
    cmp     cl,     bl
    jge     print_newline
    jmp     print_space
; Print Newline and Restart Column Count
print_newline:
    xor     rbx,    rbx
    mov     rbx,    newline
    call    output
    xor     rcx,    rcx
    jmp     done
; Add Space for Padding
print_space:
    xor     rbx,    rbx
    mov     rbx,    space
    push    rcx
    call    output
    pop     rcx
    inc     cl
; Adjust Column to Print
done:
    mov     [column],   cl    

    popf
    pop     rax
    pop     rbx
    pop     rcx
    pop     rdx
    pop     rsi
    ret

; Entry point
_start:
    ; Read in 1 Byte from STDIN
    mov     rax,    0x00    ; SYS_READ
    mov     rdi,    0x00    ; STDIN
    mov     rsi,    buffer
    mov     rdx,    0x01
    syscall

    ; Check for 0 Bytes Read
    cmp     al,     0x00
    je      exit
    call    find_hex
    
    jmp     _start

; Gracefully Exit Program
exit:
    mov     rax,    0x3C    ; SYS_EXIT
    xor     rdi,    rdi
    syscall 

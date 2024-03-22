.model small
.stack 100h
.data
buffer db 81 dup(?)
lineCount dw 0
outputCount dw 0
keys db 81 dup(?)
values db 81 dup(?)
keys_size dw 81
values_size dw 81

.code
main proc
    mov ax, @data
    mov ds, ax
    mov bx, 0

read_loop:
    mov ah, 3Fh
    lea dx, buffer
    mov cx, 80h
    int 21h
    or ax, ax
    jz ending
    mov si, offset buffer
    mov di, offset keys

find_space:
    lodsb
    cmp al, ' '
    je got_space
    stosb
    jmp find_space

got_space:
    mov byte ptr [di], '$'
    inc si
    mov di, offset values

store_values:
    lodsb
    stosb
    cmp al, '$'
    je print_keys_and_values
    jmp store_values

print_keys_and_values:
    mov ah, 09h
    lea dx, keys
    int 21h
    lea dx, values
    int 21h
    jmp read_loop

ending:
    mov ax, 4C00h
    int 21h
main endp
end main
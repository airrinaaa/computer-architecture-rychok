.model small
.stack 100h

.data
    buffer db 80h dup(?)

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ah, 3Fh       
    mov bx, 0        
    lea dx, buffer   
    mov cx, 80h      
    int 21h         

    cmp ax, cx
    jae checking_eof    
    mov cx, ax       

display:
    mov ah, 02h      
    mov si, 0        

print_loop:
    mov dl, buffer[si] ; Вставляємо символ для виведення
    int 21h           ; Виводимо символ
    inc si            ; Наступний символ
    loop print_loop   ; Повторюємо, поки CX != 0

checking_eof:
    ; Перевірка на кінець файлу
    mov ah, 3Eh       ; Функція DOS для перевірки EOF
    mov bx, 0     
    int 21h           ;DOS-переривання

    ; Якщо вказівник EOF не дорівнює 128 (0x80), - що файл закінчився
    cmp ax, 80h
    jne ending   ;EOF = завершуємо програму

    jmp main

ending:
    
    mov ax, 4C00h
    int 21h

main endp
end main

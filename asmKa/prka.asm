.model small
.stack 100h

.data
    buffer db 81 dup(?)  ; Збільшуємо розмір буфера на 1 для завершуючого нуль-символу
    lineCount dw 0        ; Лічильник кількості стрічок
    outputCount dw 0      ; Лічильник виведених стрічок

.code
main proc
    mov ax, @data
    mov ds, ax

    mov bx, 0  ; Обнулення лічильника стрічок

read_loop:
    ; Перевірка, чи виведено вже 1000 рядків
    mov ax, [outputCount]
    cmp ax, 1000
    je ending

    mov ah, 3Fh       
    mov bx, 0        
    lea dx, buffer   
    mov cx, 80h      
    int 21h         

    cmp ax, cx
    jae checking_eof    
    mov cx, ax       

    inc word ptr [lineCount]  ; Збільшення лічильника стрічок

    ; Перевірка, чи досягнуто 1000 стрічок
    mov ax, [lineCount]
    cmp ax, 1000
    je print_loop

    ; Виведення стрічки на екран
    mov ah, 02h      
    mov si, 0        

print_loop:
    mov dl, buffer[si] 
    int 21h           
    inc si            
    cmp dl, 0          ; Перевірка, чи досягли ми завершуючого нуль-символу
    je reset_buffer    ; Якщо так, очищуємо буфер та переходимо до нової ітерації зчитування
    loop print_loop   

    ; Збільшення лічильника виведених стрічок
    inc word ptr [outputCount]

    jmp read_loop

checking_eof:
    ; Перевірка на кінець файлу
    mov ah, 3Eh       ; Функція DOS для перевірки EOF
    mov bx, 0     
    int 21h           ;DOS-переривання

    ; Якщо вказівник EOF не дорівнює 128 (0x80), - що файл закінчився
    cmp ax, 80h
    jne ending   ;EOF = завершуємо програму

    jmp main

reset_buffer:
    mov byte ptr [buffer], 0  ; Очищення першого символу буфера
    jmp read_loop

ending:
    mov ax, 4C00h
    int 21h

main endp
end main

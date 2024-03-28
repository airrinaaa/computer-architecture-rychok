.model small
.stack 100h

.data
    symbol db 0 ; змінна, що необхідна для посимвольного зчитування 
    existingIndex dw 0 
    newIndex dw 0 
    keys db 10000*16 dup(0) ; Масив для зберігання ключів (максимум 10000 слів)
    keyTemp db 16 dup(0) 
    keyTempInd dw 0 
    ; змінна, що відповідає за тип зчитуваного символу(wordOrNumber == 0 - зчитується число, wordOrnumber == 1 - зчитується слово)
    wordOrNumber db 1 
    values dw 10000 dup(0) ; Масив для зберігання значень (максимум 10000 слів)
    num db 16 dup(0) 
    numberIndex dw 0 
    amountOfKeys dw 3000 dup(0) 

.code
main proc
    mov ax, @data
    mov ds, ax
read_loop:
; мітка Зчитування рядка зі стандартного вводу
    mov ah, 3Fh ; функція зчитування з файлу
    mov bx, 0 
    mov cx, 1 ; зчитування лише 1 байту
    mov dx, offset symbol ; завантаження адреси змінної symbol в dx
    int 21h   
    
    push ax ; збереження знаку рагістра ax до стеку

    call reading_symbol ; виклик підпрограми для обробки зчитуваного символа
    pop ax ;відновлення значення регістра ax зі стеку
    or ax,ax ; перевірка, чи ax == 0
    jnz read_loop ; якщо ax != 0, то продовження циклу зчитування

    mov si, offset num ; завантаження адреси змінної num в si
    dec numberIndex ; numberIndex = numberIndex - 1
    add si, numberIndex ; для переходу до наступного елемента масиву
    mov [si],0 

 
ending:
    ; завершення програми
    mov ax, 4C00h
    int 21h
main endp
end main

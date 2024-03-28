.model small
.stack 100h

.data
    symbol db 0 ; змінна, що необхідна для посимвольного зчитування 
    existingIndex dw 0 
    newIndex dw 0 
    keys db 10000*16 dup(0) ; Масив для зберігання ключів (максимум 10000 слів)
    tempKey db 16 dup(0) 
    tempKeyIndex dw 0 
    ; змінна, що відповідає за тип зчитуваного символу(wordOrNumber == 0 - зчитується число, wordOrnumber == 1 - зчитується слово)
    wordOrNumber db 1 
    values dw 10000 dup(0) ; Масив для зберігання значень (максимум 10000 слів)
    num db 16 dup(0) 
    numberIndex dw 0 ; вказує на позицію останнього символу
    amountOfKeys dw 3000 dup(0) 

.code
main proc
    mov ax, @data
    mov ds, ax
read_loop:
; мітка Зчитування рядка зі стандартного вводу
    mov ah, 3Fh ; функція зчитування з файлу
    mov bx, 0 ; стандартний ввід
    mov cx, 1 ; зчитування лише 1 байту
    mov dx, offset symbol ; завантаження адреси змінної symbol в dx
    int 21h   ; переривання
    
    push ax ; збереження знаку рагістра ax до стеку

    call reading_symbol ; виклик підпрограми для обробки зчитуваного символа
    pop ax ;відновлення значення регістра ax зі стеку
    or ax,ax ; перевірка, чи ax == 0
    jnz read_loop ; якщо ax != 0, то продовження циклу зчитування

    mov si, offset num ; завантаження адреси змінної num в si
    dec numberIndex ; numberIndex = numberIndex - 1
    add si, numberIndex ; для переходу до наступного елемента масиву
    mov [si],0 
    call convert_to_decimal ; виклик підпрограми для конвертації в число
    
 
ending:
    ; завершення програми
    mov ax, 4C00h
    int 21h
main endp


reading_symbol proc
    ; підпрограма, що відповідає за обробку кожного зчитаного символа
    cmp symbol,0Dh ; перевірка,чи є символ симколом нового рядка(CR)  
    jnz notCR
    cmp wordOrNumber,0 ; ;перевірка, чи змінна wordOrNumber == 0(це означає що зчитується число)
    jne stop_reading
    je stop_line_and_convert
   
notCR:
    ; мітка, що вказу на те що символ не є символом нового рядку(CR)
    cmp symbol,0Ah ; перевірка, чи зчитаний символ є символом нового рядка(LF)
    jnz notLF
    cmp wordOrNumber,0 ; ;перевірка, чи змінна wordOrNumber == 0(це означає що зчитується число)
    jnz stop_reading
    je stop_line_and_convert
notLF:
    ; мітка, що вказу на те що символ не є символом нового рядку(LF)
    cmp symbol,20h ; перевірка на пробіл
    jnz not_space 
    je space
stop_line_and_convert:
    mov wordOrNumber,1 ; wordOrNumber == 1
    call convert_to_decimal ; виклик підпрограми для конвертування з ASCII в десяткову систему числення
    jmp stop_reading
not_space:
    cmp wordOrNumber, 0 ; wordOrNumber == 0
    jnz iSWord
    je isNumber
isNumber:
    mov si, offset num ; завантаження в si адреси початку масиву 
    mov bx, numberIndex
    add si, bx ; для вказання наступної позиції в масиві
    mov al, symbol ; завантаження символу до al
    mov [si], al ; завантаження значення регістра al до масива 
    inc numberIndex 
    jmp stop_reading
space:
    mov wordOrNumber,0 ; wordOrNumber == 0
    call key_checking 
    jmp stop_reading
isWord:
    mov si, offset tempKey
    mov bx, tempKeyIndex ; завантаження значення наступної позиції в масиві tempKey
    add si, bx ; щоб вказати наступну позицію у масиві tempKey, куди буде збережений символ.
    mov al, symbol
    mov [si], al
    inc tempKeyIndex
     
stop_reading:
    ret
reading_symbol endp   



convert_to_decimal proc
    mov bx, 0 ; для подальшого зерігання значення числа у десятковій системі числення 
    mov cx,0 ; для відстеження позиції символу у числі
start_converting:
    ; мітка, яка відповідає за проходження по кожному символу у числі
    mov si, offset num
    add si, numberIndex ; вказує на позицію останнього символу у числі
    dec si ; для переходу до попереднього символу в числі
    sub si,cx ; si = si - cx(кількість символів які були оброблені)
    mov ax, 0
    mov al, [si]
    cmp ax, 45 ; перевірка чи символ = мінус     
    jnz positive_number
    je stop_converting
positive_number:        
    sub al,'0'; віднімання ASCII значення '0' від символу(перетворює символ цифри в цифрове значення) 
    push cx ; для подальшого відновлення, щоб знати скільки цифр у числі залишилось опрацювати
    cmp cx,0 ; щоб визначити чи це перша цифра в числі
    jnz multiplying_by_ten
    jmp saving_decimal

multiplying_by_ten:
    mov dx,10
    mul dx
    dec cx ; cx = cx - 1 
    cmp cx, 0
    je saving_decimal
    jnz multiplying_by_ten

saving_decimal:    
    pop cx
    add bx,ax ; у bx число у десятковій системі числення після множення на
    
    inc cx
    cmp cx, numberIndex
    jnz start_converting

saving_number_to_values_array:    

    mov si, offset values
    mov ax, existingIndex ; 
    shl ax, 1 ; зсув вліво на 1 біт для обчислення реального індексу
    add si, ax
    add bx, [si] ;
    mov [si],bx;save number into array
    call reset_used_values
stop_converting:
    ret
convert_to_decimal endp

reset_used_values proc
    mov numberIndex,0 
    mov cx,0
    call zero_array
    ret
reset_used_values endp

zero_array proc
fill_array_with_zeros:
    mov si, offset num
    add si, cx
    mov [si],0
    inc cx
    cmp cx,9
    je stop_filling
    jnz fill_array_with_zeros
    
stop_filling:
    ret
zero_array endp

end main

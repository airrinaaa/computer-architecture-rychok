.model small
.stack 100h

.data
    symbol db 0 ; змінна, що необхідна для посимвольного зчитування 
    existingIndex dw 0 
    newIndex dw 0 
    keys db 10000*16 dup(0) ; Масив для зберігання ключів (максимум 10000 слів)
    tempKey db 16 dup(0) ; для тимчасового зберігання символів нового ключа
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
    test ax,ax ; перевірка, чи ax == 0
    jnz read_loop ; якщо ax != 0, то продовження циклу зчитування

    mov si, offset num ; завантаження адреси змінної num в si
    dec numberIndex ; numberIndex = numberIndex - 1
    add si, numberIndex ; для переходу до наступного елемента масиву
    mov [si],0 
    call convert_to_decimal ; виклик підпрограми для конвертації в число
    call calculate_sum_and_average ; виклик підпрограми для обчислення середнього арифметичного
    
 
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
    jnz stop_reading
    jz stop_line_and_convert
   
notCR:
    ; мітка, що вказу на те що символ не є символом нового рядку(CR)
    cmp symbol,0Ah ; перевірка, чи зчитаний символ є символом нового рядка(LF)
    jnz notLF
    cmp wordOrNumber,0 ; ;перевірка, чи змінна wordOrNumber == 0(це означає що зчитується число)
    jnz stop_reading
    jz stop_line_and_convert
notLF:
    ; мітка, що вказу на те що символ не є символом нового рядку(LF)
    cmp symbol,20h ; перевірка на пробіл
    jnz not_space 
    jz space
stop_line_and_convert:
    mov wordOrNumber,1 ; wordOrNumber == 1
    call convert_to_decimal ; виклик підпрограми для конвертування з ASCII в десяткову систему числення
    jmp stop_reading
not_space:
    cmp wordOrNumber, 0 ; wordOrNumber == 0
    jnz iSWord
    jz isNumber
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
    jz stop_converting
positive_number:        
    add al,'0'; додавання ASCII значення '0' від символу(перетворює символ цифри в цифрове значення) 
    push cx ; для подальшого відновлення, щоб знати скільки цифр у числі залишилось опрацювати
    cmp cx,0 ; щоб визначити чи це перша цифра в числі
    jnz multiplying_by_ten
    jz saving_decimal

multiplying_by_ten:
    mov dx,10
    mul dx ; dx*ax
    dec cx ; cx = cx - 1 
    cmp cx, 0
    jz saving_decimal
    jnz multiplying_by_ten

saving_decimal:    
    pop cx
    add bx,ax ; у bx число у десятковій системі числення після множення на
    
    inc cx
    cmp cx, numberIndex
    jnz start_converting
    call saving_number_to_values_array
    
stop_converting:
    ret
convert_to_decimal endp

saving_number_to_values_array proc
    mov si, offset values
    mov ax, existingIndex ; 
    shl ax, 1 ; зсув вліво на 1 біт для обчислення реального індексу
    add si, ax
    add bx, [si] 
    mov [si],bx 
    call reset_used_values
saving_number_to_values_array endp


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
    jz stop_filling
    jnz fill_array_with_zeros
    
stop_filling:
    ret
zero_array endp

key_checking proc
    ; підпрограма для перевірки ключів
    mov ax,0
    mov bx, 0
    mov cx, 0
    mov dx,0
    ; обнулення регістрів
    cmp newIndex,0 
    jnz checking_existing_key ; newIndex != 0 перехід до пошуку ключів
    jz adding_new_key
key_searching:
    mov dx,0 ; для зберігання поточної позиції в масиві ключів
checking_existing_key:
    mov si, offset keys 
    shl cx, 4 ; зсув вправо на 4 біти для отримання наступного елемента масиву у пам'яті
    add si, cx
    shr cx,4 ; зсув назад на 4 біти
    add si, dx
    mov al,[si]; завантаження наступного символу
    mov di, offset tempKey
    add di,dx
    mov ah, [di]
    cmp al,ah
    jz keys_equal
    jnz different_keys

keys_equal:
    mov bx,1 ; вказує, що символи ключів співпадають
    jmp continue_checking

different_keys:
    mov bx,0 ;  вказує, що символи ключів не співпадають
    mov dx, 15; для переходу до наступного елемента масива
continue_checking:
    inc dx
    cmp dx,16 ; перевірка, чи порівняно уже весь ключ
    jnz checking_existing_key
    cmp bx,1 ; чи ключ знайдено
    jz key_present 

    inc cx ; перехід до наступного ключа
    cmp cx, newIndex ; перевірка чи оброблено всі ключі
    jnz key_searching
    mov cx, 0 
adding_new_key:
    mov si, offset tempKey 
    add si, cx ; для отримання адресу поточного символу для додавання до масиву keys
    mov di, offset keys 
    mov ax,  newIndex ; вказування місця нового ключа в масиві keys
    shl ax,4 
    add di,cx ; для отримання адреси місця для нового ключа
    add di, ax ; для отримання кінцевої адреси копіювання символів
    mov al, [si]
    mov [di], al 
    inc cx
    cmp cx, 16 ; перевірка, чи були додані всі символи ключа
    jz key_added
    jnz adding_new_key
    
key_added:
    call already_added
    jmp end_checking

key_present:
    mov existingIndex,cx
    mov si, offset amountOfKeys
    mov cx, existingIndex
    shl cx,1 ; кожне значення кількості ключів займає 2 байти
    add si, cx ; для отримання адреси кількості ключів, яку ми хочемо збільшити
    mov ax, [si]
    inc ax 
    mov [si],ax ;збереження нового значення в масиві ключів

end_checking:
    ; перевірка завершена
    mov tempKeyIndex,0
    mov cx,0
    call reset_keys_array
    ret
key_checking endp

already_added proc
    mov cx, newIndex
    mov existingIndex,cx ; вказує на останній індекс, де знаходиться останній доданий ключ
    inc newIndex ; збільшення значення newIndex, бо був доданий новий ключ
    mov si, offset amountOfKeys ; вказує на останній індекс у масиві amountOfKeys, де зберігається кількість ключів
    mov cx, existingIndex
    shl cx,1 ; cx = cx*2( щоб коректно вказати на необхідний елемент у масиві)
    add si, cx ; додавання зміщення для отримання адреси місця, де потрібно зберегти кількість ключів
    mov ax,1 ; додавання кількості ключів, бо був доданий новий ключ
    mov [si],ax
    ret
already_added endp

reset_keys_array proc 
;підпрограма для очищення масиву ключів(заповнення нулями)
fill_with_zeros:
    mov si, offset tempKey
    add si, cx
    mov [si],0
    inc cx
    cmp cx,15
    jnz fill_with_zeros 
    ret
reset_keys_array endp

calculate_sum_and_average proc
    mov cx,0 ; лічильник
calculate_average:
    mov si, offset values
    shl cx,1
    add si,cx ; перехід до наступного числа

    mov di, offset amountOfKeys
    add di, cx ; для переходу до відповідної кількості ключів
    shr cx,1 
    mov ax, [si] ; завантаження елемента масиву values до ax
    mov bx, [di] ; завантаження кількості ключа з amountOfKeys до bx
    mov dx,0
    div bx ; отримання середнього значення
    mov [si], ax ; запис середнього арифметичного до масиву values
    inc cx
    cmp cx, newIndex 
    jnz calculate_average
    ret
calculate_sum_and_average endp
end main

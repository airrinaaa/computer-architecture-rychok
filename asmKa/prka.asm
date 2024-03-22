.model small
.stack 100h
.data
filename    db "test.in", 0
buffer      db 255 dup (?)  ; Буфер для збереження рядка

.code
main:
    ; Відкриття файлу
    mov ah, 3Dh       ; Функція для відкриття файлу
    mov al, 0         ; Режим доступу (0 - читання)
    lea dx, filename  ; Адреса імені файлу
    int 21h           ; Виклик системного переривання DOS

    jc error          ; Перевірка на помилку (якщо CF встановлено, сталася помилка)

    mov bx, ax        ; Збереження дескриптора файлу

    ; Читання рядка з файлу
    mov ah, 3Fh       ; Функція для читання з файлу
    mov cx, 255       ; Максимальна довжина рядка
    lea dx, buffer    ; Адреса буфера для збереження рядка
    int 21h           ; Виклик системного переривання DOS

    jc error_read     ; Перевірка на помилку

    ; Обробка рядка (за потреби)
    ; Наприклад, виведення рядка на екран
    mov ah, 09h       ; Функція для виведення рядка
    lea dx, buffer    ; Адреса початку рядка
    int 21h           ; Виклик системного переривання DOS

    ; Закриття файлу
    mov ah, 3Eh       ; Функція для закриття файлу
    mov bx, bx        ; Передача дескриптора файлу
    int 21h           ; Виклик системного переривання DOS

    ; Вихід з програми
    mov ah, 4Ch       ; Функція для виходу з програми
    int 21h           ; Виклик системного переривання DOS

error:
    ; Обробка помилки відкриття файлу
    ; Ваш код обробки помилки

    ; Вихід з програми
    mov ah, 4Ch       ; Функція для виходу з програми
    int 21h           ; Виклик системного переривання DOS

error_read:
    ; Обробка помилки читання з файлу
    ; Ваш код обробки помилки

    ; Вихід з програми
    mov ah, 4Ch       ; Функція для виходу з програми
    int 21h           ; Виклик системного переривання DOS

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

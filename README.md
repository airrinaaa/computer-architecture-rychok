# Проект Ричок Ірини: Варіант 3

## Постановка задачі

Прочитати з stdin N рядків до появи EOF (максимум 10000 рядків).

Рядки розділяються АБО послідовністю байтів 0x0D та 0x0A (CR LF), або одним символом - 0x0D чи 0x0A.

Кожен рядок це пара "<key> <value>" (розділяються пробілом), де ключ - це текстовий ідентифікатор макс 16 символів (будь-які символи окрім white space chars - пробілу чи переводу на новий рядок), а значення - це десяткове ціле знакове число в діапазоні [-10000, 10000]. 

Провести групування: заповнити два масиви (або масив структур з 2х значень) для зберігання пари <key> та <average> , які будуть включати лише унікальні значення <key> а <average> - це средне значення, обраховане для всіх <value>, що відповідають конкретному значенню <key>.

Відсортувати алгоритмом bubble sort за <average>, та вивести в stdout  значення key від більших до менших (average desc), кожен key окремим рядком.
(Якщо merge sort - буде додатковий бал)

### Наприклад:
a1 1
a1 2
a1 3
a2 0
a2 10 
_Результат_ (average для a2=(0+10)/2=5, для a1=(1+2+3)/3 = 2):
a2
a1

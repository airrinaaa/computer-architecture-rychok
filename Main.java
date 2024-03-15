/*Прочитати з stdin N рядків до появи EOF (максимум 10000 рядків).
Рядки розділяються АБО послідовністю байтів 0x0D та 0x0A (CR LF), або одним символом - 0x0D чи 0x0A.
Кожен рядок це пара "<key> <value>" (розділяються пробілом), де ключ - це текстовий ідентифікатор макс 16 символів (будь-які символи окрім white space chars - пробілу чи переводу на новий рядок), а значення - це десяткове ціле знакове число в діапазоні [-10000, 10000].
Провести групування: заповнити два масиви (або масив структур з 2х значень) для зберігання пари <key> та <average> , які будуть включати лише унікальні значення <key> а <average> - це средне значення, обраховане для всіх <value>, що відповідають конкретному значенню <key>.
Відсортувати алгоритмом bubble sort за <average>, та вивести в stdout  значення key від більших до менших (average desc), кожен key окремим рядком.
Якщо merge sort - буде додатковий бал
file:Main.java
author: Rychok Iryna
 */
import java.util.*;
//головний метод
public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        Map<String, List<Double>> keyValueMap = new HashMap<>();
        int lineCount = 0; // Лічильник рядків

        while (scanner.hasNextLine()) {
            String line = scanner.nextLine();
            if (line.isEmpty()) {
                break; // Якщо введено порожній рядок, зупиняємо читання
            }

            lineCount++; // Збільшуємо лічильник рядків

            String[] parts = line.split(" ");
            if (parts.length != 2) {
                System.out.println("Некоректний формат рядка: " + line);
                continue; // Пропускаємо некоректний рядок
            }

            String key = parts[0];
            if (!isValidIdentifier(key)) {
                System.out.println("Некоректний ідентифікатор: " + key);
                continue; // Пропускаємо некоректний ідентифікатор
            }

            double value;
            try {
                value = Double.parseDouble(parts[1]);
                if (value < -10000 || value > 10000) {
                    System.out.println("Значення поза діапазоном [-10000, 10000]: " + value);
                    continue; // Пропускаємо некоректне значення
                }
            } catch (NumberFormatException e) {
                System.out.println("Некоректне значення: " + parts[1]);
                continue; // Пропускаємо некоректне значення
            }

            keyValueMap.compute(key, (k, v) -> (v == null) ? new ArrayList<>() : v).add(value);
        }

        if (lineCount > 1000) {
            System.out.println("Перевищено максимальну кількість рядків (1000).");
        } else {
            String[] keysArray = new String[keyValueMap.size()];
            double[] averagesArray = new double[keyValueMap.size()];
            int index = 0;

            for (String key : keyValueMap.keySet()) {
                double average = computeAverage(keyValueMap.get(key));
                keysArray[index] = key;
                averagesArray[index] = average;
                index++;
            }

            sortAverages(averagesArray, keysArray);

            for (int i = 0; i < keysArray.length; i++) {
                System.out.println(keysArray[i] + " " + averagesArray[i]);
            }
        }
    }

    /**
     * перевірка чи ключ - це текстовий ідентифікатор макс 16 символів
     * (будь-які символи окрім white space chars - пробілу чи переводу на новий рядок)
     * @param key
     * @return
     */
    private static boolean isValidIdentifier(String key) {
        return key.matches("^[^\\s]{1,16}$");
    }

    /**
     * метод для обчислення середнього арифметичного
     * @param values
     * @return
     */
    private static double computeAverage(List<Double> values) {
        if (values == null || values.isEmpty()) {
            return 0.0;
        }

        double sum = 0.0;
        for (double value : values) {
            sum += value;
        }

        return sum / values.size();
    }

    /**
     * метод для розділення масиву середніх значень на підмасиви довжиною в 1 елемент
     * @param averagesArray
     * @param keysArray
     */
    private static void sortAverages(double[] averagesArray, String[] keysArray) {
        int length = averagesArray.length;
        if (averagesArray.length < 2) {
            return;
        }
        int middleindex = length / 2;
        double[] lefthalf = new double[middleindex];
        double[] righthalf = new double[length - middleindex];
        for (int i = 0; i < middleindex; i++) {
            lefthalf[i] = averagesArray[i];
        }
        for (int i = middleindex; i < length; i++) {
            righthalf[i - middleindex] = averagesArray[i];
        }
        sortAverages(lefthalf, keysArray);
        sortAverages(righthalf, keysArray);
        mergeAverages(averagesArray, lefthalf, righthalf, keysArray);
    }

    /**
     * сортування(злиття) підмасивів
     * @param averagesArray
     * @param lefthalf
     * @param righthalf
     * @param keysArray
     */
    private static void mergeAverages(double[] averagesArray, double[] lefthalf, double[] righthalf, String[] keysArray) {
        int leftsize = lefthalf.length;
        int rightsize = righthalf.length;
        int i = 0;
        int j = 0;
        int k = 0;
        String key;
        while (i < leftsize && j < rightsize) {
            if (lefthalf[i] >= righthalf[j]) {
                averagesArray[k] = lefthalf[i];
                key = keysArray[k];
                keysArray[k] = keysArray[i];
                keysArray[i] = key;
                i++;
            } else {
                averagesArray[k] = righthalf[j];
                key = keysArray[k];
                keysArray[k] = keysArray[i];
                keysArray[i] = key;
                j++;
            }
            k++;
        }

        while (i < leftsize) {
            averagesArray[k] = lefthalf[i];
            key = keysArray[k];
            keysArray[k] = keysArray[i];
            keysArray[i] = key;
            i++;
            k++;
        }
        while (j < rightsize) {
            averagesArray[k] = righthalf[j];
            key = keysArray[k];
            keysArray[k] = keysArray[i];
            keysArray[i] = key;
            j++;
            k++;
        }
    }
}

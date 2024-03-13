import java.util.*;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        Map<String, List<Integer>> keyValueMap = new HashMap<>();
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

            int value;
            try {
                value = Integer.parseInt(parts[1]);
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
            for (String key : keyValueMap.keySet()) {
                double average = computeAverage(keyValueMap.get(key));
                System.out.println(key + " " + average);
            }
        }
    }

    private static boolean isValidIdentifier(String key) {
        return key.matches("^[^\\s]{1,16}$");
    }

    private static double computeAverage(List<Integer> values) {
        if (values == null || values.isEmpty()) {
            return 0.0;
        }

        int sum = 0;
        for (int value : values) {
            sum += value;
        }

        return (double) sum / values.size();
    }
}

import java.util.*;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        Map<String, List<Integer>> keyValueMap = new HashMap<>();
        int lineCount = 0; // Лічильник рядків

        while (scanner.hasNextLine()) {
            String line = scanner.nextLine();
            if (line.isEmpty()) {
                break; // Якщо введено порожній рядок - зупиняємо читання
            }

            lineCount++; // Збільшуємо лічильник рядків

            String[] parts = line.split(" ");
            String key = parts[0];
            int value = Integer.parseInt(parts[1]);

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

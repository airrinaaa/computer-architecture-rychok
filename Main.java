import java.util.*;
public class Main {
    public static void main(String[] args){
        Scanner scanner = new Scanner(System.in);
        Map<String, List<Integer>> keyValueMap = new HashMap<>();
        while (scanner.hasNextLine()){
            String line = scanner.nextLine();
            if (line.isEmpty()){
                break;//if an empty line entered then stop
            }
            String[] parts = line.split(" ");
            String key = parts[0];
            int value = Integer.parseInt(parts[1]);
            keyValueMap.compute(key, (k, v) -> (v == null) ? new ArrayList<>() : v).add(value);



        }
    }

    /**
     * method which calculates average value for each key
     * @param values
     * @return
     */
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



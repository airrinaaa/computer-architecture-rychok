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

}



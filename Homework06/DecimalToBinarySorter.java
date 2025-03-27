import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class DecimalToBinarySorter {
    public static void main(String[] args) {
        try {
            // Read input numbers
            List<Integer> numbers = readNumbers();
            
            // Convert to 16-bit signed representation
            List<Short> binaryValues = convertToBinary(numbers);
            
            // Sort using merge sort
            mergeSort(binaryValues, 0, binaryValues.size() - 1);
            
            // Calculate and print median
            printMedian(binaryValues);
            
            // Calculate and print average
            printAverage(binaryValues);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // Read numbers from stdin
    private static List<Integer> readNumbers() throws Exception {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        List<Integer> numbers = new ArrayList<>();
        String line;
        
        while ((line = reader.readLine()) != null && !line.trim().isEmpty()) {
            // Split by whitespace
            String[] parts = line.trim().split("\\s+");
            
            for (String part : parts) {
                if (!part.isEmpty()) {
                    try {
                        numbers.add(Integer.parseInt(part));
                    } catch (NumberFormatException e) {
                        // Ignore invalid numbers
                    }
                }
            }
            
            // Stop if max numbers reached
            if (numbers.size() >= 10000) break;
        }
        
        return numbers;
    }
    
    // Convert to 16-bit signed representation with overflow handling
    private static List<Short> convertToBinary(List<Integer> numbers) {
        List<Short> binaryValues = new ArrayList<>();
        
        for (int num : numbers) {
            // Handle overflow for 16-bit signed representation
            if (num > Short.MAX_VALUE) {
                binaryValues.add(Short.MAX_VALUE);
            } else if (num < Short.MIN_VALUE) {
                binaryValues.add(Short.MIN_VALUE);
            } else {
                binaryValues.add((short) num);
            }
        }
        
        return binaryValues;
    }
    
    // Merge sort implementation
    private static void mergeSort(List<Short> arr, int left, int right) {
        if (left < right) {
            int mid = left + (right - left) / 2;
            
            // Sort first and second halves
            mergeSort(arr, left, mid);
            mergeSort(arr, mid + 1, right);
            
            // Merge the sorted halves
            merge(arr, left, mid, right);
        }
    }
    
    private static void merge(List<Short> arr, int left, int mid, int right) {
        // Find sizes of two subarrays to be merged
        int n1 = mid - left + 1;
        int n2 = right - mid;
        
        // Create temporary arrays
        List<Short> L = new ArrayList<>(n1);
        List<Short> R = new ArrayList<>(n2);
        
        // Copy data to temporary arrays
        for (int i = 0; i < n1; ++i)
            L.add(arr.get(left + i));
        for (int j = 0; j < n2; ++j)
            R.add(arr.get(mid + 1 + j));
        
        // Merge the temporary arrays
        int i = 0, j = 0;
        int k = left;
        while (i < n1 && j < n2) {
            if (L.get(i) <= R.get(j)) {
                arr.set(k, L.get(i));
                i++;
            } else {
                arr.set(k, R.get(j));
                j++;
            }
            k++;
        }
        
        // Copy remaining elements of L[] if any
        while (i < n1) {
            arr.set(k, L.get(i));
            i++;
            k++;
        }
        
        // Copy remaining elements of R[] if any
        while (j < n2) {
            arr.set(k, R.get(j));
            j++;
            k++;
        }
    }
    
    // Print median
    private static void printMedian(List<Short> numbers) {
        if (numbers.isEmpty()) return;
        
        int size = numbers.size();
        int midIndex = size / 2;
        
        if (size % 2 == 0) {
            // Even number of elements, average of two middle values
            int median = (numbers.get(midIndex - 1) + numbers.get(midIndex)) / 2;
            System.out.println(median);
        } else {
            // Odd number of elements, middle value
            System.out.println(numbers.get(midIndex));
        }
    }
    
    // Print average
    private static void printAverage(List<Short> numbers) {
        if (numbers.isEmpty()) return;
        
        long sum = 0;
        for (Short num : numbers) {
            sum += num;
        }
        
        int average = (int) (sum / numbers.size());
        System.out.println(average);
    }
}
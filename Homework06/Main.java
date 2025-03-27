import java.io.*;
import java.util.*;

public class Main {
    public static void main(String[] args) {
        List<Integer> numbers = readNumbers(args[0]);
        List<Short> sortedNumbers = processNumbers(numbers);
        
        printMedian(sortedNumbers);
        printAverage(sortedNumbers);
    }
    
    private static List<Integer> readNumbers(String filename) {
        try (Scanner scanner = new Scanner(new File(filename))) {
            return scanner.tokens()
                .mapToInt(Integer::parseInt)
                .limit(10000)
                .boxed()
                .toList();
        } catch (Exception e) {
            System.err.println("Error reading file: " + e.getMessage());
            return Collections.emptyList();
        }
    }
    
    private static List<Short> processNumbers(List<Integer> numbers) {
        List<Short> binaryValues = numbers.stream()
            .map(num -> (short) Math.max(Short.MIN_VALUE, Math.min(Short.MAX_VALUE, num)))
            .collect(ArrayList::new, ArrayList::add, ArrayList::addAll);
        
        mergeSort(binaryValues, 0, binaryValues.size() - 1);
        return binaryValues;
    }
    
    private static void mergeSort(List<Short> arr, int left, int right) {
        if (left < right) {
            int mid = left + (right - left) / 2;
            
            mergeSort(arr, left, mid);
            mergeSort(arr, mid + 1, right);
            
            merge(arr, left, mid, right);
        }
    }
    
    private static void merge(List<Short> arr, int left, int mid, int right) {
        int n1 = mid - left + 1;
        int n2 = right - mid;
        
        List<Short> L = new ArrayList<>(n1);
        List<Short> R = new ArrayList<>(n2);
        
        for (int i = 0; i < n1; ++i)
            L.add(arr.get(left + i));
        for (int j = 0; j < n2; ++j)
            R.add(arr.get(mid + 1 + j));
        
        int i = 0, j = 0, k = left;
        
        while (i < n1 && j < n2) {
            if (L.get(i) <= R.get(j)) {
                arr.set(k++, L.get(i++));
            } else {
                arr.set(k++, R.get(j++));
            }
        }
        
        while (i < n1)
            arr.set(k++, L.get(i++));
        
        while (j < n2)
            arr.set(k++, R.get(j++));
    }
    
    private static void printMedian(List<Short> numbers) {
        if (numbers.isEmpty()) return;
        
        int midIndex = numbers.size() / 2;
        int median = numbers.size() % 2 == 0 
            ? (numbers.get(midIndex - 1) + numbers.get(midIndex)) / 2 
            : numbers.get(midIndex);
        
        System.out.println(median);
    }
    
    private static void printAverage(List<Short> numbers) {
        if (numbers.isEmpty()) return;
        
        int average = (int) numbers.stream()
            .mapToLong(Short::longValue)
            .sum() / numbers.size();
        
        System.out.println(average);
    }
}
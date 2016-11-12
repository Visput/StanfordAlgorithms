//
//  Task2.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 10/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

// Question 1:
// The file contains all of the integers between 1 and 10,000 (inclusive, with no repeats) in unsorted order. The integer in the ith row of the file 
// gives you the ith entry of an input array.
// Your task is to compute the total number of comparisons used to sort the given input file by QuickSort. 
// As you know, the number of comparisons depends on which elements are chosen as pivots, so we'll ask you to explore three different pivoting rules.
// You should not count comparisons one-by-one. Rather, when there is a recursive call on a subarray of length m, 
// you should simply add m−1 to your running total of comparisons. (This is because the pivot element 
// is compared to each of the other m−1 elements in the subarray in this recursive call.)
// WARNING: The Partition subroutine can be implemented in several different ways, 
// and different implementations can give you differing numbers of comparisons. For this problem, you should implement the Partition subroutine 
// exactly as it is described in the video lectures (otherwise you might get the wrong answer).

// Question 2:
// See the first question.
// DIRECTIONS FOR THIS PROBLEM:
// Compute the number of comparisons (as in Problem 1), always using the final element of the given array as the pivot element. 
// Again, be sure to implement the Partition subroutine exactly as it is described in the video lectures.
// Recall from the lectures that, just before the main Partition subroutine, 
// you should exchange the pivot element (i.e., the last element) with the first element.

// Question 3:
// See the first question.
// DIRECTIONS FOR THIS PROBLEM:
// Compute the number of comparisons (as in Problem 1), using the "median-of-three" pivot rule. 
// [The primary motivation behind this rule is to do a little bit of extra work to get much better performance on input arrays that are nearly sorted 
// or reverse sorted.] In more detail, you should choose the pivot as follows. Consider the first, middle, and final elements of the given array. 
// (If the array has odd length it should be clear what the "middle" element is; for an array with even length 2k, 
// use the kth element as the "middle" element. So for the array 4 5 6 7, the "middle" element is the second one ---- 5 and not 6!) 
// Identify which of these three elements is the median (i.e., the one whose value is in between the other two), and use this as your pivot. 
// As discussed in the first and second parts of this programming assignment, be sure to implement Partition exactly 
// as described in the video lectures (including exchanging the pivot element with the first element just before the main Partition subroutine).
// EXAMPLE: For the input array 8 2 4 5 7 1 you would consider the first (8), middle (4), and last (1) elements; 
// since 4 is the median of the set {1,4,8}, you would use 4 as your pivot element.
// SUBTLE POINT: A careful analysis would keep track of the comparisons made in identifying the median of the three candidate elements. 
// You should NOT do this. That is, as in the previous two problems, you should simply add m−1 to your running total of comparisons 
// every time you recurse on a subarray with length m.

// Question 4:
// See the first question.
// Use random pivot element.

import Foundation

struct Task2 {

    static func executeQuestion1() {
        execute(pivotIndex: { _, startIndex, _ in
            return startIndex
        })
    }
    
    static func executeQuestion2() {
        execute(pivotIndex: { _, _, endIndex in
            return endIndex
        })
    }
    
    static func executeQuestion3() {
        execute(pivotIndex: { array, startIndex, endIndex in
            let firstElement = (value: array[startIndex], index: startIndex)
            let lastElement = (value: array[endIndex], index: endIndex)
            
            let middleIndex = (endIndex + startIndex) / 2
            let middleElement = (value: array[middleIndex], index: middleIndex)
            
            if firstElement.value < middleElement.value && firstElement.value < lastElement.value {
                if middleElement.value <= lastElement.value {
                    return middleElement.index
                } else {
                    return lastElement.index
                }
                
            } else if firstElement.value > middleElement.value && firstElement.value > lastElement.value {
                if middleElement.value < lastElement.value {
                    return lastElement.index
                } else {
                    return middleElement.index
                }
                
            } else {
                return firstElement.index
            }
        })
    }
    
    static func executeQuestion4() {
        execute(pivotIndex: { _, startIndex, endIndex in
            return startIndex + Int(arc4random_uniform(UInt32(endIndex - startIndex + 1)))
        })
    }
}

extension Task2 {
    
    fileprivate static func execute(pivotIndex: ([Int], Int, Int) -> Int) {
        let inputArray = readInputArray()
        
        Stopwatch.run({
            let comparisonsCount = comparisonsInQuickSort(for: inputArray, pivotIndex: pivotIndex)
            print("comparisons: \(comparisonsCount)")
        })
    }
    
    fileprivate static func comparisonsInQuickSort(for array: [Int],
                                                   pivotIndex: ([Int], Int, Int) -> Int) -> Int {
        var comparisons = 0
        
        var resultArray = array
        
        quickSort(for: &resultArray,
                  pivotIndex: pivotIndex,
                  startIndex: 0,
                  endIndex: array.count - 1,
                  comparisons: &comparisons)
        
        return comparisons
    }
    
    @inline(__always) fileprivate static func quickSort(for array: inout [Int],
                                                        pivotIndex: ([Int], Int, Int) -> Int,
                                                        startIndex: Int,
                                                        endIndex: Int,
                                                        comparisons: inout Int) {
        if endIndex > startIndex {
            comparisons += endIndex - startIndex
            
            let currentPivotIndex = pivotIndex(array, startIndex, endIndex)
            let pivotValue = array[currentPivotIndex]
            
            if currentPivotIndex != startIndex {
                swap(&array[currentPivotIndex], &array[startIndex])
            }
            
            var smallerElementsLastIndex = startIndex

            for index in startIndex + 1 ... endIndex {
                if pivotValue > array[index] {
                    smallerElementsLastIndex += 1
                    
                    if smallerElementsLastIndex != index {
                        swap(&array[smallerElementsLastIndex], &array[index])
                    }
                }
            }
            
            if startIndex != smallerElementsLastIndex {
                swap(&array[startIndex], &array[smallerElementsLastIndex])
            }
            
            quickSort(for: &array, pivotIndex: pivotIndex, startIndex: startIndex, endIndex: smallerElementsLastIndex - 1, comparisons: &comparisons)
            quickSort(for: &array, pivotIndex: pivotIndex, startIndex: smallerElementsLastIndex + 1, endIndex: endIndex, comparisons: &comparisons)
            
        }
    }
}

extension Task2 {
    
    fileprivate static func readInputArray() -> [Int] {
        let filePath = Bundle.main.path(forResource: "Task2_Input", ofType: "txt")!
        let reader = StreamReader(path: filePath)!
        
        var result = [Int]()
        for line in reader {
            result.append(Int(line)!)
        }
        
        return result
    }
}

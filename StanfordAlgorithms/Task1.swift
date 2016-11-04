//
//  Task1.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 10/8/16.
//  Copyright © 2016 Tabbedout. All rights reserved.
//

// Question 1:
// Input file contains all of the 100,000 integers between 1 and 100,000 (inclusive) in some order, with no integer repeated.
// Your task is to compute the number of inversions in the file given, where the ith row of the file indicates the ith entry of an array.
// Because of the large size of this array, you should implement the fast divide-and-conquer algorithm covered in the video lectures.

import CoreFoundation
import Foundation

struct Task1 {
    
    static func executeQuestion1() {
        let inputArray = readInputArray()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let inversionsCount = inversions(in: inputArray)
        let finishTime = CFAbsoluteTimeGetCurrent()
        
        print("\n\ninversions: \(inversionsCount), time: \(finishTime - startTime)\n\n")
    }
    
}

extension Task1 {
    
    fileprivate static func readInputArray() -> [Int] {
        let filePath = Bundle.main.path(forResource: "Task1_Input", ofType: "txt")!
        let reader = StreamReader(path: filePath)!
        
        var result = [Int]()
        for line in reader {
            result.append(Int(line)!)
        }
        
        return result
    }
    
    fileprivate static func inversions(in array: [Int]) -> Int {
        var inversions = 0
        mergeSort(for: array, inversions: &inversions)
        return inversions
    }
    
    @inline(__always) @discardableResult fileprivate static func mergeSort(for array: [Int], inversions: inout Int) -> [Int] {
        if array.count > 1 {
            var array1 = [Int]()
            var array2 = [Int]()
            
            for (index, number) in array.enumerated() {
                if index < array.count / 2 {
                    array1.append(number)
                } else {
                    array2.append(number)
                }
            }
            
            let sortedArray1 = mergeSort(for: array1, inversions: &inversions)
            let sortedArray2 = mergeSort(for: array2, inversions: &inversions)
            
            return mergeSortedArrays(array1: sortedArray1,
                                     array2: sortedArray2,
                                     inversions: &inversions)
            
        } else {
            return array
        }
    }
    
    @inline(__always) fileprivate static func mergeSortedArrays(array1: [Int],
                                              array2: [Int],
                                              inversions: inout Int) -> [Int] {
        var mergedArray = [Int]()
        
        var index1 = 0
        var index2 = 0
        
        while index1 < array1.count || index2 < array2.count {
            
            if index1 == array1.count {
                mergedArray.append(array2[index2])
                index2 += 1
                
            } else if index2 == array2.count {
                mergedArray.append(array1[index1])
                index1 += 1
                
            } else {
                let value1 = array1[index1]
                let value2 = array2[index2]
                
                if value1 < value2 {
                    mergedArray.append(value1)
                    index1 += 1
                    
                } else {
                    mergedArray.append(value2)
                    index2 += 1
                    
                    inversions += array1.count - index1
                }
            }
        }
        
        return mergedArray
    }
}

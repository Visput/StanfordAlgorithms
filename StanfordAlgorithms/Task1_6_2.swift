//
//  Task1_6_2_2.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 11/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

// Question 1.
// The goal of this problem is to implement the "Median Maintenance" algorithm (covered in the Week 5 lecture on heap applications). 
// The text file contains a list of the integers from 1 to 10000 in unsorted order; 
// you should treat this as a stream of numbers, arriving one by one. Letting xi denote the ith number of the file, 
// the kth median mk is defined as the median of the numbers x1,…,xk. (So, if k is odd, 
// then mk is ((k+1)/2)th smallest number among x1,…,xk; if k is even, then mk is the (k/2)th smallest number among x1,…,xk.)
// In the box below you should type the sum of these 10000 medians, modulo 10000 (i.e., only the last 4 digits). 
// That is, you should compute (m1+m2+m3+⋯+m10000)mod10000.

import Foundation

struct Task1_6_2 {
    
    static func executeQuestion1() {
        let array = readInputArray()
        
        Stopwatch.run({
            let medianSumMod = computeMedianSumMod(in: array)
            print("median sum mod: \(medianSumMod)")
            
        })
    }
}

extension Task1_6_2 {
    
    static func computeMedianSumMod(in inputArray: [Int]) -> Int {
        var minHeap = IntHeap(type: .min)
        var maxHeap = IntHeap(type: .max)
        
        var medianSum = 0
        
        for element in inputArray {
            if let maxRootElement = maxHeap.rootElement {
                if element <= maxRootElement {
                    maxHeap.insert(element)
                    
                    if maxHeap.count - minHeap.count > 1 {
                        let elementToSwap = maxHeap.extractRootElement()!
                        minHeap.insert(elementToSwap)
                    }
                } else {
                    minHeap.insert(element)
                    
                    if minHeap.count - maxHeap.count > 1 {
                        let elementToSwap = minHeap.extractRootElement()!
                        maxHeap.insert(elementToSwap)
                    }
                }
            } else {
                maxHeap.insert(element)
            }
            
            let median = minHeap.count > maxHeap.count ? minHeap.rootElement! : maxHeap.rootElement!
            medianSum += median
            
        }
        
        return medianSum % inputArray.count
    }
}

extension Task1_6_2 {
    
    fileprivate struct IntHeap {
        
        enum `Type` {
            case min
            case max
        }
        
        private let type: Type
        private var storage = [Int]()
        
        var isEmpty: Bool {
            return storage.isEmpty
        }
        
        var count: Int {
            return storage.count
        }
        
        var rootElement: Int? {
            return storage.first
        }
        
        init(type: Type) {
            self.type = type
        }
        
        @discardableResult mutating func extractRootElement() -> Int? {
            guard !isEmpty else { return nil }
            guard count != 1 else { return storage.removeLast() }
            
            let firstIndex = 0
            let lastIndex = count - 1
            
            swapVertices(from: firstIndex, to: lastIndex)
            let element = storage.removeLast()
            
            downHeap(for: 0)
            
            return element
        }
        
        mutating func insert(_ element: Int) {
            storage.append(element)
            
            upHeap(for: count - 1)
        }
        
        @discardableResult mutating func delete(at index: Int) -> Int {
            let lastIndex = count - 1
            guard lastIndex != index else { return storage.removeLast() }
            
            swapVertices(from: index, to: lastIndex)
            let element = storage.removeLast()
            
            upOrDownHeap(for: index)
            
            return element
        }
        
        mutating func sorted() -> [Int] {
            var sortedArray = [Int]()
            while !isEmpty {
                sortedArray.append(extractRootElement()!)
            }
            return sortedArray
        }
        
        fileprivate mutating func upHeap(for index: Int) {
            let parentIndex = self.parentIndex(for: index)
            
            if reverseCompare(atIndex1: parentIndex, index2: index) {
                swapVertices(from: index, to: parentIndex)
                upHeap(for: parentIndex)
            }
        }
        
        fileprivate mutating func downHeap(for index: Int) {
            if let childIndex = childIndex(for: index), compare(atIndex1: childIndex, index2: index) {
                swapVertices(from: index, to: childIndex)
                downHeap(for: childIndex)
            }
        }
        
        fileprivate mutating func upOrDownHeap(for index: Int) {
            let parentIndex = self.parentIndex(for: index)
            
            if reverseCompare(atIndex1: parentIndex, index2: index) {
                swapVertices(from: index, to: parentIndex)
                upHeap(for: parentIndex)
                
            } else if let childIndex = childIndex(for: index), compare(atIndex1: childIndex, index2: index) {
                swapVertices(from: index, to: childIndex)
                downHeap(for: childIndex)
            }
        }
        
        fileprivate func parentIndex(for index: Int) -> Int {
            return (index - 1) / 2
        }
        
        fileprivate func childIndex(for index: Int) -> Int? {
            let firstIndex = index * 2 + 1
            let secondIndex = firstIndex + 1
            
            if firstIndex >= count {
                return nil
            } else {
                if secondIndex >= count {
                    return firstIndex
                } else {
                    return compare(atIndex1: firstIndex, index2: secondIndex) ? firstIndex : secondIndex
                }
            }
        }
        
        fileprivate mutating func swapVertices(from fromIndex: Int, to toIndex: Int) {
            swap(&storage[fromIndex], &storage[toIndex])
        }
        
        fileprivate func compare(atIndex1 index1: Int, index2: Int) -> Bool {
            switch type {
            case .min: return storage[index1] < storage[index2]
            case .max: return storage[index1] > storage[index2]
            }
        }
        
        fileprivate func reverseCompare(atIndex1 index1: Int, index2: Int) -> Bool {
            switch type {
            case .min: return storage[index1] > storage[index2]
            case .max: return storage[index1] < storage[index2]
            }
        }
    }
}

extension Task1_6_2 {
    
    fileprivate static func readInputArray() -> [Int] {
        let filePath = Bundle.main.path(forResource: "Task1_6_2_Input", ofType: "txt")!
        let reader = StreamReader(path: filePath)!
        
        let nonNumericSet = CharacterSet.decimalDigits.inverted
        
        var result = [Int]()
        for line in reader {
            let trimmedLine = line.trimmingCharacters(in: nonNumericSet)
            result.append(Int(trimmedLine)!)
        }
        
        return result
    }
}

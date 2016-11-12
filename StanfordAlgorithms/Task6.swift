//
//  Task6.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 11/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

// Question 1.
// The goal of this problem is to implement a variant of the 2-SUM algorithm (covered in the Week 6 lecture on hash table applications).
// The file contains 1 million integers, both positive and negative (there might be some repetitions!).
// This is your array of integers, with the ith row of the file specifying the ith entry of the array.
// Your task is to compute the number of target values t in the interval [-10000,10000] (inclusive) 
// such that there are distinct numbers x,y in the input file that satisfy x+y=t. 
// (NOTE: ensuring distinctness requires a one-line addition to the algorithm from lecture.)
// Write your numeric answer (an integer between 0 and 20001) in the space provided.

import Foundation
import CoreFoundation

struct Task6 {
    
    static func executeQuestion1() {
        
    }
}

extension Task6 {
    
    
    fileprivate static func readInputArray() -> [Int] {
        let filePath = Bundle.main.path(forResource: "Task6_Input", ofType: "txt")!
        let reader = StreamReader(path: filePath)!
        
        var result = [Int]()
        for line in reader {
            result.append(Int(line)!)
        }
        
        return result
    }
}

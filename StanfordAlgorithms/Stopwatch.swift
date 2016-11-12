//
//  Stopwatch.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 11/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import CoreFoundation

struct Stopwatch {
    
    static func run(_ task: () -> Void, completion: ((Double) -> Void)? = nil) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        task()
        
        let finishTime = CFAbsoluteTimeGetCurrent()
        let time = finishTime - startTime
        
        completion?(time)
        print("\nTime: \(time)\n")
    }
}

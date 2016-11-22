//
//  Task2_1_1And2.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 11/21/16.
//  Copyright © 2016 Visput. All rights reserved.
//

// Question 1:
// In this programming problem and the next you'll code up the greedy algorithms from lecture for minimizing the weighted sum of completion times..
// The file describes a set of jobs with positive and integral weights and lengths. It has the format
// [number_of_jobs]
// [job_1_weight] [job_1_length]
// [job_2_weight] [job_2_length]
// ...
// For example, the third line of the file is "74 59", indicating that the second job has weight 74 and length 59.
// You should NOT assume that edge weights or lengths are distinct.
// Your task in this problem is to run the greedy algorithm that schedules jobs in decreasing order of the difference (weight - length). 
// Recall from lecture that this algorithm is not always optimal. IMPORTANT: if two jobs have equal difference (weight - length), 
// you should schedule the job with higher weight first. Beware: if you break ties in a different way, you are likely to get the wrong answer. 
// You should report the sum of weighted completion times of the resulting schedule --- a positive integer --- in the box below.

// Question 2:
// For this problem, use the same data set as in the previous problem.
// Your task now is to run the greedy algorithm that schedules jobs (optimally) in decreasing order of the ratio (weight/length). 
// In this algorithm, it does not matter how you break ties. You should report the sum of weighted completion times 
// of the resulting schedule --- a positive integer --- in the box below.

import Foundation

struct Task2_1_1And2 {
    
    static func executeQuestion1() {
        var inputJobs = readInputJobs()
        
        Stopwatch.run({
            for (index, job) in inputJobs.enumerated() {
                inputJobs[index].priority = Double(job.weight - job.length)
            }
            
            let completionTime = computeCompletionTime(for: &inputJobs)
            print("completion time: \(completionTime)")
            
        })
    }
    
    static func executeQuestion2() {
        var inputJobs = readInputJobs()
        
        Stopwatch.run({
            for (index, job) in inputJobs.enumerated() {
                inputJobs[index].priority = Double(job.weight) / Double(job.length)
            }
            
            let completionTime = computeCompletionTime(for: &inputJobs)
            print("completion time: \(completionTime)")
            
        })
    }
}

extension Task2_1_1And2 {
    
    fileprivate static func computeCompletionTime(for inputJobs: inout [Job]) -> Double {
        inputJobs.sort(by: { job1, job2 -> Bool in
            if job1.priority == job2.priority {
                return job1.weight > job2.weight
            } else {
                return job1.priority > job2.priority
            }
        })
        
        typealias Time = (pureTime: Double, weightedTime: Double)
        let initialTime: Time = (pureTime: 0, weightedTime: 0)
        
        let completionTime = inputJobs.reduce(initialTime, { currentTime, job -> Time in
            var newTime = currentTime
            newTime.pureTime += Double(job.length)
            newTime.weightedTime += newTime.pureTime * Double(job.weight)
            
            return newTime
        }).weightedTime
        
        return completionTime
    }
}

extension Task2_1_1And2 {
    
    fileprivate struct Job {
        
        let length: Int
        let weight: Int
        var priority: Double = 0
        
        init(length: Int, weight: Int) {
            self.length = length
            self.weight = weight
        }
    }
}

extension Task2_1_1And2 {
    
    fileprivate static func readInputJobs() -> [Job] {
        let filePath = Bundle.main.path(forResource: "Task2_1_1And2_Input", ofType: "txt")!
        let reader = StreamReader(path: filePath)!
        
        var jobs = [Job]()
        for line in reader {
            let lineResult = line.components(separatedBy: " ").flatMap({ Int($0) })
            
            let job = Job(length: lineResult[1], weight: lineResult[0])
            jobs.append(job)
        }
        
        return jobs
    }
}


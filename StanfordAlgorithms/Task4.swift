//
//  Task4.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 11/3/16.
//  Copyright © 2016 Visput. All rights reserved.
//

// Question 1.
// The file contains the edges of a directed graph. Vertices are labeled as positive integers from 1 to 875714. 
// Every row indicates an edge, the vertex label in first column is the tail and the vertex label in second column 
// is the head (recall the graph is directed, and the edges are directed from the first column vertex to the second column vertex). 
// So for example, the 11th row looks liks : "2 47646". This just means that the vertex with label 2 has 
// an outgoing edge to the vertex with label 47646
// Your task is to code up the algorithm from the video lectures for computing strongly connected components (SCCs), 
// and to run this algorithm on the given graph.
// Output Format: You should output the sizes of the 5 largest SCCs in the given graph, in decreasing order of sizes, separated by commas 
// (avoid any spaces). So if your algorithm computes the sizes of the five largest SCCs to be 500, 400, 300, 200 and 100, 
// then your answer should be "500,400,300,200,100" (without the quotes). If your algorithm finds less than 5 SCCs, 
// then write 0 for the remaining terms. Thus, if your algorithm computes only 3 SCCs whose sizes are 400, 300, and 100, 
// then your answer should be "400,300,100,0,0" (without the quotes). (Note also that your answer should not have any spaces in it.)

import CoreFoundation
import Foundation

struct Task4 {
    
    static func executeQuestion1() {
        var (graph, reversedGraph) = readDirectedGraphs()
    
        let startTime = CFAbsoluteTimeGetCurrent()

        let finishingTimes = computeFinishingTimes(for: &reversedGraph)
        var modifiedGraph = apply(finishingTimes: finishingTimes, to: graph)
        let sccLengths = computeStronglyConnectedComponentLengths(for: &modifiedGraph)

        let finishTime = CFAbsoluteTimeGetCurrent()
        print("\nscc lengths: \(sccLengths)\n, time: \(finishTime - startTime)\n\n")
    }
}

extension Task4 {
    
    fileprivate static func readDirectedGraphs() -> (graph: DirectedGraph, reversedGraph: DirectedGraph) {
        let filePath = Bundle.main.path(forResource: "Task4_TestInput", ofType: "txt")!
        let numberOfVertices = 9
        let reader = StreamReader(path: filePath)!
        
        let nonNumericSet = CharacterSet.decimalDigits.inverted
        
        var graph = DirectedGraph(numberOfVertices: numberOfVertices)
        var reversedGraph = DirectedGraph(numberOfVertices: numberOfVertices)
        
        for line in reader {
            let lineResult = line.trimmingCharacters(in: nonNumericSet).components(separatedBy: nonNumericSet).map({ Int($0)! })
            
            reversedGraph.vertices[lineResult[1] - 1].edges.append(lineResult[0] - 1)
            graph.vertices[lineResult[0] - 1].edges.append(lineResult[1] - 1)
        }
        
        return (graph, reversedGraph)
    }
    
    fileprivate static func computeFinishingTimes(for graph: inout DirectedGraph) -> [Int] {
        var finishingTimes = [Int](repeating: -1, count: graph.vertices.count)
        var currentTime = -1
        
        for vertex in stride(from: graph.vertices.count - 1, through: 0, by: -1) {
            guard graph.vertices[vertex].explored == false else { continue }
            
            var leaderVertex = vertex
            executeDepthFirstSearch(for: &graph,
                                    finishingTimes: &finishingTimes,
                                    currentTime: &currentTime,
                                    leaderVertex: &leaderVertex,
                                    currentVertex: vertex)
        }
        
        return finishingTimes
    }
    
    @inline(__always) fileprivate static func executeDepthFirstSearch(for graph: inout DirectedGraph,
                                                                      finishingTimes: inout [Int],
                                                                      currentTime: inout Int,
                                                                      leaderVertex: inout Int,
                                                                      currentVertex: Int) {
        if graph.vertices[currentVertex].explored {
            currentTime += 1
            finishingTimes[leaderVertex] = currentTime
            
        } else {
            graph.vertices[currentVertex].explored = true
            
            for edge in graph.vertices[currentVertex].edges {
                leaderVertex = currentVertex
                
                executeDepthFirstSearch(for: &graph,
                                        finishingTimes: &finishingTimes,
                                        currentTime: &currentTime,
                                        leaderVertex: &leaderVertex,
                                        currentVertex: edge)
                
                if finishingTimes[currentVertex] == -1 {
                    currentTime += 1
                    finishingTimes[currentVertex] = currentTime
                }
            }
        }
    }
    
    fileprivate static func apply(finishingTimes: [Int], to graph: DirectedGraph) -> DirectedGraph {
        var resultGraph = DirectedGraph(numberOfVertices: graph.vertices.count)
        
        for vertex in 0 ..< graph.vertices.count {
            let targetVertex = finishingTimes[vertex]
            resultGraph.vertices[vertex] = graph.vertices[targetVertex]
            
            for (index, edge) in resultGraph.vertices[vertex].edges.enumerated() {
                let targetEdge = finishingTimes[edge]
                resultGraph.vertices[vertex].edges[index] = targetEdge
            }
        }
        
        return resultGraph
    }
    
    fileprivate static func computeStronglyConnectedComponentLengths(for graph: inout DirectedGraph) -> [Int] {
        var sccLengths = [Int]()
        
        for vertex in stride(from: graph.vertices.count - 1, through: 0, by: -1) {
            var pathLength = 0
            executeDepthFirstSearch(for: &graph,
                                    pathLength: &pathLength,
                                    currentVertex: vertex)
            
            if pathLength != 0 {
                sccLengths.append(pathLength)
            }
        }
        
        return sccLengths.sorted()
    }
    
    @inline(__always) fileprivate static func executeDepthFirstSearch(for graph: inout DirectedGraph,
                                                                      pathLength: inout Int,
                                                                      currentVertex: Int) {
        if graph.vertices[currentVertex].explored == false {
            graph.vertices[currentVertex].explored = true
            
            pathLength += 1
            
            for edge in graph.vertices[currentVertex].edges {
                executeDepthFirstSearch(for: &graph,
                                        pathLength: &pathLength,
                                        currentVertex: edge)
            }
            
        }
    }
}


extension Task4 {
    
    fileprivate struct DirectedGraph {
        var vertices: [Vertex]
        
        init(numberOfVertices: Int) {
            vertices = [Vertex](repeating: Vertex(), count: numberOfVertices)
        }
    }
    
    fileprivate struct Vertex {
        var explored = false
        var edges = [Int]()
    }
}
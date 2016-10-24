//
//  Task3_Impl1.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 10/22/16.
//  Copyright © 2016 Visput. All rights reserved.
//

// Question 1:
// The file contains the adjacency list representation of a simple undirected graph. 
// There are 200 vertices labeled 1 to 200. The first column in the file represents the vertex label, and the particular row 
// (other entries except the first column) tells all the vertices that the vertex is adjacent to. 
// So for example, the 6th row looks like : "6	155	56	52	120	......". This just means that the vertex with label 6 is adjacent to 
// (i.e., shares an edge with) the vertices with labels 155,56,52,120,......,etc
// Your task is to code up and run the randomized contraction algorithm for the min cut problem and use it on the above graph to compute the min cut. 
// (HINT: Note that you'll have to figure out an implementation of edge contractions. 
// Initially, you might want to do this naively, creating a new graph from the old every time there's an edge contraction. 
// But you should also think about more efficient implementations.) 
// (WARNING: As per the video lectures, please make sure to run the algorithm many times with different random seeds, 
// and remember the smallest cut that you ever find.) Write your numeric answer in the space provided. So e.g., 
// if your answer is 5, just type 5 in the space provided.

import CoreFoundation

struct Task3_Impl1 {
    
    static func executeQuestion1() {
        let inputAdjacencyList = StreamReader.readNumericAdjacencyList(from: "Task3_Input")
        let inputGraph = Graph(inputAdjacencyList)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let minCut = self.minCut(in: inputGraph)
        let finishTime = CFAbsoluteTimeGetCurrent()
        
        print("\n\nmin cut: \(minCut), time: \(finishTime - startTime)\n\n")
    }
}

extension Task3_Impl1 {
    
    fileprivate static func minCut(in graph: Graph) -> Int {
        let iterationsCount = 20000 //graph.vertices.count * graph.vertices.count * Int(log(Double(graph.vertices.count)))
        
        var minCut = edgesCountByContractingGraph(graph)
        for index in 1 ..< iterationsCount {
            let cut = edgesCountByContractingGraph(graph)
            if cut < minCut {
                minCut = cut
                print("minCut: \(minCut), index: \(index)")
            }
        }
        
        return minCut
    }
    
    @inline(__always) fileprivate static func edgesCountByContractingGraph(_ graph: Graph) -> Int {
        var contractedGraph = graph
        
        var existingVertexIndices = [Int](repeating: 0, count: graph.vertices.count)
        for index in 0 ..< existingVertexIndices.count {
            existingVertexIndices[index] = index
        }
        let contractionsCount = graph.vertices.count - 2
        for _ in 0 ..< contractionsCount {
            // Pick source and target vertices.
            let indexInExistingVertexIndices = Int(arc4random_uniform(UInt32(existingVertexIndices.count)))
            let sourceVertexIndex = existingVertexIndices[indexInExistingVertexIndices]
            
            var sourceVertex = contractedGraph.vertices[sourceVertexIndex]
            let sourceVertexEdgeIndex = Int(arc4random_uniform(UInt32(sourceVertex.edges.count)))
            
            let targetVertexIndex = sourceVertex.edges[sourceVertexEdgeIndex].value - 1 // Values start from 1, indices from 0.
            var targetVertex = contractedGraph.vertices[targetVertexIndex]
            
            // Merge source vertex to target vertex
            sourceVertex.edges.remove(at: sourceVertexEdgeIndex)
            targetVertex.edges = mergeSortedEdges(edges1: sourceVertex.edges,
                                                  edges2: targetVertex.edges,
                                                  edgeValueToRemove: sourceVertex.value)
            
            contractedGraph.vertices[targetVertexIndex] = targetVertex
            
            // Replace source vertex with target vertex in all other vertex's edges.
            for edge in sourceVertex.edges {
                let indexOfVertexToUpdate = edge.value - 1 // Values start from 1, indices from 0.
                var vertexToUpdate = contractedGraph.vertices[indexOfVertexToUpdate]
                let indexOfEdgeToDelete = binarySearch(in: vertexToUpdate.edges,
                                                       value: sourceVertex.value,
                                                       startIndex: 0,
                                                       endIndex: vertexToUpdate.edges.count - 1).index
                
                let edgeToDelete = vertexToUpdate.edges.remove(at: indexOfEdgeToDelete)
                
                let edgeToUpdateSearchResult = binarySearch(in: vertexToUpdate.edges,
                                                            value: targetVertex.value,
                                                            startIndex: 0,
                                                            endIndex: vertexToUpdate.edges.count - 1)
                if edgeToUpdateSearchResult.found {
                    var edgeToUpdate = vertexToUpdate.edges[edgeToUpdateSearchResult.index]
                    edgeToUpdate.count += edgeToDelete.count
                    vertexToUpdate.edges[edgeToUpdateSearchResult.index] = edgeToUpdate
                } else {
                    let edge = Edge(value: targetVertex.value, count: edgeToDelete.count)
                    vertexToUpdate.edges.insert(edge, at: edgeToUpdateSearchResult.index)
                }
                
                contractedGraph.vertices[indexOfVertexToUpdate] = vertexToUpdate
            }

            existingVertexIndices.remove(at: indexInExistingVertexIndices)
        }
        
        let edgesCount = contractedGraph.vertices[existingVertexIndices.first!].edges.first!.count
        
        return edgesCount
    }
    
    @inline(__always) fileprivate static func binarySearch(in edges: [Edge],
                                                           value: Int,
                                                           startIndex: Int,
                                                           endIndex: Int) -> (index: Int, found: Bool) {
        guard edges.count != 0 else {
            return (index: 0, found: false)
        }
        
        let splitIndex = (startIndex + endIndex) / 2
        
        if value < edges[splitIndex].value {
            if splitIndex > startIndex {
                return binarySearch(in: edges, value: value, startIndex: startIndex, endIndex: splitIndex - 1)
                
            } else {
                return (index: splitIndex, found: false)
            }
            
        } else if value > edges[splitIndex].value {
            if splitIndex < endIndex {
                return binarySearch(in: edges, value: value, startIndex: splitIndex + 1, endIndex: endIndex)
                
            } else {
                return (index: splitIndex + 1, found: false)
            }
            
        } else {
            return (index: splitIndex, found: true)
        }
    }
    
    @inline(__always) fileprivate static func binarySearch(in array: [Int],
                                                           value: Int,
                                                           startIndex: Int,
                                                           endIndex: Int) -> (index: Int, found: Bool) {
        guard array.count != 0 else {
            return (index: 0, found: false)
        }
        
        let splitIndex = (startIndex + endIndex) / 2
        
        if value < array[splitIndex] {
            if splitIndex > startIndex {
                return binarySearch(in: array, value: value, startIndex: startIndex, endIndex: splitIndex - 1)
                
            } else {
                return (index: splitIndex, found: false)
            }
            
        } else if value > array[splitIndex] {
            if splitIndex < endIndex {
                return binarySearch(in: array, value: value, startIndex: splitIndex + 1, endIndex: endIndex)
                
            } else {
                return (index: splitIndex + 1, found: false)
            }
            
        } else {
            return (index: splitIndex, found: true)
        }
    }
    
    @inline(__always) fileprivate static func mergeSortedEdges(edges1: [Edge],
                                                               edges2: [Edge],
                                                               edgeValueToRemove: Int) -> [Edge] {
        var mergedEdges = [Edge]()
        
        var index1 = 0
        var index2 = 0
        
        while index1 < edges1.count || index2 < edges2.count {
            
            var edgeToAdd: Edge! = nil
            
            if index1 == edges1.count {
                edgeToAdd = edges2[index2]
                index2 += 1
                
            } else if index2 == edges2.count {
                edgeToAdd = edges1[index1]
                index1 += 1
                
            } else {
                let edge1 = edges1[index1]
                let edge2 = edges2[index2]
                
                if edge1.value == edge2.value {
                    edgeToAdd = Edge(value: edge1.value, count: edge1.count + edge2.count)
                    index1 += 1
                    index2 += 1
                    
                } else if edge1.value < edge2.value {
                    edgeToAdd = edge1
                    index1 += 1
                    
                } else {
                    edgeToAdd = edge2
                    index2 += 1
                }
            }
            
            if edgeToAdd.value != edgeValueToRemove {
                mergedEdges.append(edgeToAdd)
            }
        }
        
        return mergedEdges
    }
}

extension Task3_Impl1 {
    
    fileprivate struct Graph {
        var vertices: [Vertex]
        
        init(_ adjacencyList: [[Int]]) {
            vertices = [Vertex]()
            for vertex in adjacencyList {
               vertices.append(Vertex(vertex))
            }
        }
    }
    
    fileprivate struct Vertex {
        var value: Int
        var edges: [Edge]
        
        init(_ array: [Int]) {
            value = array.first!
            edges = [Edge]()
            let sortedEdges = array.dropFirst().sorted()
            for edge in sortedEdges {
                edges.append(Edge(value: edge))
            }
        }
    }
    
    fileprivate struct Edge {
        var value: Int
        var count: Int
        
        init(value: Int, count: Int = 1) {
            self.value = value
            self.count = count
        }
    }
}

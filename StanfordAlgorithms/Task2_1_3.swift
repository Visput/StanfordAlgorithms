//
//  Task2_1_3.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 11/21/16.
//  Copyright © 2016 Visput. All rights reserved.
//

// Question 1:
// In this programming problem you'll code up Prim's minimum spanning tree algorithm.
// This file describes an undirected graph with integer edge costs. It has the format
// [number_of_nodes] [number_of_edges]
// [one_node_of_edge_1] [other_node_of_edge_1] [edge_1_cost]
// [one_node_of_edge_2] [other_node_of_edge_2] [edge_2_cost]
// ...
// For example, the third line of the file is "2 3 -8874", indicating that there is an edge connecting vertex #2 and vertex #3 that has cost -8874.
// You should NOT assume that edge costs are positive, nor should you assume that they are distinct.
// Your task is to run Prim's minimum spanning tree algorithm on this graph. 
// You should report the overall cost of a minimum spanning tree --- an integer, which may or may not be negative --- in the box below.

import Foundation

struct Task2_1_3 {
    
    static func executeQuestion1() {
        var graph = readGraph()

        Stopwatch.run({
            let cost = computeMinimumSpanningTreeCost(for: &graph)
            print("Minimum spanning tree cost: \(cost)")
        })
    }
}

extension Task2_1_3 {
    
    fileprivate static func computeMinimumSpanningTreeCost(for graph: inout Graph) -> Int {
        var heap = MinVertexHeap()
        
        let vertex = graph.vertices.first!
        let vertexIndex = vertex.value - 1
        let updatedVertex = graph.vertices[vertexIndex]
        updatedVertex.cost = 0
        
        processVertex(updatedVertex, in: &graph, heap: &heap)
        
        let cost = graph.vertices.reduce(0, { currentResult, vertex in
            return currentResult + vertex.cost!
        })
        
        return cost
    }
    
    fileprivate static func processVertex(_ vertex: Vertex, in graph: inout Graph, heap: inout MinVertexHeap) {
        let vertexIndex = vertex.value - 1
        graph.vertices[vertexIndex].explored = true
        
        for edge in vertex.edges {
            let edgeVertexIndex = edge.value - 1
            let edgeVertex = graph.vertices[edgeVertexIndex]
            
            if !edgeVertex.explored {
                let newCost = edge.length
                
                if edgeVertex.cost == nil {
                    edgeVertex.cost = newCost
                    heap.insert(edgeVertex)
                    
                } else {
                    if newCost < edgeVertex.cost! {
                        heap.delete(at: edgeVertex.indexInHeap!)
                        edgeVertex.cost = newCost
                        heap.insert(edgeVertex)
                    }
                }
            }
        }
        
        if let minVertex = heap.extractMin() {
            processVertex(minVertex, in: &graph, heap: &heap)
        }
    }
}

extension Task2_1_3 {
    
    fileprivate struct Graph {
        
        var vertices = [Vertex]()
    }
    
    fileprivate final class Vertex: Comparable {
        
        let value: Int
        var edges: [Edge]
        var cost: Int? = nil
        var indexInHeap: Int? = nil
        var explored: Bool = false
        
        init(value: Int) {
            self.value = value
            self.edges = []
        }
        
        static func <(lhs: Vertex, rhs: Vertex) -> Bool {
            guard let lhsCost = lhs.cost, let rhsCost = rhs.cost else { return false }
            return lhsCost < rhsCost
        }
        
        static func ==(lhs: Vertex, rhs: Vertex) -> Bool {
            return lhs.cost == rhs.cost
        }
    }
    
    fileprivate struct Edge {
        
        let value: Int
        let length: Int
    }
    
    fileprivate struct MinVertexHeap {
        
        private var storage = [Vertex]()
        
        var isEmpty: Bool {
            return storage.isEmpty
        }
        
        var count: Int {
            return storage.count
        }
        
        @discardableResult mutating func extractMin() -> Vertex? {
            guard !isEmpty else { return nil }
            guard count != 1 else { return storage.removeLast() }
            
            let firstIndex = 0
            let lastIndex = count - 1
            
            swapVertices(from: firstIndex, to: lastIndex)
            let vertex = storage.removeLast()
            
            downHeap(for: 0)
            
            return vertex
        }
        
        mutating func insert(_ vertex: Vertex) {
            storage.append(vertex)
            
            let index = storage.count - 1
            storage[index].indexInHeap = index
            
            upHeap(for: count - 1)
        }
        
        @discardableResult mutating func delete(at index: Int) -> Vertex {
            let lastIndex = count - 1
            guard lastIndex != index else { return storage.removeLast() }
            
            swapVertices(from: index, to: lastIndex)
            let vertex = storage.removeLast()
            
            upOrDownHeap(for: index)
            
            return vertex
        }
        
        fileprivate mutating func upHeap(for index: Int) {
            let parentIndex = self.parentIndex(for: index)
            
            if storage[parentIndex] > storage[index] {
                swapVertices(from: index, to: parentIndex)
                upHeap(for: parentIndex)
            }
        }
        
        fileprivate mutating func downHeap(for index: Int) {
            if let childIndex = minChildIndex(for: index), storage[childIndex] < storage[index] {
                swapVertices(from: index, to: childIndex)
                downHeap(for: childIndex)
            }
        }
        
        fileprivate mutating func upOrDownHeap(for index: Int) {
            let parentIndex = self.parentIndex(for: index)
            
            if storage[parentIndex] > storage[index] {
                swapVertices(from: index, to: parentIndex)
                upHeap(for: parentIndex)
                
            } else if let childIndex = minChildIndex(for: index), storage[childIndex] < storage[index] {
                swapVertices(from: index, to: childIndex)
                downHeap(for: childIndex)
            }
        }
        
        fileprivate func parentIndex(for index: Int) -> Int {
            return (index - 1) / 2
        }
        
        fileprivate func minChildIndex(for index: Int) -> Int? {
            let firstIndex = index * 2 + 1
            let secondIndex = firstIndex + 1
            
            if firstIndex >= count {
                return nil
            } else {
                if secondIndex >= count {
                    return firstIndex
                } else {
                    return storage[firstIndex] < storage[secondIndex] ? firstIndex : secondIndex
                }
            }
        }
        
        fileprivate mutating func swapVertices(from fromIndex: Int, to toIndex: Int) {
            swap(&storage[fromIndex], &storage[toIndex])
            storage[fromIndex].indexInHeap = fromIndex
            storage[toIndex].indexInHeap = toIndex
        }
    }
}

extension Task2_1_3 {
    
    fileprivate static func readGraph() -> Graph {
        let filePath = Bundle.main.path(forResource: "Task2_1_3_Input", ofType: "txt")!
        let reader = StreamReader(path: filePath)!
        
        var graph = Graph()
        
        let numberOfVertices = Int(reader.nextLine()!.components(separatedBy: " ").first!)!
        for vertexValue in 1 ... numberOfVertices {
            let vertex = Vertex(value: vertexValue)
            graph.vertices.append(vertex)
        }
        
        for line in reader {
            var lineResults = line.components(separatedBy: " ")
            let edgeValue1 = Int(lineResults[0])!
            let edgeValue2 = Int(lineResults[1])!
            let edgeLength = Int(lineResults[2])!
            
            graph.vertices[edgeValue1 - 1].edges.append(Edge(value: edgeValue2, length: edgeLength))
            graph.vertices[edgeValue2 - 1].edges.append(Edge(value: edgeValue1, length: edgeLength))
        }
        
        return graph
    }
}

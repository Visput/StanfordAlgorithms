//
//  Task5.swift
//  StanfordAlgorithms
//
//  Created by Uladzimir Papko on 11/7/16.
//  Copyright © 2016 Visput. All rights reserved.
//

// Question 1.
// The file contains an adjacency list representation of an undirected weighted graph with 200 vertices labeled 1 to 200. 
// Each row consists of the node tuples that are adjacent to that particular vertex along with the length of that edge. 
// For example, the 6th row has 6 as the first entry indicating that this row corresponds to the vertex labeled 6. 
// The next entry of this row "141,8200" indicates that there is an edge between vertex 6 and vertex 141 that has length 8200. 
// The rest of the pairs of this row indicate the other vertices adjacent to vertex 6 and the lengths of the corresponding edges.
// Your task is to run Dijkstra's shortest-path algorithm on this graph, using 1 (the first vertex) as the source vertex, 
// and to compute the shortest-path distances between 1 and every other vertex of the graph. 
// If there is no path between a vertex v and vertex 1, we'll define the shortest-path distance between 1 and v to be 1000000.
// You should report the shortest-path distances to the following ten vertices, in order: 7,37,59,82,99,115,133,165,188,197. 
// You should encode the distances as a comma-separated string of integers. So if you find that all ten of these vertices 
// except 115 are at distance 1000 away from vertex 1 and 115 is 2000 distance away, 
// then your answer should be 1000,1000,1000,1000,1000,2000,1000,1000,1000,1000. 
// Remember the order of reporting DOES MATTER, and the string should be in the same order in which the above ten vertices are given. 
// The string should not contain any spaces. Please type your answer in the space provided.

import CoreFoundation
import Foundation

struct Task5 {
    
    static func executeQuestion1() {
        let unreachableDistance = 1000000
        var graph = readGraph()
        let sourceVertex = graph.vertices.first!
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        calculateDijkstraShortestPaths(for: sourceVertex, in: &graph)
        
        let finishTime = CFAbsoluteTimeGetCurrent()
        print("time: \(finishTime - startTime)\n\n")
        
        for vertex in graph.vertices {
            print("vertex: \(vertex.value), distance: \(vertex.distance ?? unreachableDistance)")
        }
    }
}

extension Task5 {
    
    fileprivate static func readGraph() -> Graph {
        let filePath = Bundle.main.path(forResource: "Task5_Input", ofType: "txt")!
        let reader = StreamReader(path: filePath)!
        
        var graph = Graph()
        
        for line in reader {
            var lineResults = line.components(separatedBy: "\t")
            let vertexValue = Int(lineResults[0])!
            
            var edges = [Edge]()
            for index in 1 ..< lineResults.count - 1 {
                let edgeResults = lineResults[index].components(separatedBy: ",").flatMap({ Int($0) })
                let edge = Edge(value: edgeResults[0], length: edgeResults[1])
                edges.append(edge)
            }
            
            let vertex = Vertex(value: vertexValue, edges: edges)
            graph.vertices.append(vertex)
        }
        
        return graph
    }
    
    fileprivate static func calculateDijkstraShortestPaths(for vertex: Vertex, in graph: inout Graph) {
        var heap = MinHeap<Vertex>()
        
        let vertexIndex = vertex.value - 1
        graph.vertices[vertexIndex].distance = 0
        let updatedVertex = graph.vertices[vertexIndex]
        processVertex(updatedVertex, in: &graph, heap: &heap)
    }
    
    fileprivate static func processVertex(_ vertex: Vertex, in graph: inout Graph, heap: inout MinHeap<Vertex>) {
        let vertexIndex = vertex.value - 1
        graph.vertices[vertexIndex].explored = true
        
        for edge in vertex.edges {
            let edgeVertexIndex = edge.value - 1
            var edgeVertex = graph.vertices[edgeVertexIndex]
            
            if !edgeVertex.explored {
                let newDistance = vertex.distance! + edge.length
                
                if edgeVertex.distance == nil {
                    edgeVertex.distance = newDistance
                    edgeVertex.indexInHeap = heap.insert(edgeVertex)
                    graph.vertices[edgeVertexIndex] = edgeVertex
                    
                } else {
                    if newDistance < edgeVertex.distance! {
                        heap.delete(at: edgeVertex.indexInHeap!)
                        edgeVertex.distance = newDistance
                        edgeVertex.indexInHeap = heap.insert(edgeVertex)
                        graph.vertices[edgeVertexIndex] = edgeVertex
                    }
                }
            }
        }
        
        if let minVertex = heap.extractMin() {
            processVertex(minVertex, in: &graph, heap: &heap)
        }
    }
}

extension Task5 {
    
    fileprivate struct Graph {
        
        var vertices = [Vertex]()
    }
    
    fileprivate struct Vertex: Comparable {
        
        let value: Int
        let edges: [Edge]
        var distance: Int? = nil
        var indexInHeap: Int? = nil
        var explored: Bool = false
        
        init(value: Int, edges: [Edge]) {
            self.value = value
            self.edges = edges
        }
        
        static func <(lhs: Vertex, rhs: Vertex) -> Bool {
            guard let lhsDistance = lhs.distance, let rhsDistance = rhs.distance else { return false }
            return lhsDistance < rhsDistance
        }
        
        static func ==(lhs: Vertex, rhs: Vertex) -> Bool {
            return lhs.distance == rhs.distance
        }
    }
    
    fileprivate struct Edge {
        
        let value: Int
        let length: Int
    }
}

fileprivate struct MinHeap<Element: Comparable> {
    
    private var storage = [Element]()
    
    var isEmpty: Bool {
        return storage.isEmpty
    }
    
    var count: Int {
        return storage.count
    }
    
    @discardableResult mutating func extractMin() -> Element? {
        guard !isEmpty else { return nil }
        guard count != 1 else { return storage.removeLast() }
        
        let firstIndex = 0
        let lastIndex = count - 1
        
        swap(&storage[firstIndex], &storage[lastIndex])
        let element = storage.removeLast()
        
        downHeap(for: 0)
        
        return element
    }
    
    @discardableResult mutating func insert(_ element: Element) -> Int {
        storage.append(element)
        
        return upHeap(for: count - 1)
    }
    
    @discardableResult mutating func delete(at index: Int) -> Element {
        let lastIndex = count - 1
        guard lastIndex != index else { return storage.removeLast() }
        
        swap(&storage[index], &storage[lastIndex])
        let element = storage.removeLast()
        
        upOrDownHeap(for: index)
        
        return element
    }
    
    @discardableResult fileprivate mutating func upHeap(for index: Int) -> Int {
        let parentIndex = self.parentIndex(for: index)
        
        if storage[parentIndex] > storage[index] {
            swap(&storage[index], &storage[parentIndex])
            return upHeap(for: parentIndex)
        } else {
            return index
        }
    }
    
    @discardableResult fileprivate mutating func downHeap(for index: Int) -> Int {
        if let childIndex = minChildIndex(for: index), storage[childIndex] < storage[index] {
            swap(&storage[index], &storage[childIndex])
            return downHeap(for: childIndex)
        } else {
            return index
        }
    }
    
    @discardableResult fileprivate mutating func upOrDownHeap(for index: Int) -> Int {
        let parentIndex = self.parentIndex(for: index)
        
        if storage[parentIndex] > storage[index] {
            swap(&storage[index], &storage[parentIndex])
            return upHeap(for: parentIndex)
            
        } else if let childIndex = minChildIndex(for: index), storage[childIndex] < storage[index] {
            swap(&storage[index], &storage[childIndex])
            return downHeap(for: childIndex)
            
        } else {
            return index
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
}

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

struct Task5 {
    
    static func executeQuestion1() {

    }
}

extension Task5 {
    
}

fileprivate struct MinHeap<Element: Comparable> {
    
    private var storage = [Element]()
    
    var isEmpty: Bool {
        return storage.isEmpty
    }
    
    mutating func extractMin() -> Element? {
        guard !storage.isEmpty else { return nil }
        guard storage.count != 1 else { return storage.removeLast() }
        
        let firstIndex = 0
        let lastIndex = storage.count - 1
        
        swap(&storage[firstIndex], &storage[lastIndex])
        let element = storage.removeLast()
        
        downHeap(for: 0)
        
        return element
    }
    
    mutating func insert(_ element: Element) {
        storage.append(element)
        
        upHeap(for: storage.count - 1)
    }
    
    mutating func delete(at index: Int) -> Element {
        let lastIndex = storage.count - 1
        guard lastIndex != index else { return storage.removeLast() }
        
        swap(&storage[index], &storage[lastIndex])
        let element = storage.removeLast()
        
        upOrDownHeap(for: index)
        
        return element
    }
    
    fileprivate mutating func upHeap(for index: Int) {
        let parentIndex = self.parentIndex(for: index)
        
        if storage[parentIndex] > storage[index] {
            swap(&storage[index], &storage[parentIndex])
            upHeap(for: parentIndex)
        }
    }
    
    fileprivate mutating func downHeap(for index: Int) {
        if let childIndex = minChildIndex(for: index), storage[childIndex] < storage[index] {
            swap(&storage[index], &storage[childIndex])
            downHeap(for: childIndex)
        }
    }
    
    fileprivate mutating func upOrDownHeap(for index: Int) {
        let parentIndex = self.parentIndex(for: index)
        
        if storage[parentIndex] > storage[index] {
            swap(&storage[index], &storage[parentIndex])
            upHeap(for: parentIndex)
            
        } else if let childIndex = minChildIndex(for: index), storage[childIndex] < storage[index] {
            swap(&storage[index], &storage[childIndex])
            downHeap(for: childIndex)
        }
    }

    fileprivate func parentIndex(for index: Int) -> Int {
        return (index - 1) / 2
    }
    
    fileprivate func minChildIndex(for index: Int) -> Int? {
        let firstIndex = index * 2 + 1
        let secondIndex = firstIndex + 1
        
        if firstIndex >= storage.count {
            return nil
        } else {
            if secondIndex >= storage.count {
                return firstIndex
            } else {
                return storage[firstIndex] < storage[secondIndex] ? firstIndex : secondIndex
            }
        }
    }
}

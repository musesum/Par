//  Visitor.swift
//
//  Created by warren on 7/7/17.
//  Copyright © 2017 DeepMuse 
//  License: Apache 2.0 - see License file

import Foundation

/// Visit a node only once. Collect and compare with a set of nodes already visited.
public class Visitor {

    static var Id = 0  // unique identifier for each node
    public static func nextId() -> Int { Id += 1; return Id }
    
    public var visited = Set<Int>()

    public init () {
    }
    public init (_ id: Int) {
        visited.insert(id)
    }
    public func fromRemote() -> Visitor {
        visited.insert("remote".hash)
        return self
    }
    public func wasRemote() -> Bool {
        return visited.contains("remote".hash)
    }
    
    public func startVisit(_ id: Int,_ visit: @escaping ()->()) {
        if visited.contains(id) { return }
        visited.insert(id)
        visit()
    }

    public func newVisit(_ id: Int) -> Bool {
        
        if visited.contains(id) {
            return false
        }
        else {
            visited.insert(id)
            return true
        }
    }
}


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
    var lock = NSLock()
    
    private var visited = Set<Int>()

    public init (_ id: Int) {
        visited.insert(id)
    }
    public init (fromRemote: Bool = false) {
        if fromRemote {
            visited.insert("remote".hash)
        }
    }
    public func wasRemote() -> Bool {
        return visited.contains("remote".hash)
    }
    public func wasHere(_ id: Int) -> Bool {
        return visited.contains(id)
    }
    public func isLocal() -> Bool {
        return !wasRemote()
    }

    public func newVisit(_ id: Int) -> Bool {
        
        if visited.contains(id) {
            return false
        } else {
            lock.lock()
            visited.insert(id)
            lock.unlock()
            return true
        }
    }
}


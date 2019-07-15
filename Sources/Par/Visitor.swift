//
//  Visitor.swift
//  Par
//
//  Created by warren on 7/7/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.
//

import Foundation

/// Visit a node only once. Collect and compare with a set of nodes already visited.
public class Visitor {

    static var Id = 0  // unique identifier for each node
    public static func nextId() -> Int { Id+=1; return Id }
    
    public var visited = Set<Int>()

    public init (_ id: Int) {
        visited.insert(id)
    }

    public func newVisit(_ id:Int) -> Bool {
        
        if visited.contains(id) {
            return false
        }
        else {
            visited.insert(id)
            return true
        }
    }
}


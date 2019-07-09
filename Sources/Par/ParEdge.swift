//
//  ParEdge.swift
//  Par
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.
//

import Foundation

/// @available(iOS 11,*)
/// @available(watchOS 4,*)

/// An ParEdge connects and is shrared by two nodes

public class ParEdge {
    
    var id = -ParNode.nextId()
    
    static let MaxReps = 200
    
    var prev: ParNode!  // prefix
    var next: ParNode!  // suffix
    
    init(_ pre: ParNode!, _ suf: ParNode!) {
        
        prev = pre
        next = suf
        
        prev.suffixs.append(self)
        next.prefixs.append(self)
    }
}


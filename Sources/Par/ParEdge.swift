//
//  ParEdge.swift
//  Par
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation

/// An ParEdge connects and is shrared by two nodes
public class ParEdge {
    
    static let MaxReps = 200
    
    var nodePrev: ParNode!  // edge predecessor
    var nodeNext: ParNode!  // edge successor
    
    init(_ nodePrev_: ParNode!, _ nodeNext_: ParNode?) {
        
        nodePrev = nodePrev_
        nodeNext = nodeNext_
        
        nodePrev.edgeNexts.append(self)
        nodeNext.edgePrevs.append(self)
    }
}


//  ParAny+reduce.swift
//  Par iOS
//
//  Created by warren on 3/18/19.
//  License: Apache 2.0 - see License file

import Foundation

extension ParAny {

    /// when ParAny has a single leaf node with a value,
    /// then promote the leaf value

    public func promoteSingleLeaf() {

        if  value == nil,
            next.count == 1,
            next.first?.value != nil {

            value = next.first! .value
            next = []
        }
    }

    public func reduce(keywords:[String:Any]) -> [ParAny] {

        if value != nil { return [self] }

        var reduction = [ParAny]()
        for nexti in next {
            let reduced = nexti.reduce(keywords: keywords)
            reduction.append(contentsOf: reduced)
        }
        // self's node is a keyword, so keep it
        if keywords[node?.pattern ?? ""] != nil {
            next = reduction
            return [self]
        }
        return reduction
    }

    public func reduce1(keywords:[String:Any]) -> ParAny {

        let reduction = reduce(keywords: keywords)
        if reduction.count == 1 {
            return reduction[0]
        }
        return ParAny(ParNode("child"),reduction)
    }
    
}

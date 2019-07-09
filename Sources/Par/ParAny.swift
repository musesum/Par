//
//  ParAny.swift
//  Par
//
//  Created by warren on 7/13/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.
//

import Foundation

/// @available(iOS 11,*)
/// @available(watchOS 4,*)

/// A ParNode pattern plus instance of Any, which may be either a String or [ParAny]

public class ParAny {
    
    var id = ParNode.nextId()
    public var node: ParNode? // reference to parse node
    public var value: String? = nil // either a ParAny, [ParAny], or String
    public var next = [ParAny]()
    public var hops = 0
    var time = TimeInterval(0)
    
    init (_ node_  : ParNode!,
          _ value_ : String?,
          _ hops_  : Int = 0,
          _ time_  : TimeInterval = 0) {

        node = node_
        value = value_
        hops = hops_
        time = time_
    }

    init (_ node_  : ParNode!,
          _ next_ : [ParAny],
          _ hops_  : Int = 0,
          _ time_  : TimeInterval = 0) {

        node = node_
        next = next_
        hops = hops_
        time = time_
    }

    /// Search a strand of nodeAnys for the last node

    func lastNode() -> ParAny! {
        if let last = next.last {
            return last.lastNode()
        }
        return self
    }

    public func anyStr(flat: Bool=false) -> String {
        
        var ret = ""

        if !flat, let node = node {

            switch node.parOp {
            case .rgx,.quo: break
            default:
                if node.pattern.count > 0  {
                    ret += node.pattern + ":"
                }
            }
        }

        switch next.count {
        case 0: ret += (value != nil ? value! : "")
        case 1: ret += next[0].anyStr(flat:flat)
        default:
            var del = "("
            for nexti in next {
                ret += del + nexti.anyStr(flat:flat)
                del = ", "
            }
            ret += ")"
        }
        return ret
    }

    static func printAny(_ any:Any?) {

        switch any {

        case let parAny as ParAny:

            print(parAny.anyStr(), terminator:" ")

        case let anys as [Any]:

            for any in anys {
                printAny(any)
            }
        default: print(" *** failed ***")
        }
    }

    public func getFirstFloat() -> Float {
        if let value = next.first?.value {
            return Float(value) ?? Float.nan
        }
        return Float.nan
    }

    public func getFirstValue() -> String? {
        return next.first?.value 
    }
    
    public func harvestValues(_ keys:[String]) -> [String] {
        var result = [String]()
        for nexti in next {
            if let value = nexti.value {
                result.append(value)
            }
            else if let pattern = nexti.node?.pattern,
                keys.contains(pattern) {

                for nextii in nexti.next {

                    if let value = nextii.value {
                        result.append(value)
                    }
                }
            }
        }
        return result
    }

}

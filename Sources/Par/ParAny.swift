//  ParAny.swift
//
//  Created by warren on 7/13/17.
//  Copyright © 2017 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation

/// A ParNode pattern plus instance of Any, which may be either a String or [ParAny]
public class ParAny {

    public var node: ParNode? // reference to parse node
    public var value: String?    // either value or next, not both to support
    public var nextPars = [ParAny]() // either a String, ParAny, or [ParAny]

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
          _ next_  : [ParAny],
          _ hops_  : Int = 0,
          _ time_  : TimeInterval = 0) {

        node = node_
        nextPars = next_
        hops = hops_
        time = time_
    }

   /// Search a strand of nodeAnys for the last node
    func lastNode() -> ParAny! {
        for reversePar in nextPars.reversed() {
            if reversePar.value != nil ||
                reversePar.nextPars.count > 0 {
                return reversePar.lastNode()
            }
        }
        return self
    }

    public func makeScript(flat: Bool=false) -> String {
        
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

        switch nextPars.count {
        case 0: ret += (value != nil ? value! : "")
        case 1: ret += nextPars[0].makeScript(flat:flat)
        default:
            var del = "("
            for nextPar in nextPars {
                ret += del + nextPar.makeScript(flat:flat)
                del = ", "
            }
            ret += ")"
        }
        return ret
    }

    static func printScript(_ any:Any?) {

        switch any {

        case let parAny as ParAny:

            print(parAny.makeScript(), terminator:" ")

        case let anys as [Any]:

            for any in anys {
                printScript(any)
            }
        default: print(" *** failed ***")
        }
    }

    public func getFirstFloat() -> Float {
        if let value = nextPars.first?.value {
            return Float(value) ?? Float.nan
        }
        return Float.nan
    }

    public func getFirstValue() -> String? {
        return nextPars.first?.value
    }

    /// Convenience for collecting a tuple of multiple values.
    /// - note: Used by Tr3Graph.
    public func harvestValues(_ keys:[String]) -> [String] {
        var result = [String]()
        for nextPar in nextPars {
            if let value = nextPar.value {
                result.append(value)
            }
            else if let pattern = nextPar.node?.pattern,
                keys.contains(pattern) {

                for nextPari in nextPar.nextPars {

                    if let value = nextPari.value {
                        result.append(value)
                    }
                }
            }
        }
        return result
    }

}

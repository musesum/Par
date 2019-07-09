//
//  ParMatching.swift
//  Par
//
//  Created by warren on 8/5/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.
//

import Foundation

/// @available(iOS 11,*)
/// @available(watchOS 4,*)

/// An array of `[ParAny]`, which can reduce a single suffix
public class ParMatching {

    //TODO: this is makes ParAny's single threaded, move keywords to passthru function call. 

    var array = [ParAny]()

    func add (_ parAny: ParAny) {

        if let node = parAny.node {

            // ignore nodes with names that begin wiht "_"
            // such as `_end`, or `_'^\\s*[}]$\\s*'`
            if node.ignore { return }
            // /*???*/ if node.parOp == .quo { return }
        }
        array.append(parAny)
    }

    /// return parAny with fewest hops
    func bestCandidate() -> ParAny! {
        if array.count == 0 {
            return nil
        }
        var bestParAny = array.first!
        for parAny in array {
            if parAny.hops < bestParAny.hops {
                bestParAny = parAny
            }
        }
        return bestParAny
    }

    /// Reduce anys
    func reduce(_ node: ParNode!, _ goDeeper: Bool = false) -> ParAny! {

        switch array.count {

        case 0: return ParAny(node,nil)

        case 1:

            let first = array.first!
            switch first.node!.parOp {
            case .def,.and,.or:
                if goDeeper, node?.id != first.node?.id {
                    return ParAny(node,[first])
                }
                else {
                    return first
                }
            case .quo,.rgx,.match:
                return ParAny(node, first.value, first.hops)
            }

        default: break
        }

        // test if has subarray
        var hasSubarray = false
        for parAny in array {
            if let _ = getBlankAnys(parAny) {
                hasSubarray = true
                break
            }
        }
        if hasSubarray {
            var newArray = [ParAny]()
            for parAny in array {
                if let anys = getBlankAnys(parAny) {
                    for any2 in anys {
                        newArray.append(any2)
                    }
                }
                else {
                    newArray.append(parAny)
                }
            }
            array = newArray
        }
        var hops = 0
        for item in array {
            hops += item.hops
        }
        return ParAny(node,array,hops)
    }

    /// Accommodate a graph like this, example:
    ///
    /// ParNode("or",[ParNode("and"),...
    ///            ParNode("+",[ParNode("\"|\""), ...
    ///                      ParNode("and")])]), ...
    ///
    /// which splits ParNode("+",[]) into (.and,.many,"")
    /// So, the node.pattern is ""
    ///
    /// During a parse, the "" ParNode can contain a subarray,
    /// so promote it to the same level as its siblings
    ///
    /// for example, convert:
    ///     or:(path:show, (path:hide, path:setting, path:clear))
    /// to  or:(path:show, path:hide, path:setting, path:clear)

    func getBlankAnys(_ parAny:ParAny!) -> [ParAny]! {
        if  parAny?.node?.pattern == "",
            parAny?.value == nil {

            return parAny?.next
        }
        return nil
    }
}

class ParRecents: ParMatching {

    static let shortTermMemory = TimeInterval(3) // seconds

    func forget(_ timeNow: TimeInterval) {
        if array.count == 0 {
            return
        }
        let cutTime = timeNow - ParRecents.shortTermMemory
        if  timeNow <= 0 ||
            array.last!.time < cutTime {
            array.removeAll()
            return
        }
        var count = 0
        for parAny in array {
            if parAny.time < cutTime {
                count += 1
            }
            else {
                break
            }
        }
        if count > 0 {
            array.removeFirst(count)
        }
    }

 }

//
//  ParNode+find.swift
//  Par
//
//  Created by warren on 7/27/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.
//

import Foundation

/// @available(iOS 11,*)
/// @available(watchOS 4,*)

public extension ParNode {

    /// return first of alternate choices (boolean or)
    func testOr(_ parStr:ParStr, level:Int) -> ParAny! {

        let matching = ParMatching()
        let snap = parStr.getSnapshot()

        for suf in suffixs {

            parStr.putSnapshot(snap)

            if let parAny = suf.next.findMatch(parStr, level) {
                if parAny.hops == 0 {
                    return parAny
                }
                else {
                    matching.add(parAny)
                }
            }
        }
        return matching.bestCandidate()
    }

    /// Return a ParAny when all suffixes match (boolean and),
    /// otherwise, return nil to signify failure.
    ///
    /// A `.def` is not parsed; it defines a namespace.
    /// So, for the following example, b and c are parsed once once,
    /// since the `{` begins a `.def` of local statements.
    ///
    ///     a: b c { b:"bb", c:"cc" }
    ///
    func testAnd(_ parStr:ParStr, level:Int) -> ParAny! {
        let matching = ParMatching()
        for suf in suffixs {
            if let next = suf.next {
                // skip namespace
                if next.parOp == .def {
                    continue
                }
                if let parAny = next.findMatch(parStr, level) {
                    matching.add(parAny)
                    continue
                }
            }
            return nil
        }
        let reduced = matching.reduce(self)
        return reduced
    }

    /// return result, when parStr.sub matches external function, if it exists
    func testMatch(_ parStr:ParStr, level:Int) -> ParAny! {
        let result =  parStr.matchMatchStr(self)
        return result
    }

    /// return empty parAny, when parStr.sub matches pattern
    func testQuo(_ parStr:ParStr, level:Int) -> ParAny! {
        let result =  parStr.matchQuote(self)

        return result
    }

    /// return result, when parStr.sub matches regular expression in pattern */
    func testRegx(_ parStr:ParStr, level:Int) -> ParAny! {
        let result = parStr.matchRegx(self)
        return result
    }

    /// Repeat closure based on repetion range range and closure's result
    ///
    ///     - ?: 0 ... 1
    ///     - *: 0 ..< ParEdge.repMax, stop when false
    ///     - +: 1 ..< ParEdge.repMax, stop when false
    ///     - { repMin ..< repMax }
    ///
    internal func forRepeat(_ parStr:ParStr,
                            _ level: Int,
                            _ parStrLevel:ParStrLevel) -> ParAny! {

        var count = 0
        let matching = ParMatching()

        for _ in 0 ..< reps.repMax {
            // matched, so add
            if let parAny = parStrLevel(parStr,level) {
                matching.add(parAny)
            }
                // unmatched, fail minimum, so false
            else if count < reps.repMin {
                return nil
            }
                // unmatched, but met minimum, so true
            else {
                break
            }
            count += 1 
        }
        // met both minimum and maximum
        let reduced = matching.reduce(self,isName)
        return reduced
    }

    /// Search for pattern matches in substring with by transversing graph of nodes, with behavior:
    ///
    /// - or - alternation find first match
    /// - and - all suffixes must match
    /// - match - external function
    /// - quo - quoted string
    /// - rgx - regular expression
    ///
    /// - Parameter parStr: sub(string) of input to match
    /// - Parameter level: depth within graph search
    ///
    func findMatch(_ parStr: ParStr,_ level:Int=0) -> ParAny! {

        let snap = parStr.getSnapshot()
        var parAny: ParAny!

        parStr.trace(self, parAny, level)

        switch parOp {
        case .def,
             .and:   parAny = forRepeat(parStr,level,testAnd)
        case .or:    parAny = forRepeat(parStr,level,testOr)
        case .quo:   parAny = forRepeat(parStr,level,testQuo)
        case .rgx:   parAny = forRepeat(parStr,level,testRegx)
        case .match: parAny = forRepeat(parStr,level,testMatch)
        }

        if let parAny = parAny {
            foundCall?(parAny)
            parStr.trace(self,parAny,level)
        }
        else {
            parStr.putSnapshot(snap)
        }
        return parAny
    }

    /// Path must match all node names, ignores and/or/cardinals
    /// - parameter parStr: space delimited sequence of
    func findPath(_ parStr: ParStr) -> ParNode! {

        var val:String!
        switch parOp {
        case .rgx: val = parStr.matchRegx(self)?.value ?? nil
        case .quo: val = parStr.matchQuote(self, withEmpty: true)?.value ?? nil
        default:   val = ""
        }

        if let _ = val {
            //print("\(nodeStrId()):\(val) ", terminator:"")

            if parStr.isEmpty() {
                return self
            }
            for suf in suffixs {
                let ret = suf.next.findPath(parStr)
                if ret != nil {
                    return ret
                }
            }
            return self
        }
        return nil
    }

}

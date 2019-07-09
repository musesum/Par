//  ParWords.swift
//  Par
//
//  Created by warren on 7/28/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.

import Foundation

/// @available(iOS 11,*)
/// @available(watchOS 4,*)

/// Parse a sequential set of words
public class ParWords: ParStr {

    var recents = ParRecents()
    var words : [Substring]!
    var found : [Int]! // index of found
    var starti = 0 // where to start searching
    var count = 0
    var time = TimeInterval(0)

    public convenience init(_ str_: String) {

        self.init()
        update(str_)
    }

    public func update(_ str_: String,_ time_: TimeInterval = Date().timeIntervalSince1970) {
        
        str = str_
        time = time_
        restart() // set sub from str
        starti = 0
        count = 0
        words = sub.split(separator: " ")
        found = [Int](repeating: -1, count: words.count)
        recents.forget(time)
    }

    /// Snapshot of current ParWords state. To all parser to push and pop state.
    struct ParSetSnap {
        var sub: Substring
        var count: Int
        var starti: Int
        var foundi: Int
        init(_ ps:ParWords) {
            sub = ps.sub
            count = ps.count
            starti = ps.starti
            foundi = ps.found.count
        }
    }

    override func getSnapshot() -> Any! {
        return ParSetSnap(self)
    }

    override func putSnapshot(_ any:Any!) {
        if let snap = any as? ParSetSnap {
            sub = snap.sub
            count = snap.count
            starti = snap.starti
            let trim = found.count - snap.foundi
            if trim > 0 {
                found.removeLast(trim)
            }
        }
    }

    override func isEmpty() -> Bool {
        return sub.isEmpty
    }

    /** Minimun number of hops `min(<,^,v)` from expected, which is based on proximity to:
         < sequ(ence) position,
         ^ prev(ious) match,
         v next match.
     For example, when expecting `"muse show event yo"`:

     "muse show event yo"  ⟹ 
     //   min(<,^,v)   => hops
     0,0: min(0,.,0) += 0 => 0
     1,1: min(0,0,0) += 0 => 0
     2,2: min(0,0,0) += 0 => 0
     3,3: min(0,0,.) += 0 => 0

     "muse event show yo"  ⟹ 
      //   min(<,^,v)  => hops
     0,0: min(0,.,1) += 0 => 0
     1,2: min(1,1,2) += 1 => 1
     2,1: min(1,2,1) += 1 => 2
     3,3: min(0,1,.) += 0 => 2

     "yo muse show event"  ⟹ 
     //   min(<,^,v)   => hops
     0,1: min(1,.,0) += 0 => 0
     1,2: min(1,0,0) += 0 => 0
     2,3: min(1,0,4) += 0 => 0
     3,0: min(3,4,.) += 3 => 3

     "muse show yo event"  ⟹  hops:2
     "muse event yo show"  ⟹  hops:2
     */

    public func totalHops(trace:Bool = false) -> Int {
        if trace { print("\n//   min(<,^,v)   => hops") }
        var total = 0
        let count = words.count
        for i in 0 ..< count {
            let j =  found[i]
            let sequ =                abs(i-j) // sequence distance
            let prev = i > 0        ? abs(found[i-1]+1 - j) : Int.max
            let next = i < count-1  ? abs(found[i+1]-1 - j) : Int.max
            let shortest = min(sequ,prev,next) // min(<,^,v)
            total += shortest
            if trace {
                // print current state
                let prevStr = prev != Int.max ? String(prev) : "."
                let nextStr = next != Int.max ? String(next) : "."
                print("\(i),\(j): min(\(sequ),\(prevStr),\(nextStr)) += \(shortest) => \(total)")
            }
        }
        return total
    }

    /// Advance past match and return parAny with number of hops from normal sequence.
    /// - note: extension of ParStr, for a set of words match in parallel. Only use on a short phrase.
    func advancePar(_ node:ParNode!, _ index:Int, _ str: String!,_ deltaTime:TimeInterval = 0) -> ParAny! {

        /// matching a recent query is treated as a last resort, which is insured by adding cuttoff time for short term memory
        let penaltyHops = deltaTime > 0 ? Int(deltaTime + ParRecents.shortTermMemory) : 0

        // add from recent or has extra matches, so extend found
        if deltaTime > 0 || count >= found.count {
            found.append(index)
        }
            // could be sequence, which may mean that successor is a -1
        else {
            found[count] = index
        }

        var hops = abs(index-count) // sequence distance
        if index > 0 && found[index-1] > -1 {
            let previ = found[index-1]
            let expected = previ + 1
            hops = min(hops,abs(expected - index))
        }
        if index < found.count-1  && found[index+1] > -1 {
            let nexti = found[index+1]
            let expected = nexti - 1
            hops = min(hops,abs(expected - index))
        }
        print ("\(str!):\(hops + penaltyHops) ", terminator:"")
        count += 1
        starti = (index+1) % words.count

        let parAny = ParAny(node, str, hops + penaltyHops, Date().timeIntervalSince1970)
        recents.add(parAny)
        return parAny
    }


    /// match a quoted string and advance past match
    /// - note: extension of ParStr, for a set of words match in parallel. Only use on a short phrase.
    override func matchMatchStr(_ node:ParNode!) -> ParAny! {

        func match(_ i: Int) -> String! {
            let word = words[i]
            return node.matchStr?(word)
        }

        // search forward from last match
        if starti < words.count {
            for index in starti ..< words.count {
                if let ret = match(index) {
                    return advancePar(node,index,ret)
                }
            }
        }

        // continue search from leftovers
        if starti > 0 {
            for index in (0 ..< starti).reversed() {
                if let ret = match(index) {
                    return advancePar(node,index,ret)
                }
            }
        }
        // test non optional recents
        if recents.array.count > 0,
          node.reps.repMin >= 1 {

            for parAny in recents.array.reversed() {
                if  let id = parAny.node?.id, id == node.id,
                    let word = parAny.value {

                    let deltaTime = time - parAny.time
                    return advancePar(node, words.count, word, deltaTime)
                }
            }
        }
        return nil
    }


    /// match a quoted string and advance past match
    /// - note: extension of ParStr, for a set of words match in parallel. Only use on a short phrase.
    override func matchQuote(_ node:ParNode!, withEmpty:Bool=false) -> ParAny! {

        func match(_ i: Int) -> Bool {
            let word = words[i]
            if word == node.pattern {
                found[i] = abs(starti-i)
                return true
            }
            else {
                return false
            }
        }

        // for an empty value, maybe return true
        if node.pattern == "" { return withEmpty ? ParAny(node,"") : nil }

        // search forward from last match
        if starti < words.count {
            for index in starti ..< words.count {
                if match(index) {
                    return advancePar(node,index,node.pattern)
                }
            }
        }

        // continue search from leftovers
        if starti > 0 {
            for  index in (0 ..< starti).reversed()  {
                if match(index) {
                    return advancePar(node,index,node.pattern)
                }
            }
        }

        // test non optional recents
        if recents.array.count > 0,
           node.reps.repMin >= 1 {

            for parAny in recents.array.reversed() {
                if  let id = parAny.node?.id, id == node.id {

                    let deltaTime = time - parAny.time
                    return advancePar(node, words.count, node.pattern, deltaTime)
                }
            }
        }
        return nil
    }

    /// Match regular expression to beginning of substring
    /// - parameter regx: compiled regular expression
    /// - returns: ranges of inner value and outer match, or nil
    func matchRegxWord(_ regx: NSRegularExpression, _ word: Substring) -> RangeRegx! {

        let nsRange = NSRange( word.startIndex ..< word.endIndex, in: str)
        let match = regx.matches(in: str, options:[], range:nsRange)
        if match.count == 0 { return nil }
        switch match[0].numberOfRanges {
        case 1:  return RangeRegx(match[0].range(at: 0), match[0].range(at: 0), str)
        default: return RangeRegx(match[0].range(at: 1), match[0].range(at: 0), str)
        }
    }

    /// Match regular expression to word
    /// - parameter regx: compiled regular expression
    /// - returns: ranges of inner value and outer match, or nil
    func matchRegxWord(_ regx: NSRegularExpression, _ word: String) -> RangeRegx! {

        let nsRange = NSRange( word.startIndex ..< word.endIndex, in: word)
        let match = regx.matches(in: word, options:[], range:nsRange)
        if match.count == 0 { return nil }
        switch match[0].numberOfRanges {
        case 1:  return RangeRegx(match[0].range(at: 0), match[0].range(at: 0), word)
        default: return RangeRegx(match[0].range(at: 1), match[0].range(at: 0), word)
        }
    }

    /// Nearest match a regular expression and advance past match
    /// - note: extension of ParStr, for a set of words match in parallel. Only use on a short phrase.
    override func matchRegx(_ node:ParNode!) -> ParAny! {

        if node!.regx == nil { return nil }

        func match(_ i: Int) -> String! {
            let word = words[i]
            if let rangeRegx = matchRegxWord(node!.regx!,word) {
                let result = String(str[rangeRegx.matching])
                return result
            }
            else {
                return nil
            }
        }

        // search forward from last match
        if starti < words.count {
            for index in starti ..< words.count {
                if let word = match(index) {
                    return advancePar(node,index,word)
                }
            }
        }

        // continue search from leftovers
        if starti > 0 {
            for  index in (0 ..< starti).reversed()  {
                if let word = match(index) {
                    return advancePar(node,index,word)
                }
            }
        }
        // test non optional recents
        if recents.array.count > 0,
            node.reps.repMin >= 1 {

            for parAny in recents.array.reversed() {
                if  let id = parAny.node?.id, id == node.id,
                    let word = parAny.value,
                    let _ = matchRegxWord(node!.regx!,word) {

                    let deltaTime = time - parAny.time
                    return advancePar(node, words.count, word, deltaTime)
                }
            }
        }
        return nil
    }

}

//
//  ParNode+print.swift
//  Par
//
//  Created by warren on 7/1/17.
//  Copyright © 2017 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation

public extension ParNode {
    
    func printGraph(_ visitor: Visitor,_ level: Int = 0) {
        
        // deja vu? stop when revisiting same node
        if visitor.visited.contains(id) { return }
        visitor.visited.insert(id)
        
        var left = "⦙ " + " ".padding(toLength: level, withPad: " ", startingAt: 0)
        for pre in prefixs {
            left += pre.prev.nodeOpId() + " "
        }
        left = left.padding(toLength: 32, withPad: " ", startingAt: 0)

        let center = (nodeOpId()+" ").padding(toLength: 24, withPad: " ", startingAt: 0)
        
        var right = ""
        for suf in suffixs {
            right += suf.next.nodeOpId() + " "
        }
        
        print (left + center + right)
        
        for suf in suffixs {
            suf.next.printGraph(visitor, level+1)
        }
    }
    
    /// Text representation of node and its unique ID. Used in graph dump, which includes before and after edges.
    func nodeOpId() -> String {

        let opStr =  ( pattern=="" ? parOp.rawValue :
            parOp == .or    ? "|"   :
            parOp == .match  ? "()"  : ".")

        let repStr = (reps.count == .one ? "" : reps.makeScript()) + (reps.surf ? "~" : "")

        switch parOp {
        case .quo:  return "\"\(pattern)\"\(repStr + opStr)\(id)" //+ repStr
        case .rgx:  return "\'\(pattern)\'\(repStr + opStr)\(id)" //+ repStr
        default:    return "\(pattern)\(repStr + opStr)\(id)" //+ parOp.rawValue // + idStr
        }
    }
    /// Text representation of node and its unique ID. Used in graph dump, which includes before and after edges.
    func nodeStrId() -> String {

       switch parOp {
        case .quo:  return "\"\(pattern)\".\(id)"
        case .rgx:  return "\'\(pattern)\'.\(id)"
        default:    return pattern + ".\(id)"
        }
    }
    /// Text representation of node. Often used in generating a script from the graph.
    func makeScript(isLeft: Bool) -> String {
        
        var str = "" // return value

        switch parOp {
        case .quo:  str = "\"" + pattern + "\""
        case .rgx:  str =  "'" + pattern.replacingOccurrences(of: "\"", with: "\\\\\"", options: .regularExpression) + "'"
        default:    str = pattern
        }
        if !isLeft, reps.count != .one {
            str += reps.makeScript()
        }
        return str
    }

    /// Space adding for indenting hierarcical list
    func pad(_ level:Int) -> String {
        let pad = " ".padding(toLength: level*4, withPad: " ", startingAt: 0)
        return pad
    }

    ///
    func makeSuffixs(_ level:Int) -> String {

        /// And suffixs
        func makeAnd(_ next:ParNode!) -> String {
            
            if next.isName {
                return next.makeScript(isLeft: false)
            }

            var str = "" // return value
            let dels = next.reps.count == .one ? ["", " ", ""] : ["(", " ", ")"]
            var del = dels[0]
            for nextSuffix in next.suffixs {

                str += del
                
                if let next2 = nextSuffix.next {
                    // As of xcode 9 beta 3, 
                    if      next2.parOp == .or    { str += makeOr(next2) }
                    else if next2.parOp == .and   { str += makeAnd(next2) }
                    else if next2.parOp == .match { str += next2.makeScript(level:level) + "()" }
                    else                          { str += next2.makeScript(level:level+1) }
                }
                del = dels[1]
            }
            str += dels[2] + next.reps.makeScript()
            return str
        }
        
        /// Alternation suffixes
        func makeOr(_ next:ParNode!, inner:Bool = false) -> String {

            var str = "" // return value
            let dels = inner ? ["", " | ", ""] :  [" (", " | ", ")"]
            var del = dels[0]
            for suf2 in next.suffixs {
                
                str += del
                
                if let suf2Node = suf2.next {
                    if      suf2Node.parOp == .and { str += makeAnd(suf2Node) }
                    else if suf2Node.parOp == .or  { str += makeOr(suf2Node, inner:true) }
                    else                           { str += suf2Node.makeScript(level:level+1) }
                }
                del = dels[1]
            }
            str += dels[2] + next.reps.makeScript() + " "
            return str
        }
        
        /// Definition
        func makeDef(_ next:ParNode!) -> String {
            
            var str = " {\n" // return value
            for suf2 in next.suffixs {
                str += suf2.next.makeScript(level:level+1) + "\n"
            }
            str += pad(level) + "}\n"
            return str
        }
        
        // ────────────── begin ──────────────
        
        var str = ""
        for suf in suffixs {
            
            if let next = suf.next {
               switch next.parOp {
                case .and:   str += makeAnd(next)
                case .or:    str += makeOr(next)
                case .def:   str += makeDef(next)
                case .match: str += next.makeScript(isLeft: false) + "() "
                default:     str += next.makeScript(isLeft: false) + " "
                }
            }
        }
        return str
    }
    
    /**
     Print graph as script starting form left side of statement.
     The resulting script should resemble the original script.
     - Parameter level: depth of namespace hierarchy, where some isName nodes are local
     */
    func makeScript(level:Int = 0) -> String {

        var str = "" // return value

        if isName { str += pad(level) + makeScript(isLeft: true) + " : " }
        else      { str +=              makeScript(isLeft: false)  }
        
        str += makeSuffixs(level)
        return str
    }

     ///  [par.end.^([ \n\t,;]*|[/][/][^\n]*)]
    func scriptLineage(_ level:Int) -> String {
        if let prefix = prefixs.first, level > 0, let prev = prefix.prev {
             return prev.scriptLineage(level-1) + "." + pattern
        }
        else {
            return pattern
        }
    }

}

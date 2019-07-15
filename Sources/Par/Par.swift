//  Par.Swift
//
//  Created by warren on 6/22/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.

import Foundation

/// @available(iOS 11,*)
/// @available(watchOS 4,*)

/// Parse a script into a new graph, using static `par` graph
public class Par {
    
    public static let shared = Par()
    static var trace = false
    static var trace2 = false

    public var parStr = ParStr()

    public func parse(script: String) -> ParNode! {
        parStr.str = script
        parStr.restart()
        if let parAny = Par.par.findMatch(parStr) {

            let result = parAny.anyStr()
                .replacingOccurrences(of: "(", with: "(\n")
                .replacingOccurrences(of: ",", with: ",\n")

            if Par.trace2 { print(result + divider()) }

            if let node = parseParAny(parAny) {
                return node
            }
        }
        return nil
    }
    
    public func parse(_ filename: String, _ ext:String) -> ParNode! {

        parStr.read(filename, ext)
        
        if Par.trace { print(parStr.str + divider()) }
        
        if let parAny = Par.par.findMatch(parStr) {
        
            let result = parAny.anyStr()
                .replacingOccurrences(of: "(", with: "(\n")
                .replacingOccurrences(of: ",", with: ",\n")
            
            if Par.trace2 { print(result + divider()) }
            
            if let node = parseParAny(parAny) {
                return node
            }
        }
        return nil
    }
    
    func parseParAny(_ parAny:ParAny) -> ParNode? {
        
        if let def = parseNode(ParNode("def:"),parAny,0) {
            def.parOp = .and         // change .def in top node to .and so that it will parse
            def.connectReferences(Visitor(0)) // find references to elsewhere in namespace and connect edges
            def.distillSuffixs(Visitor(0))    // reduce nested suffix of same type
            return def
        }
        return nil
    }
    
     func parseNode(_ superNode: ParNode!, _ parAny: ParAny,_ level:Int) -> ParNode! {
        
        /// keep track of last node in which to apply repeat
        var lastNode = superNode
        
        if Par.trace2 {
            print("\n" + pad(level) + superNode.makeScript(isLeft:false), terminator:": ")
        }
        
        /// parse list of sibling pars and promote up a level
        func addAnd(_ pattern: String,_ any: ParAny) {
            if let subNode = parseNode(ParNode(pattern), any, level+1) {
                for suf in subNode.suffixs {
                    let _ = ParEdge(superNode,suf.next)
                }
            }
        }
        /// apply literal to current par
        func addLeaf(_ pattern: String) {
            if Par.trace2 { print(pattern, terminator:" ") }
            lastNode = ParNode(pattern)
            let _ = ParEdge(superNode, lastNode)
        }
        /// Apply list of sub pars as an `after` edge
        func addSub(_ pattern: String,_ any: ParAny) {
            lastNode = parseNode(ParNode(pattern), any, level+1)
            let _ = ParEdge(superNode,lastNode)
        }

        /// Apply name to super node
        ///
        /// par:( name:ask, and:(regex:muse, and:(...)))
        ///
        func addName(_ pattern: String,_ any: ParAny) {
            if Par.trace2 { print ("`" + pattern, terminator:"` ") }
            superNode.isName = true
            superNode.parOp = .and
            superNode.pattern = pattern
            lastNode = superNode
        }

        /// Apply repeat * ? + ~ to current node
        func addReps(_ nexti: ParAny) {
            if let nextValue = nexti.value {
                lastNode?.reps.parse(nextValue)
            }
        }

        func printError(_ msg: String,_ any: Any?) {
            print("*** unexpected \(msg):", terminator:"")
            print(any ?? "??")
        }

        for nexti in parAny.next {

            if Par.trace2 { print (nexti.node?.pattern ?? "nil", terminator:" ") }

            switch nexti.node?.pattern {
                
            case "par"?:    addSub(":",nexti)
            case "or"?:     addSub("|",nexti)
            case "and"?:    addSub("&",nexti)
            case "right"?:  addSub("&",nexti)
            case "parens"?: addSub("&",nexti)

            case "name"?:   addName(nexti.value! , nexti)
            case "reps"?:   addReps(nexti)
                
            case "path"?:   addLeaf(nexti.value!)
            case "quote"?:  addLeaf("\"" + (nexti.value!) + "\"")
            case "regex"?:  addLeaf("'" + (nexti.value!) + "'")
            case "match"?:  addLeaf(nexti.value! + "()")

            default: break // printError ("anys.any", any)
            }
        }
        return superNode
    }


    /// Attach a closure to a node, which is called when that node is found
    func setFound(_ str: String, _ foundCall_: @escaping ParAnyVoid) {
        
        let searchStr = ParStr(str) // finds an explicit path
        
        if let node = Par.par.findPath(searchStr) {
            
            node.foundCall = foundCall_
        }
        else {
            print("*** \(#function)(\"\(str)\") lost at \"\(parStr.sub)\"")
        }
    }
    
    /// explicitly declared parse graph
    /// - note: new lines delimits a new statement with a left and right side
    static let par = ParNode(":", [
        
        ParNode("par+", [
            
            ParNode("name",[
                ParNode("'^([A-Za-z_]\\w*)'")]),
            
            ParNode("reps?", [
                ParNode("'^([\\~]?[\\?\\+\\*]|\\{\\d+[,]?\\d*\\}[\\~]?)'")]), // ~ ? + * {2,3}
            
            ParNode("\":\""),
            
            ParNode("right+|",[
                
                ParNode("or",[
                    ParNode("and"),
                    ParNode("+", [
                        ParNode("\"|\""),
                        ParNode("right")])]),
                
                ParNode("and+",[
                    ParNode("leaf|",[
                        ParNode("match",[ ParNode("'^([A-Za-z_]\\w*)\\(\\)'")]),
                        ParNode("path", [ ParNode("'^[A-Za-z_][A-Za-z0-9_.]*'")]),
                        ParNode("quote",[ ParNode("'^\"([^\"]*)\"'")]),
                        ParNode("regex",[ ParNode("'^\'(?i)([^\']+)\''")])]),
                    ParNode("reps")]),
                
                ParNode("parens",[
                    ParNode("\"(\""),
                    ParNode("right"),
                    ParNode("\")\""),
                    ParNode("reps")])]),
            
            ParNode("sub?",[
                ParNode("\"{\""),
                ParNode("_end"),
                ParNode("par"),
                ParNode("\"}\""),
                ParNode("_end")
                ]),

            ParNode("_end?",[ParNode("'^([ \\n\\t,;]*|[/][/][^\\n]*)'")])])])
}




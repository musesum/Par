//  ParNode.swift
//
//  Created by warren on 6/22/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.

import Foundation

/// @available(iOS 11,*)
/// @available(watchOS 4,*)

public typealias ParAnyVoid = (_ parAny: ParAny) -> Void
public typealias ParStrLevel = (_ parStr:ParStr, _ level:Int) -> ParAny?

/// A node in a parse graph with prefix and suffix edges.
public class ParNode {
    
    static var Id = 0  // unique identifier for each node
    static func nextId() -> Int { Id+=1; return Id }
    public var id = ParNode.nextId()

    /// name, quote, or regex pattern 
    public var pattern = ""

    /**
     Kind of operation
     - def: namespace declaration only
     - or: of alternate choices, take first match in after[]
     - and: all Pars in after[] must be true
     - rgx: regular expression - true if matches pattern
     - quo: quote - true if path matches pattern
     - match: function -- false if nil, true when returning a string
     */
    enum ParOp : String { case

        def   = ":",  // namespace declaration only
        or    = "|",  // of alternate choices, take first match in after[]
        and   = "&",  // all Pars in after[] must be true
        rgx   = "'",  // regular expression - true if matches pattern
        quo   = "\"", // quote - true if path matches pattern
        match = "()"  // function - false if nil, true when returning a string
    }
    var parOp = ParOp.quo         // type of operation on parseStr

    public var reps = Repetitions()    // number of allowed repetitions to be true
    var matchStr: SubStr?       // call external function to see of matches start of substring, return any
    var foundCall: ParAnyVoid? // call external function with Found array, when true
    var prefixs = [ParEdge]()      // prefix edges, sequence is important for maintaining precedence
    var suffixs = [ParEdge]()      // suffix edges, sequence is important for maintaining precedence
    var regx: NSRegularExpression? // compiled regular expression
    var ignore = false
    var isName = false            // lValue; name as in `name: what ever`

    func graft(_ node_:ParNode) {
        
        parOp = node_.parOp
        matchStr = node_.matchStr
        prefixs = node_.prefixs
        suffixs = node_.suffixs
        regx = node_.regx
        ignore = node_.ignore
        isName = true 
    }
    public init (_ pat:String,_ after_:[ParNode]) {
        
        (parOp,reps,pattern) = splitPat(pat)
        
        switch parOp {
        case .rgx:  regx = ParStr.compile(pattern)
        default: break
        }
        
        for node in after_ {
            let _ = ParEdge(self,node)
        }
        // top node of hierarchy for explicit declarations in code
        // which is declared top down, so includes a list of after_ Nodes
        // ignore while parsing script
        if parOp == .def {
            connectReferences(Visitor(0))
        }
    }
    
    public init (_ pat:String) {
        
        (parOp,reps,pattern) = splitPat(pat)
        
        switch parOp {
        case .rgx:  regx = ParStr.compile(pattern)
        default: break
        }
    }

     /// Split a pattern into operation, repetitions, string
     ///
    func splitPat(_ pat:String) -> (ParOp,Repetitions,String) {
        
        // return values
        var op = ParOp.and
        var rep = Repetitions()
        var str = ""
        
        var count = pat.count
        var starti = 0 // starting index
        var hasLeftParen = false
        
        scanning: for char in pat.reversed() {
            
            switch char {
            case ":":   op = .def ; count -= 1
            case "&":   op = .and ; count -= 1
            case "|":   op = .or  ; count -= 1
                
            case ")":   hasLeftParen = true
            case "(":   if hasLeftParen { op = .match ; count -= 2 ; break scanning}
            case "\"":  op = .quo ; count -= 1 ; break scanning
            case "'":   op = .rgx ; count -= 1 ; break scanning
                
            case "?":   rep = Repetitions(.opt)  ; count -= 1
            case "*":   rep = Repetitions(.any)  ; count -= 1
            case "+":   rep = Repetitions(.many) ; count -= 1
            case ".":   rep = Repetitions(.one)  ; count -= 1
            default:    break scanning
            }
        }
        
        switch op {
            
        case .rgx:
            scanning: for char in pat {
                switch char {
                case "\\":  starti += 1; count -= 1
                case "'":   starti += 1; count -= 1
                case "_":   starti += 1; count -= 1; ignore = true
                default: break scanning
                }
            }
        case .quo: if pat.first == "\"" { starti += 1; count -= 1}; ignore = true
        default:   if pat.first == "_"  { starti += 1; count -= 1 ; ignore = true }
        }
        
        if count <= pat.count {
            let patStart = pat.index(pat.startIndex, offsetBy: starti)
            let patEnd = pat.index(patStart, offsetBy: count)
            str = String(pat[patStart ..< patEnd])
            if parOp == .quo {
                str = str.replacingOccurrences(of: "\\\"", with: "\"")
            }
        }
        return (op,rep,str)
    }


    /// Attach a closure to detect a match at beginning of parStr.sub(string)
    ///
    /// - Parameter str: space delimited sequence
    /// - Parameter matchStr_: closure to compare substring
    ///
    public func setMatch(_ str: String, _ matchStr_: @escaping SubStr) {

        print("\"\(str)\"  ⟹  ", terminator:"")

        if let parAny = findMatch(ParStr(str)) {

            if let foundParAny = parAny.lastNode(),
                let foundNode = foundParAny.node {

                print("\(foundNode.nodeStrId()) = \(String(describing: matchStr_))")
                foundNode.matchStr = matchStr_
            }
        }
        else {
            print("failed ***")
        }
    }
    
    func go(_ parStr: ParStr, _ nodeValCall: @escaping ParAnyVoid) {

        if let parAny = findMatch(parStr) {
            nodeValCall(parAny)
        }
        else {
            print("*** \(#function)(\"\(parStr.str)\") not found")
        }
    }
}


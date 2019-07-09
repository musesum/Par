//
//  ParNode+connect.swift
//  Par
//
//  Created by warren on 7/7/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.
//

/// @available(iOS 11,*)
/// @available(watchOS 4,*)

public extension ParNode {
    
    /**
     Search self, then before's afters, before's before's afters, etc.
     
     - Parameter name: name of node to find
     - Parameter visitor: track nodes already visited to break loops
     */
    func findLeft(_ name: String!, _ visitor: Visitor) -> ParNode! {

        // haven't been here before, so check it out
        if visitor.newVisit(id) {
            
            // name refers to a left-node, residing here
            if [.def,.and,.or].contains(parOp),
                pattern.count > 0,
                pattern == name,
                suffixs.count > 0 {
                
                return self
            }
            // check for siblings which haven't been visited
            for suf in suffixs {
                if let node = suf.next.findLeft(name, visitor) {
                    return node
                }
            }
            // check for aunts/uncles which haven't been visited
            for pre in prefixs {
                if let node = pre.prev.findLeft(name, visitor) {
                    return node
                }
            }
        }
        return nil
    }
    
    /**
     ParNode may refer to more complete definition, elsewhere.
     So, copy the more complete definition's edges
     
     - Parameter visitor: track nodes already visited to break loops
     */
    internal func connectReferences(_ visitor: Visitor) {
        
        /// deja vu? if already been here, then skip
        if !visitor.newVisit(id) { return }
        
        /** name has no suffixes, so real definition must reside somewhere else */
        func nameRefersToDefinitionElsewhere() -> Bool {
            if  [.def,.and,.or].contains(parOp), // is not a leaf
                pattern.count > 0, // is an explicitly declared node
                suffixs.count == 0    // has no suffixes, so elsewhere
            {
                return true
            }
        return false
        }
        
        /** search for named node and subsitude its edges */
        func findAndSubstituteEdges() {
            
            // new vistor for search
            let findVisitor = Visitor(id)

            for pre in prefixs {
                // found a node
                if let node = pre.prev.findLeft(pattern, findVisitor) {
                    if node.isName, !(node.reps == pre.next.reps) {
                        pre.next.graft(node)
                        return
                    }
                    pre.next = node
                    return
                }
            }
            print("*** could not find reference: \"\(pattern)\".\(id)")
        }
        
        // main body
        
        if nameRefersToDefinitionElsewhere() {
            findAndSubstituteEdges()
        }
        for suf in suffixs {
            suf.next.connectReferences(visitor)
        }
    }
    
    /**
     Reduce nested Suffixs of same type
     
            a (b | (c | d) )   ⟹  a (b | c | d)
            a (b | (c | d)?)?  ⟹  a (b | c | d)?
            a (b | (c | d)*)*  ⟹  a (b | c | d)*
            a (b | (c | d)*)   ⟹  no change
            a (b | (c | d)*)?  ⟹  no change
     
     - Parameter visitor: track nodes already visited to break loops
     */
    internal func distillSuffixs(_ visitor: Visitor) {
        
        /**
        nested suffix is extension of self

            (a | ( b | c))   ⟹  true
            (a | ( b | c)?)  ⟹  false
         */
        func isSelfRecursive(_ next:ParNode!) -> Bool {
            
            if next.parOp == parOp &&
                next.reps.repMax == reps.repMax &&
                next.reps.repMin == reps.repMin &&
                next.prefixs.count == 1 {
                return true
            }
            else {
                return false
            }
        }
        /**
         promote nested suffix

         (a | ( b | c))  ⟹  (a | b | c)
         */
        func distill() {
            
            var newSuffixs = [ParEdge]()
            
            for suf in suffixs {
                
                if let next = suf.next,
                    isSelfRecursive(next) {
                    
                    next.distillSuffixs(visitor)
                    
                    for suf2 in next.suffixs {
                        suf2.prev = self
                        newSuffixs.append(suf2)
                    }
                }
                else {
                    newSuffixs.append(suf)
                }
            }
            suffixs = newSuffixs
        }
        
        /// deja vu? if already been here, then skip
        if !visitor.newVisit(id) { return }
  
        if [.or].contains(parOp),
            suffixs.count > 0 {
            
            for suf in suffixs {
                if isSelfRecursive(suf.next) {
                    distill()
                    break
                }
            }
        }
        for suf in suffixs {
            suf.next.distillSuffixs(visitor)
        }
    }
    
}

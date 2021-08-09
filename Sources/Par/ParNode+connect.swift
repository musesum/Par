//  ParNode+connect.swift
//
//  Created by warren on 7/7/17.
//  Copyright © 2017 DeepMuse
//  License: Apache 2.0 - see License file

public extension ParNode {
    
    /**
     Search self, then before's afters, before's before's afters, etc.
     
     - Parameters:
        - name: name of node to find
        - visitor: track nodes already visited to break loops
     */
    func findLeft(_ name: String, _ visitor: Visitor) -> ParNode? {

        // haven't been here before, so check it out
        if visitor.newVisit(id) {
            
            // name refers to a left-node, residing here
            if [.def,.and,.or].contains(parOp),
                pattern.count > 0,
                pattern == name,
                edgeNexts.count > 0 {
                
                return self
            }
            // check for siblings which haven't been visited
            for edgeNext in edgeNexts {
                if let node = edgeNext.nodeNext?.findLeft(name, visitor) {
                    return node
                }
            }
            // check for aunts/uncles which haven't been visited
            for edgePrev in edgePrevs {
                if let node = edgePrev.nodePrev?.findLeft(name, visitor) {
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
                edgeNexts.count == 0    // has no suffixes, so elsewhere
            {
                return true
            }
        return false
        }
        
        /** search for named node and subsitude its edges */
        func findAndSubstituteEdges() {
            
            // new vistor for search
            let findVisitor = Visitor(id)

            for edgePrev in edgePrevs {
                // found a node
                if let node = edgePrev.nodePrev?.findLeft(pattern, findVisitor) {
                    if node.isName,
                       let prevNext = edgePrev.nodeNext,
                       !(node.reps == prevNext.reps) {

                        prevNext.graft(node)
                        return
                    }
                    edgePrev.nodeNext = node
                    return
                }
            }
            print("🚫 could not find reference: \"\(pattern)\".\(id)")
        }
        
        // main body
        
        if nameRefersToDefinitionElsewhere() {
            findAndSubstituteEdges()
        }
        for edgeNext in edgeNexts {
            edgeNext.nodeNext?.connectReferences(visitor)
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
        func isSelfRecursive(_ next: ParNode) -> Bool {
            
            if next.parOp == parOp &&
                next.reps.repMax == reps.repMax &&
                next.reps.repMin == reps.repMin &&
                next.edgePrevs.count == 1 {
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
            
            for edgeNext in edgeNexts {
                
                if let nodeNext = edgeNext.nodeNext,
                    isSelfRecursive(nodeNext) {
                    
                    nodeNext.distillSuffixs(visitor)
                    
                    for edgeNext2 in nodeNext.edgeNexts {
                        edgeNext2.nodePrev = self
                        newSuffixs.append(edgeNext2)
                    }
                }
                else {
                    newSuffixs.append(edgeNext)
                }
            }
            edgeNexts = newSuffixs
        }
        
        /// deja vu? if already been here, then skip
        if !visitor.newVisit(id) { return }
  
        if [.or].contains(parOp),
            edgeNexts.count > 0 {
            
            for edgeNext in edgeNexts {
                if let nodeNext = edgeNext.nodeNext,
                   isSelfRecursive(nodeNext) {
                    distill()
                    break
                }
            }
        }
        for edgeNext in edgeNexts {
            edgeNext.nodeNext?.distillSuffixs(visitor)
        }
    }
    
}

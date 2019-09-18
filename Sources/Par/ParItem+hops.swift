//
//  ParItem+hops.swift
//  
//  Created by warren on 9/13/19.
//  License: Apache 2.0 - see License file

import Foundation

extension ParItem {

    public func totalHops() -> Int {

        let hasValue = value != nil && value! != ""
        var totalHops = hasValue ? hops : 0
        for nextPar in nextPars {
            totalHops += nextPar.totalHops()
        }
        return totalHops
    }

    public func foundString(withHops:Bool = true) -> String {

        let hasValue = value != nil && value! != ""
        var found = hasValue ? value! : ""

        if withHops, hasValue {
            found += ":\(hops)"
        }
        for nextPar in nextPars {
            found += nextPar.foundString()
        }
        if found != "", found.first != " " {
            found = " " + found
        }
        return found
    }
}

//  MuseNLP.swift
//  ParGraph
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.

import Foundation
import Par

/// This is a toy natural langauge parsing example
///
/// Some unique features:
///
/// - flexible position of keywords`, with `hops` showing distance from ideal
/// - optional shortTermMemory in seconds of retaining previous keywords
/// - attaches script's eventList() to swift API func eventListChecker(...),
///     which is useful for connecting an external databases to the parser
///
public class MuseNLP {

    public static var shared = MuseNLP()
    public var root: ParNode?
    let found = MuseFound()
    let parWords = ParWords("") // search for nearest match on tokenized words in parallel

    public init() {
        root = Par.shared.parse(script: MusePar)
    }

    /// Parse string and find match to muse graph
    /// - parameter str: lowercase string
    /// - returns: -1: not found. 0...n: number of hops from ideal graph
    
    public func findMatch(_ str: String) -> MuseFound? {

        if root == nil { return nil }
        let timeNow = Date().timeIntervalSince1970

        parWords.update(str, timeNow) // filter words out after shortTermMemory span
        found.str = str
        found.parItem = root?.findMatch(parWords, 0).parLast ?? nil
        found.hops = found.parItem?.totalHops() ?? -1
        return found
    }

    func parseParItem(_ parItem: ParItem, _ model: MuseModel, _ visitor: Visitor) {

        if let node = parItem.node, !visitor.newVisit(node.id) { return }

        if parItem.nextPars.count > 0 {
            for nextPar in parItem.nextPars {
                parseParItem(nextPar, model, visitor)
            }
        }
        else if parItem.value != nil {
            switch parItem.value {
            case "show": model.show = true
            case "hide": model.show = false
            default: break
            }
        }
    }

}


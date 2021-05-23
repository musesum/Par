//  TestNLP.swift
//  ParGraph
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 DeepMuse All rights reserved.

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
public class TestNLP {

    public static var shared = TestNLP()
    public var root: ParNode?
    let parWords = ParWords("") // search for nearest match on tokenized words in parallel

    public init() {
        root = Par.shared.parse(script: TestPar)
    }

    /// Parse string and find match to test graph
    /// - parameter str: lowercase string
    /// - returns: -1: not found. 0...n: number of hops from ideal graph
    public func findMatch(_ str: String) -> TestFound? {

        let timeNow = Date().timeIntervalSince1970

        parWords.update(str, timeNow) // filter words out after shortTermMemory span
        if  let parItem = root?.findMatch(parWords, 0).parLast {
            let hops = parItem.totalHops()
            return TestFound(str, parItem, hops)
        }
        return TestFound("", nil, -1)
    }
    func parseParItem(_ parItem: ParItem, _ model: TestModel, _ visitor: Visitor) {

        if !visitor.newVisit(parItem.node.id) { return }

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


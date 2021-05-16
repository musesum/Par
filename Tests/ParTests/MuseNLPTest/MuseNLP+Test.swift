//  Muse+Test.swift
//  Created by warren on 9/3/17.
//  Copyright © 2017 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation
import Par

extension MuseNLP {

    func testAndPrintMuseGraph() -> Int {

        var err = 0
        if let root = root {
            let script = root.makeScript() //remake script from parse graph
            err = ParStr.testCompare(script, script, echo: true) // should match
            print("-------------------------------")
            print(script)
            print(" ⟹ What follows is a dump of the graph of the muse script,\n" +
            "which is sometimes valueable for tracking down the parse details.\n" +
            "-----------------------------------------------------------------\n" +
            "⦙  Predecessor                  Node                    Successors ")
            root.printGraph(Visitor(0)) // print the parse graph
            print("-----------------------------------------------------------------")
        }
        else {
            err = 1
        }
        return err
    }

    func testScript() -> Int {

        func testPhrase(_ request: String) -> Int {

            print("\"\(request)\" ⟹ ", terminator:"")

            parWords.update(request, Date().timeIntervalSince1970)

            if let parItem = root?.findMatch(parWords).parLast {

                let foundString = parItem.foundString(withHops: true)
                let totalHops = parItem.totalHops()
                print("\(foundString) ⟹ hops:\(totalHops) ✔︎")
                return 0
            }
            else  {
                print("🚫 failed")
                return 1
            }
        }

        func eventListChecker(_ str: Substring) -> String? {
            let ret =  str.hasPrefix("yo") ? "yo" : nil
            return ret
        }

        // ────────────── begin ──────────────

        var err = testAndPrintMuseGraph()
        ParStr.tracing = false

        ParRecents.shortTermMemory = 0 // 0 seconds of short term memory

        err += testPhrase("muse show all alarms")
        err += testPhrase("muse show alarms")
        err += testPhrase("muse please show alarms")

        print("\n-------------------------------")
        print("⟹ before attaching eventListChecker() - `yo` is unknown")
        let _ = testPhrase("muse show event yo") // should produce an error

        print("\n⟹ runtime is attaching eventListChecker() callback to eventList()")
        root?.setMatch("muse show event eventList()", eventListChecker)

        print("\n⟹ now `yo` is now matched during runtime")
        err += testPhrase("muse show event yo") // should now be ok as yo is n
        err += testPhrase("muse event show yo")
        err += testPhrase("yo muse show event")
        err += testPhrase("muse show yo event")
        err += testPhrase("muse event yo show")

        print("\n-------------------------------")
        print("⟹ with no shortTermMemory, partial matches fail")
        ParRecents.shortTermMemory = 0 // 8 seconds of short term memory
        let _ = testPhrase("muse show event yo")
        let _ = testPhrase("muse hide yo")    // should hide yo event
        let _ = testPhrase("muse hide event")
        let _ = testPhrase("hide event")
        let _ = testPhrase("hide")

        print("\n⟹ after setting ParRecents.shortTermMemory = 8 seconds")
        ParRecents.shortTermMemory = 8 // 8 seconds of short term memory
        err += testPhrase("muse show event yo")
        err += testPhrase("muse hide yo")    // should hide yo event
        err += testPhrase("muse hide event")
        err += testPhrase("hide event")
        err += testPhrase("hide")

        return err
    }
}

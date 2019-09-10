import Foundation
import XCTest

@testable import Par

// test
func matches(_ str:Substring) -> String! {
    return str.hasPrefix("yo") ? "yo" : nil
}

final class ParTests: XCTestCase {

    var countTotal = 0
    var countError = 0

    /// test ParGraph for parsing different languages
    ///
    /// - Test1     - rudimentary cardinality within sub-namespace
    /// - Tr3       - complete definition of Tr3 language
    /// - MuseNow   - a simple natural language command recognizer

    public func TestParGraph(_ filename: String) {

        Par.trace = false // for debugging error
        Par.trace2 = false

        let _ /*border*/ = "┄".padding(toLength: 40, withPad: "┄", startingAt: 0)

        if let graph = Par.shared.parse(filename, "par") {

            //graph.printGraph(Visitor(0));            print(divider(15))
            let script = graph.makeScript(level:0);  print(divider(15))
            //print(script)

            if let error = Par.shared.parStr.compare(script) {
                print ("\(#function) \(filename): 🚫 mismatch \n\(error)")
                countError += 1
            }
            else {
                print ("\(#function) \(filename): ✓")
            }
        }
        else {
            countError += 1
        }
        print(divider(30))
    }

    func testBasics() {
        countError = 0
        TestParGraph("Test1")
        TestParGraph("Test2a")
        TestParGraph("Test2b")
        TestParGraph("Test3")
        
        TestParGraph("Tr3")
        TestParGraph("MuseNow")
        TestParGraph("Muse")
        XCTAssertEqual(countError,0)

    }


    static var allTests = [
        ("testBasics", testBasics),
    ]
}

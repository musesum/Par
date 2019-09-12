import Foundation
import XCTest

@testable import Par

final class ParTests: XCTestCase {

    var errorCount = 0

    /// compare expected with actual result and print error strings
    /// with 🚫 marker at beginning of non-matching section
    ///
    /// - parameter script: expected output
    /// - parameter script: actual output
    ///
    func testCompare(_ expected:String, _ actual:String, echo:Bool = false) {
        if echo {
            print ("⟹ " + expected, terminator:"")
        }
        // for non-match, compare will insert a 🚫 into expectedErr and actualErr
        if let (expectedErr,actualErr) = ParStr.compare(expected, actual) {
            print (" 🚫 mismatch")
            print ("⟹ " + expectedErr)
            print ("⟹ " + actualErr + "\n")
            errorCount += 1
        }
        else {
            print ("⟹ " + expected + " ✓\n")
        }
    }


      public func test(_ script: (String,String)) {

        Par.trace = false // for debugging error
        Par.trace2 = false
        ParStr.tracing = false

        // script contains original to parse and expected result of parse
        var (original,expected) = script
        if expected == "" { expected = original }

        if let graph = Par.shared.parse(script:original) {

           // graph.printGraph(Visitor(0))

            let actual = graph.makeScript(level:0)
            testCompare(expected, actual)
        }
        else {
            print(" 🚫 failed parse")
            errorCount += 1
        }
        print(divider(30))
    }

    /// test basic parsing by comparing with generated output
    func testBasics() {
        errorCount = 0

        // test(Bug1Par) 🚫bug! single rvalue `ask`
        // test(Bug2Par) 🚫bug! double ((...) ...)

        test(Namespace1Par)
        test(Namespace2Par)
        test(CardinalPar)
        test(MultiGroupPar)
        test(MusePar)
        test(RoutinePar)
        test(MediaPar)

        XCTAssertEqual(errorCount,0)
    }
    /// test natural language processing with shifting order
    func testNLP() {

        let muse = Muse()
        errorCount = muse.testScript()
    
        XCTAssertEqual(errorCount,0)
    }

    static var allTests = [
        ("testBasics", testBasics),
        ("testNLP", testNLP),
    ]
}

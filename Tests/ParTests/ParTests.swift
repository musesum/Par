import Foundation
import XCTest

@testable import Par


/// parse script into graph and then generate output script from graph.
/// If the actual output is different from the expected output
/// then generate an error meassage with a 🚫 at where they differ.
public func testParse(_ original_: String, _ expected_: String = "") -> Int {

    Par.trace = false // for debugging errors
    Par.trace2 = false
    ParStr.tracing = false

    // script contains original to parse and expected result of parse
    // sometimes the expected is same as original
    // sometimes the output adds additional parents
    let original = original_
    let expected = expected_ == "" ? original : expected_

    if let graph = Par.shared.parse(script: original) {

        // graph.printGraph(Visitor(0))

        let actual = graph.makeScript(level: 0)
        return ParStr.testCompare(expected, actual)
    }
    else {
        print(" 🚫 failed parse")
        return 1 // error
    }
}

final class ParTests: XCTestCase {


    /// test basic parsing by comparing with generated output
    func testBasics() {
        print("\n------------------------------------")
        var err = 0 // error count
        //let _ = testParse(Bug1Par) //🚫bug! single rvalue `ask`
        //let _ = testParse(Bug2Par) //🚫bug! double ((…) …)
        
        err += testParse(Namespace1Par)
        err += testParse(Namespace2Par)
        err += testParse(CardinalPar)
        err += testParse(MultiGroupPar)
        err += testParse(TestPar)
        err += testParse(RoutinePar, RoutineParOut)
        err += testParse(MediaParAndOr, MediaParAndOr)
        err += testParse(MediaPar, MediaParOut)

        XCTAssertEqual(err, 0)
    }

    /// test natural language processing with shifting order
    func testNLP() {
        print("\n------------------------------------")
        let err = TestNLP().testScript()
        XCTAssertEqual(err, 0)
    }

    /// Test Tr3 graph parse
    func testTr3() {
        print("\n------------------------------------")
        print(" ⟹ What follows a parse of the Tr3 \n" +
            "Par is vertically integrated with Tr3 so,\n" +
            "Par should never break Tr3 for major versions.\n")
        let err = testParse(Tr3Par)
        print("------------------------------------")
        XCTAssertEqual(err, 0)
    }

    static var allTests = [
        ("testBasics", testBasics),
        ("testNLP", testNLP),
        ("testTr3", testTr3),
    ]
}

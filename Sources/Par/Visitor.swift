//  Created by warren on 7/7/17.


import Foundation

public struct VisitFrom: OptionSet {

    public let rawValue: Int

    public static let model   = VisitFrom(rawValue: 1 << 0) // 1
    public static let canvas  = VisitFrom(rawValue: 1 << 1) // 2
    public static let user    = VisitFrom(rawValue: 1 << 2) // 4
    public static let remote  = VisitFrom(rawValue: 1 << 3) // 8
    public static let midi    = VisitFrom(rawValue: 1 << 4) // 16
    public static let animate = VisitFrom(rawValue: 1 << 5) // 32
    public init(rawValue: Int = 0) { self.rawValue = rawValue }

    static public var debugDescriptions: [(Self, String)] = [
        (.model  , "model"  ),
        (.canvas , "canvas" ),
        (.user   , "user"   ),
        (.remote , "remote" ),
        (.remote , "midi"   ),
        (.animate, "animate"),
    ]
    static public var logDescriptions: [(Self, String)] = [
        (.model  , "􀬎"),
        (.canvas , "􀏅"),
        (.user   , "􀉩"),
        (.remote , "􀤆"),
        (.midi   , "􀑪"),
        (.animate, "􀎶"),
    ]

    public var description: String {
        let result: [String] = Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
        let joined = result.joined(separator: ", ")
        return "[\(joined)]"
    }
    public var log: String {
        let result: [String] = Self.logDescriptions.filter { contains($0.0) }.map { $0.1 }
        let joined = result.joined(separator: "")
       return joined
    }
    public var remote  : Bool { self.contains(.remote ) }
    public var user    : Bool { self.contains(.user   ) }
    public var model   : Bool { self.contains(.model  ) }
    public var midi    : Bool { self.contains(.midi   ) }
    public var animate : Bool { self.contains(.animate) }
    public var canvas  : Bool { self.contains(.animate) }
}

/// Visit a node only once. Collect and compare with a set of nodes already visited.
public class Visitor {

    static var Id = 0  // unique identifier for each node
    public static func nextId() -> Int { Id += 1; return Id }

    private var lock = NSLock()
    private var visited = Set<Int>()

    public var from: VisitFrom

    public init (_ id: Int, from: VisitFrom = .model ) {
        self.from = from
        nowHere(id)
    }
    public init (_ from: VisitFrom) {
        self.from = from
    }

    public func nowHere(_ id: Int) {
        lock.lock()
        visited.insert(id)
        lock.unlock()
    }
    public func wasHere(_ id: Int) -> Bool {
        lock.lock()
        let contains = visited.contains(id)
        lock.unlock()
        return contains
    }
    public func isLocal() -> Bool {
        return !from.contains(.remote)
    }

    public func newVisit(_ id: Int) -> Bool {
        if wasHere(id) {
            return false
        } else {
            nowHere(id)
            return true
        }
    }
    public func via(_ via: VisitFrom) -> Visitor {
        self.from.insert(via)
        return self
    }
    public var log: String {
        let visits = visited.map { String($0)}.joined(separator: ",")
        return "\(from.log):(\(visits))"
    }
}


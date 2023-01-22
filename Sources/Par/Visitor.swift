//  Created by warren on 7/7/17.


import Foundation

public struct VisitFrom: OptionSet {

    public let rawValue: Int

    public static let model   = VisitFrom(rawValue: 1 << 0) ///  1
    public static let user    = VisitFrom(rawValue: 1 << 1) ///  2
    public static let remote  = VisitFrom(rawValue: 1 << 2) ///  4
    public init(rawValue: Int = 0) { self.rawValue = rawValue }

    static public var debugDescriptions: [(Self, String)] = [
        (.model  , "model"  ),
        (.user  , "user"  ),
        (.remote , "remote" ),
    ]

    public var description: String {
        let result: [String] = Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
        let joined = result.joined(separator: ", ")
        return "\(joined)"
    }
    public var remote: Bool { self.contains(.remote) }
    public var user: Bool { self.contains(.user) }
    public var model: Bool { self.contains(.model) }
}

/// Visit a node only once. Collect and compare with a set of nodes already visited.
public class Visitor {

    static var Id = 0  // unique identifier for each node
    public static func nextId() -> Int { Id += 1; return Id }

    private var lock = NSLock()
    private var visited = Set<Int>()

    public var from: VisitFrom

    public init (_ id: Int = 0) {
        from = .model
        nowHere(id)
    }
    public init (_ from: VisitFrom) {
        self.from = from
    }
    public var fromRemote: Bool { from.contains(.remote) }
    public var fromUser: Bool { from.contains(.user) }
    public var fromModel: Bool { from.contains(.model) }

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
}


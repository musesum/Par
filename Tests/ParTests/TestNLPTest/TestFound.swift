//  TestFound.swift
//  Created by warren on 9/5/17.
//  Copyright © 2017 DeepMuse All rights reserved.

import Foundation
import Par

public enum ActionType: Int { case
    unknown,
    calendars,
    events,
    memos,
    marks,
    alarm
}

public class TestFound {

    public var str = ""
    public var parItem: ParItem?
    public var hops = -1

    public init (_ str: String, _ nodeAny: ParItem?, _ hops: Int) {
    
        self.str = str
        self.parItem = nodeAny
        self.hops = hops
    }

    public init (_ from: TestFound) {
        self.str     = from.str
        self.parItem = from.parItem
        self.hops    = from.hops
    }
}

class TestModel {

    // var action: DoAction = .unknown
    var show = true
    var item: ActionType = .unknown
}

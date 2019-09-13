//  MuseFound.swift
//  Created by warren on 9/5/17.
//  Copyright © 2017 Muse Dot Company All rights reserved.

import Foundation
import Par

public enum ActionType : Int { case
    unknown,
    calendars,
    events,
    memos,
    marks,
    alarm
}

public class MuseFound {

    public var str    = ""
    public var parItem : ParItem?
    public var hops   = -1

    public convenience init (_ str_:String,_ nodeAny_: ParItem!,_ hops_:Int) {
    
        self.init()
        str    = str_
        parItem = nodeAny_
        hops   = hops_
    }

    public convenience init (_ from: MuseFound) {
        self.init()
        str    = from.str
        parItem = from.parItem
        hops   = from.hops
    }
}

class MuseModel {

    // var action: DoAction = .unknown
    var show = true
    var item: ActionType = .unknown
}

//
//  ParMatchNow.swift
//  
//
//  Created by warren on 9/11/19.
//

import Foundation


public class ParMatchNow: ParMatching {

    public static var shortTermMemory = TimeInterval(0) // seconds

    func forget(_ timeNow: TimeInterval) {
        if parAnys.count == 0 {
            return
        }
        if timeNow == 0 {
            return parAnys.removeAll()
        }
        let cutoffTime = timeNow - ParMatchNow.shortTermMemory
        var removeCount = 0
        for parAny in parAnys {
            if parAny.time < cutoffTime {
                removeCount += 1
            }
            else {
                break
            }
        }
        if removeCount > 0 {
            parAnys.removeFirst(removeCount)
        }
    }

 }

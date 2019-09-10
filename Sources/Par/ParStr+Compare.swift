//
//  ParStr+Compare.swift
//  Par
//
//  Created by warren on 8/7/17.
//  Copyright © 2017 Muse Dot Company
//  License: Apache 2.0 - see License file


import Foundation

public extension ParStr {

    static func compare(_ str1:String,_ str2:String) -> (String,String)? {

        var sub1 = Substring(str1)
        var sub2 = Substring(str2)
        var i1 = sub1.startIndex
        var i2 = sub2.startIndex

        // advance i1,i2 indexes past whitespace and/or comments
        func eatWhitespace() {

            var hasComment = false

            while i1 < sub1.endIndex && "\n\t ".contains(sub1[i1]) { i1 = sub1.index(after: i1) }
            while i2 < sub2.endIndex && "\n\t ".contains(sub2[i2]) { i2 = sub2.index(after: i2) }

            // remove comments
            if sub1[i1 ..< sub1.endIndex].hasPrefix("//") {
                while i1 < sub1.endIndex && "\n" != str1[i1] { i1 = sub1.index(after: i1) }
                hasComment = true
            }
            if sub2[i2 ..< sub2.endIndex].hasPrefix("//") {
                while i2 < sub2.endIndex && "\n" != str2[i2] { i2 = sub2.index(after: i2) }
                hasComment = true
            }
            if hasComment {
                // remove trailing whitespace and/or multi-line comments
                eatWhitespace()
            }
        }

        func makeError() -> (String,String)? {

            let error1 = str1[..<i1] + "🚫" + str1[i1..<str1.endIndex]
            let error2 = str2[..<i2] + "🚫" + str2[i2..<str2.endIndex]
            return (String(error1), String(error2))
        }

        // -------------- body --------------

        eatWhitespace() // start by removing leading comments

        while i1 < str1.endIndex && i2 < sub2.endIndex {

            if sub1[i1] != sub2[i2] { return makeError() }

            i1 = sub1.index(after: i1)
            i2 = sub2.index(after: i2)

            eatWhitespace()
        }

        // nothing remaining for either string?

        if  i1 == sub1.endIndex,
            i2 == sub2.endIndex {
            return nil
        }
        else {
            return makeError()
        }
    }

    func compare(_ str2: String) -> String? {
        if let (_,error) = ParStr.compare(str,str2) {
            return error
        }
        return nil
    }

}


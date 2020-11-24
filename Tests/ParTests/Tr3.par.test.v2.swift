//
//  Tr3.par.swift
//  Language definition for Tr3 graph.
//  A pretty version of this with syntax highlight
//  Created by warren on 9/13/19.
//

import Foundation

// This is the language definition for Tr3 graph

public let Tr3Par =
#"""
tr3 ~ left right* {

    left ~ comment* pathName proto?
    proto ~ "*" pathName
    pathName ~ path | name

    right ~ value | child | array | edges | embed | comment
    child ~ "{" tr3+ "}" many?
    many ~ "." child

    value ~ scalar | tuple | quote
    scalar ~ "(" scalar1 ")"
    scalar1 ~ thru | modu | incr | decr | data | dflt {
        thru ~ min ":" max eqDflt?
        modu ~ "%" max eqDflt?
        incr ~ "++"
        decr ~ "--"
        data ~ "*"
        min ~ num
        max ~ num
        dflt ~ num
        eqDflt ~ "=" dflt
    }
    tuple ~ "(" tupVal ")" {
        names ~ name{2,}
        nums ~ num{2,}
        nameNum ~ name num
        nameNums ~ nameNum nameNum*
        tupVal ~ nameNums | names | nums
    }
    edges ~ edgeOp edgeItem comment* {

        edgeOp ~ '^([<][<sx?!\╌>]+|[sx?!>]+[>])'
        edgeItem ~ edgeValTern comment*
        edgeVal ~ pathName value?
        edgeValTern ~ edgeVal | ternary
        pathNameVal ~ pathName | value
        ternPathNameVal ~ ternary | pathNameVal

        ternary ~ "(" tern ")" {
            tern ~ ternIf ternThen ternElse? ternRadio?
            ternIf ~ pathName ternCompare?
            ternThen ~ "?" ternPathNameVal
            ternElse ~ ":" ternPathNameVal
            ternRadio ~ "|" ternary
            ternCompare ~ compare pathNameVal
        }
    }
    path ~ '^((([A-Za-z_][A-Za-z0-9_]*)*([.˚*])+([A-Za-z_][A-Za-z0-9_.˚*]*)*)+)'
    name ~ '^([A-Za-z_][A-Za-z0-9_]*)'
    quote ~ '^\"([^\"]*)\"'
    num ~ '^([+-]*([0-9]+[.][0-9]+|[.][0-9]+|[0-9]+[.](?![.])|[0-9]+)([e][+-][0-9]+)?)'
    array ~ '^\:?\[[ ]*([0-9]+)[ ]*\]'
    comment ~ '^[/][/][ ]*((.*?)[\r\n]+|^[ \r\n\t]+)'
    compare ~ '^[<>!=][=]?'
    embed ~ '^[{][{](?s)(.*?)[}][}]'
}
"""#

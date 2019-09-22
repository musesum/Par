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
tr3 : left right* {

    left : comment* (path | name | quote)

    right : (tr3Val | child | many | proto | array | edges | embed | comment)+

    child  :     "{" tr3+ "}"
    many   : ":" "{" tr3+ "}"
    proto  : ":" (path | name)
    tr3Val : ":" value

    value  : (scalar | tuple | quote)

    scalar : ("(" scalar1 ")" | scalar1)
    scalar1 : (thru | upto | modu | incr | decr | data | dflt) {

        thru : min "..." max ("=" dflt)?
        upto : min "..<" max ("=" dflt)?
        modu : "%" max ("=" dflt)?
        incr : "++"
        decr : "--"
        data : "*"
        min  : num
        max  : num
        dflt : num
    }
    tuple : "(" (nameNums | names | nums) ")" tupVal? {
        names    : name{2,}
        nums     : num{2,}
        nameNums : (name ":" num){1,}
        tupVal   : ":" (scalar1 | tuple)
    }
    edges : edgeOp (edgePar | edgeItem) comment* {

        edgeOp   : '^([<][-=?!\╌>]+|[-=?!\˚]+[>])'
        edgePar  : "(" edgeItem+ ")" edges?
        edgeItem : (edgeVal | ternary) comment*

        edgeVal  :  (path | name) (edges+ | ":" value)?

        ternary  : ("(" tern ")" | tern) {

            tern        : ternIf ternThen ternElse? ternRadio?
            ternIf      : (path | name) ternCompare?
            ternThen    : "?" (ternary | path | name | value)
            ternElse    : ":" (ternary | path | name | value)
            ternRadio   : "|" ternary
            ternCompare : compare (path | name | value)
        }
    }
    path    : '^((([A-Za-z_][A-Za-z0-9_]*)*([.˚*])+([A-Za-z_][A-Za-z0-9_.˚*]*)*)+)'
    name    : '^([A-Za-z_][A-Za-z0-9_]*)'
    quote   : '^\"([^\"]*)\"'
    num     : '^([+-]*([0-9]+[.][0-9]+|[.][0-9]+|[0-9]+[.](?![.])|[0-9]+))'
    array   : '^\:?\[[ ]*([0-9]+)[ ]*\]'
    comment : '^[/][/][ ]*((.*?)[\r\n]+|^[ \r\n\t]+)'
    compare : '^[<>!=][=]?'
    embed   : '^[{][{](?s)(.*?)[}][}]'
}
"""#
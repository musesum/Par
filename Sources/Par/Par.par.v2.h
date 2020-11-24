//  Par.par.h
//
//  Created by warren on 6/22/17.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

// this is not parsed, describes Par.par in the Par.swift file
par ~ name "~" right+ sub? end_ {
    name ~ '^[A-Za-z_]\w*'
    right ~ or_ | and_ | paren {
        or_ ~ and_ orAnd+ {
            orAnd ~ "|" and_
        }
        and_ ~ leaf reps? {
            leaf ~ match | path | quote | regex {
            match ~ '^([A-Za-z_]\w*)\(\)'
            path ~ '^[A-Za-z_][A-Za-z0-9_.]*'
            quote ~ '^\"([^\"]*)\"' // skip  \"
            regex ~ '^([i_]*\'[^\']+)'
            }
        }
        parens ~ "(" right ")" reps
    }
    sub ~ "{" end_ par "}" end_?
    end_ ~ '[ \\n\\t,]*'
    reps ~ '^([\~]?([\?\+\*]|\{],]?\d+[,]?\d*\})[\~]?)'
}


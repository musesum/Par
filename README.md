# Par

Par is a simple parse graph for DSLs and NLP

- DSLs (domain specific languages), like Tr3
- NLP (chat bots) with flexible word position and closures

with the following features
- modified Backus Naur Form (BNF) to define a named parse tree
- optional namespace { } brackets to restrict a sub-parse
- allow runtime recompile of syntax for NLP / chat bots
- somewhat idiomatic to Swift syntax

graph based intermediate representation
- breaks graph loops when resolving namespace
- allow future integration with data flow graphs
- allow future bottom-up restructuring of parse tree

allow runtime closures to extend lexicon
- search current Calendar, flight schedules, etc
- integrate procedural code

allow imprecise searching
- allow different word orders
- based on minimal hops (hamming distance) from graph

allow short term memory (STM)
- keep keywords from previous queries to complete imprecise matching
- may be adjusted to 0 seconds for computer language parsing

## Modified BNF

Here is the ubiquitous Hello World
```swift
greeting ~ "hello" "world"
```

namespace `{ }` brackets limits the symbols `hello` and `world` to `greeting`.
```swift
greeting ~ hello world {
     hello ~ "hello"
     world ~ "world"
}
```
double quotes match strings, while
single quotes match regular expressions:
```swift
year ~ '(19|20)[0-9][0-9]'
digits ~ '[0-9]{1, 5}'
```

Alternation and repetitions are supported
```c
greetings ~ cough{, 3} (hello | yo+) (big | beautiful)* world?
```

#### Closures for Runtime APIs

in the file test.par is the line
```swift
events ~ 'event' eventList()
```

whereupon the source in TestNLP+test.swift, attaches to eventList()
```swift
root?.setMatch("test show event eventList()", eventListChecker)
```
and attaches a simple callback to extend the lexicon:
```swift
func eventListChecker(_ str: Substring) -> String? {
     let ret =  str.hasPrefix("yo") ? "yo" : nil
     return ret
}
```
which in the real world could attach to a dynamic calendar, or any other 3rd party API.

Here is the output from ParTests/TestNLP+Test.swift :
```swift
⟹ before attaching eventListChecker() - `yo` is unknown
"test show event yo" ⟹ 🚫 failed

⟹ runtime is attaching eventListChecker() callback to eventList()
"test show event eventList()"  ⟹  eventList.924 = (Function)

⟹ now `yo` is now matched during runtime
"test show event yo" ⟹  test: 0 show: 0 event: 0 yo: 0 ⟹ hops: 0 ✔︎
```

#### Imprecise matching

For NLP, word order may not perfectly match parse tree order. So, report number of hops (or Hamming Distance) from ideal.

Output from ParTests/TestNLP+Test.swift:
```swift
"test event show yo" ⟹  test: 0 show: 1 event: 0 yo: 1 ⟹ hops: 2 ✔︎
"yo test show event" ⟹  test: 1 show: 1 event: 2 yo: 2 ⟹ hops: 6 ✔︎
"test show yo event" ⟹  test: 0 show: 0 event: 1 yo: 0 ⟹ hops: 1 ✔︎
"test event yo show" ⟹  test: 0 show: 2 event: 0 yo: 0 ⟹ hops: 2 ✔︎
```

#### Short term memory

For NLP, set a time where words from a previous query continue onto the next query.

Output from ParTests/TestNLP+Test.swift:
```swift
⟹ with no shortTermMemory, partial matches fail
"test show event yo" ⟹  test: 0 show: 0 event: 0 yo: 0 ⟹ hops: 0 ✔︎
"test hide yo" ⟹ 🚫 failed
"test hide event" ⟹ 🚫 failed
"hide event" ⟹ 🚫 failed
"hide" ⟹ 🚫 failed

⟹ after setting ParRecents.shortTermMemory = 8 seconds
"test show event yo" ⟹  test: 0 show: 0 event: 0 yo: 0 ⟹ hops: 0 ✔︎
"test hide yo" ⟹  test: 0 show: 10 event: 10 yo: 0 ⟹ hops: 20 ✔︎
"test hide event" ⟹  test: 0 show: 10 event: 1 yo: 9 ⟹ hops: 20 ✔︎
"hide event" ⟹  test: 10 show: 9 event: 0 yo: 8 ⟹ hops: 27 ✔︎
"hide" ⟹  test: 9 show: 8 event: 8 yo: 9 ⟹ hops: 34 ✔︎
```
#### Use Case
Here is the Par definition in the Par format:

```swift
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
```
Here is a complete Par definition for the functional data flow graph, called Tr3: 

```swift
tr3 ~ left right* {

    left ~ (path | name | quote) 

    right ~ (tr3Val | child | many | copyat | array | edges | embed | comment)+

    tr3Val ~ value
    child ~ "{" comment* tr3+ "}"
    many ~ "." "{" tr3+ "}"
    copyat ~ "@" (path | name)
    array ~ "[" thru "]"

    value ~ scalar | tuple | quote
    value1 ~ scalar1 | tuple | quote
    scalar ~ "(" scalar1 ")"
    scalar1 ~ thru | modu | incr | decr | data | dflt {
        thru ~ min ".." max eqDflt?
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
        names ~ name (","? name)+
        scalars ~ scalar1 (","? scalar1)+
        nameScalars ~ name scalar1 (","? name scalar1)*
        tupVal ~ nameScalars | names | scalars
    }
    edges ~ edgeOp (edgePar | edgeItem) comment* {

        edgeOp ~ '^([<][<⋯!@&\=\╌>]+|[⋯!@&\=\╌>]+[>])'
        edgePar ~ "(" edgeItem+ ")" edges?
        edgeItem ~ (edgeVal | ternary) comment*

        edgeVal ~ (path | name) (edges+ | value)?

        ternary ~ "(" tern ")" | tern {
            tern ~ ternIf ternThen ternElse? ternRadio?
            ternIf ~ (path | name) ternCompare?
            ternThen ~ "?" (ternary | path | name | value1)
            ternElse ~ ":" (ternary | path | name | value1)
            ternCompare ~ compare (path | name | value1)
            ternRadio ~ "|" ternary
        }
    }
    path ~ '^(([A-Za-z_][A-Za-z0-9_]*)?[.º˚*]+[A-Za-z0-9_.º˚*]*)'
    name ~ '^([A-Za-z_][A-Za-z0-9_]*)'
    quote ~ '^\"([^\"]*)\"'
    num ~ '^([+-]*([0-9]+[.][0-9]+|[.][0-9]+|[0-9]+[.](?![.])|[0-9]+)([e][+-][0-9]+)?)'
    comment ~ '^([,]+|^[/]{2,}[ ]*(.*?)[\n\r\t]+|\/[*]+.*?\*\/)'
    compare ~ '^[<>!=][=]?'
    embed ~ '^[{][{](?s)(.*?)[}][}]'
}
"""#

```
#### Future

Par is vertically integrated with Tr3 [here](https://github.com/musesum/Tr3)
- Future version Tr3 may embed Par as a node value type

Bottom up restructuring of parse from user queries
- Parse tree may be discarded in favor of a parse graph
- Graph built from user queries as prevNode & nextNode edges as n-grams
- Match queries by assembling nodes middle-out from dictionary of words and n-gram edges

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
greeting: "hello" "world"
```

namespace `{ }` brackets limits the symbols `hello` and `world` to `greeting`.
```swift
greeting : hello world {
hello : "hello"
world : "world"
}
```
double quotes match strings, while
single quotes match regular expressions:
```swift
year   : '(19|20)[0-9][0-9]'
digits : '[0-9]{1,5}'
```

Alternation and repetitions are supported
```c
greetings: cough{,3} (hello | yo+) (big | beautiful)* world?
```

#### Closures for Runtime APIs

in the file muse.par is the line
```swift
events : 'event' eventList()
```

whereupon the source in MuseNLP+test.swift, attaches to eventList()
```swift
root?.setMatch("muse show event eventList()",eventListChecker)
```
and attaches a simple callback to extend the lexicon:
```swift
func eventListChecker(_ str:Substring) -> String? {
let ret =  str.hasPrefix("yo") ? "yo" : nil
return ret
}
```
which in the real world could attach to a dynamic calendar, or any other 3rd party API.

Here is the output from ParTests/MuseNLP+Test.swift :
```swift
⟹ before attaching eventListChecker() - `yo` is unknown
"muse show event yo" ⟹ 🚫 failed

⟹ runtime is attaching eventListChecker() callback to eventList(
"muse show event eventList()"  ⟹  eventList.924 = (Function)

⟹ now `yo` is now matched during runtime
"muse show event yo" ⟹  muse:0 show:0 event:0 yo:0 ⟹ hops:0 ✔︎
```

#### Imprecise matching

For NLP, word order may not perfectly match parse tree order. So, report number of hops (or Hamming Distance) from ideal

from ParTests/MuseNLP+Test.swift:
```swift
"muse event show yo" ⟹  muse:0 show:1 event:0 yo:1 ⟹ hops:2 ✔︎
"yo muse show event" ⟹  muse:1 show:1 event:2 yo:2 ⟹ hops:6 ✔︎
"muse show yo event" ⟹  muse:0 show:0 event:1 yo:0 ⟹ hops:1 ✔︎
"muse event yo show" ⟹  muse:0 show:2 event:0 yo:0 ⟹ hops:2 ✔︎
```

#### Short term memory

For NLP, set a time where words from a previous query continue onto the next query

from ParTests/MuseNLP+Test.swift:
```swift
⟹ with no shortTermMemory, partial matches fail
"muse show event yo" ⟹  muse:0 show:0 event:0 yo:0 ⟹ hops:0 ✔︎
"muse hide yo" ⟹ 🚫 failed
"muse hide event" ⟹ 🚫 failed
"hide event" ⟹ 🚫 failed
"hide" ⟹ 🚫 failed

⟹ after setting ParRecents.shortTermMemory = 8 seconds
"muse show event yo" ⟹  muse:0 show:0 event:0 yo:0 ⟹ hops:0 ✔︎
"muse hide yo" ⟹  muse:0 show:10 event:10 yo:0 ⟹ hops:20 ✔︎
"muse hide event" ⟹  muse:0 show:10 event:1 yo:9 ⟹ hops:20 ✔︎
"hide event" ⟹  muse:10 show:9 event:0 yo:8 ⟹ hops:27 ✔︎
"hide" ⟹  muse:9 show:8 event:8 yo:9 ⟹ hops:34 ✔︎
```
#### Future

Par is vertically integrated with Tr3 [here](https://github.com/musesum/Tr3)
- Future version Tr3 may embed Par as node value type

Bottom up restructuring of parse from user queries
- Parse tree may be discarded as scaffolding for a parse graph

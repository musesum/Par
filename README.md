# Par

Par is a simple parse graph for making

    DSLs (domain specific languages), like Tr3
    NLP (chat bots) with flexible word position and closures

with the following features

    modified Backus Naur Form (BNF) to define a named parse tree
        use optional  namespace { } brackets to restrict a sub-parse
        allow runtime recompile of syntax for NLP chat bots
        idiomatic to Swift syntax

    graph based intermediate representation
        breaks graph loops when resolving namespace
        allow future integration with data flow graphs
        allow future bottom-up restructuring of parse tree

    allow runtime closures to extend lexicon
        search current Calendar, flight schedules, etc

    allow imprecise searching
        allow different word orders
            based on minimal hops (hamming distance) from graph
    allow short term memory (STM)
        keep keywords from previous queries
             to complete imprecise matching
        may be adjusted to 0 seconds for computer language parsing
    future plans
        merge with functional flow graphs, such Tr3Graph and TensorFlow
        bottom up restructuring of parse from user queries

Modified BNF

    Here is the ubiquitous Hello World

        greeting: "hello" "world"

    namespace { } brackets limits the symbols `hello` and `world` to `greeting`.

        greeting : hello world {
            hello : "hello"
            world : "world"
        }

    double quotes match strings, while
    single quotes match regular expressions:

        year : '(19|20)[0-9][0-9]'
        digits: '[0-9]{1,5}'

    Alternation and repetitions are supported

        greetings: cough{,3} (hello | yo+) (big | beautiful)* world?

    support for closures for runtime APIs

        in the file muse.par is the line

             events : 'event' eventList()

        whereupon the source in MuseNLP+test.swift, attaches to eventList()

             root?.setMatch("muse show event eventList()",eventListChecker)

        and attaches a simple callback to extend the lexicon:

            func eventListChecker(_ str:Substring) -> String? {
                       let ret =  str.hasPrefix("yo") ? "yo" : nil
                       return ret
            }

        which in the real world could attach to a dynamic calendar
        
to be continued

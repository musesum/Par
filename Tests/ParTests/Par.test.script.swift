/// As of 09/11/2019, Swift packages can't test file resource,
/// so, these strings are workaround. There are two strings (original, expected)
/// Original gets parsed, and Expected gets compared with post part output.
/// Some originals do have enclosing parens such as
///
///     dow ≈ (mon | tue | wed | thu | fri | sat | sun)
/// which is parsed and and regenerated as
///
///     dow ≈ mon | tue | wed | thu | fri | sat | sun
///

import Foundation

let Bug1Par = // 🚫bug! single rvalue `ask`
#"""
test ≈ ask {
ask ≈ "test" ("please" | "yo")?
}
"""#

let Bug2Par =  // 🚫bug! double ((…) …)
#"""
 a ≈ b ((c | d) | e) {
    b ≈ "bb"
    c ≈ "cc"
    d ≈ "dd"
    e ≈ "ee"
}
"""#


let Namespace1Par =
#"""
a ≈ b (c | d? | e)+ f {
    b ≈ "bb"
    c ≈ "cc"
    d ≈ "dd"
    e ≈ "ee"
    f ≈ "ff"
}
"""#

let Namespace2Par =
#"""
test ≈ ask etc {
    ask ≈ "test" ("please" | "yo")?
    etc ≈ "etc"
}
"""#

let CardinalPar = 
#"""
a ≈ uno{2,3} dos{2,} {
    uno ≈ "1"
    dos ≈ uno? "2"
}
"""#

let MultiGroupPar =
#"""
type ≈ ("alarms" | memos) ("yo" | etc)  match? {
    memos ≈ "memos"
    etc ≈ "etc"
    match ≈ memos matches()
}
"""#

let TestPar =
#"""
test ≈ ask (show | hide | setting | clear) {

    ask ≈ 'test' 'please'?
    show ≈ ('show' | 'reveal') type
    hide ≈ ('hide' | 'remove') type
    clear ≈ 'clear' type

    type ≈ 'all'? ('alarms' | 'marks' | events | memos) matching? {

        events ≈ 'event' eventList()
        memos ≈ 'memos' memoList()
        matching ≈ ('with' 'keyword' | 'matching')+ matchList()
    }

    setting ≈ 'set' (speech | debug) onoff {

        speech ≈ ('speaker' | 'speech')
        debug ≈ 'debug'
        onoff ≈ ('on' | 'off')
    }

     refresh ≈ ('refresh' | 'reset') 'screen'?
}
"""#

let RoutinePar =
#"""
routine ≈ ask (add | remove) dow+ tod duration? title {

    ask ≈ 'routine'
    add ≈ 'add' | 'insert'
    remove ≈ 'remove' | 'delete'

    title ≈ '/(?=\S)\W/'

    dow ≈ mon | tue | wed | thu | fri | sat | sun {
        mon ≈ 'mon' | 'monday'
        tue ≈ 'tue' | 'tuesday'
        wed ≈ 'wed' | 'wednesday'
        thu ≈ 'thu' | 'thursday'
        fri ≈ 'fri' | 'friday'
        sat ≈ 'sat' | 'saturday'
        sun ≈ 'sun' | 'sunday'
        weekday ≈ 'weekday' | 'week day'
        weekend ≈ 'weekend' | 'week end'
    }

    tod ≈ hour min? ampm? {
        hour ≈ '([0-2]?[0-9])'
        min ≈ '[:.]([0-5][0-9])'
        ampm ≈ '[ap]m?'
    }

    range ≈ from time to time {
        from ≈ 'from' | 'at'
        time ≈ dow | tod
        to ≈ 'to' | 'until'
    }
    duration ≈ for amount unit {
        for ≈ 'for'
        amount ≈ wordnum
        unit ≈ 'h(ou)?rs?' | 'minu?t?e?s?'
    }

    wordnum ≈ words fraction? | digits {
        words ≈ 'one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|thirty|forty|fifty|sixty|ninety'
        fraction ≈ 'tenths?|quarter|half'
        digits ≈ '[0-9]{1,5}'
    }
}
"""#
let RoutineParOut =
#"""
routine ≈ ask (add | remove) dow+ tod duration? title {
    ask ≈ 'routine'
    add ≈ 'add' | 'insert'
    remove ≈ 'remove' | 'delete'
    title ≈ '/(?=\S)\W/'
    dow ≈ mon | tue | wed | thu | fri | sat | sun {
        mon ≈ 'mon' | 'monday'
        tue ≈ 'tue' | 'tuesday'
        wed ≈ 'wed' | 'wednesday'
        thu ≈ 'thu' | 'thursday'
        fri ≈ 'fri' | 'friday'
        sat ≈ 'sat' | 'saturday'
        sun ≈ 'sun' | 'sunday'
        weekday ≈ 'weekday' | 'week day'
        weekend ≈ 'weekend' | 'week end'
    }

    tod ≈ hour min? ampm? {
        hour ≈ '([0-2]?[0-9])'
        min ≈ '[:.]([0-5][0-9])'
        ampm ≈ '[ap]m?'
    }

    range ≈ from time to time {
        from ≈ 'from' | 'at'
        time ≈ dow | tod
        to ≈ 'to' | 'until'
    }

    duration ≈ for amount unit {
        for ≈ 'for'
        amount ≈ wordnum
        unit ≈ 'h(ou)?rs?' | 'minu?t?e?s?'
    }

    wordnum ≈ words fraction? | digits  {
        words ≈ 'one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|thirty|forty|fifty|sixty|ninety'
        fraction ≈ 'tenths?|quarter|half'
        digits ≈ '[0-9]{1,5}'
    }

}
"""#

let MediaPar =
#"""
media ≈ movie | music {

    movie ≈ ask (title | director | actors) {

        ask ≈ ("show" | "watch") "movie"?
        title ≈ "title" movieTitle()
        director ≈ ("directed" | "shot") "by" movieDirector()
        actors ≈ (role | "starring") movieActor()
        role ≈ "with" | "played by" | "acted by"
    }

    music ≈ ask (search | song) "music"? {

        ask ≈ "play" | "listen to"

        song ≈ artist | track | genre {

            track ≈ next | prev | goto {

                next ≈ goPlayThe "next" songtrack?
                prev ≈ goPlayThe "previous" songtrack?
                goto ≈ goPlay "track" trackNum
                goPlay ≈ ("go" | "to" | "play"){2,3}
                goPlayThe ≈ goPlay "the"
                songtrack ≈ "song" | "track"
            }
            genre ≈ "genre" musicGenre()
            artist ≈ ("artist" | "performed" | "played") "by"? musicArtist()
        }

        search ≈ ("find" | "search" | "look") "for"? type {
            type ≈ "song" | "movie"
        }
    }
    change ≈ volume | balance {

        volume ≈ ask (amount | louder | quieter) {

            ask ≈ "make" ("music" | "sound")
            amount ≈ "a little" | "a lot" | "much"
            louder ≈ "louder" | "boom"
            quieter ≈ "quieter" | "sush"
            onoff ≈ "on" | "off"
        }
        balance ≈ "balance" ("left" | "center" | "right")
    }

    trackNum ≈ digits | wordNum {

        wordNum ≈ zero | ones | teen | tens {

            zero ≈ "zero" | "oh" | "zed"
            ones ≈ "one" | "two" | "three" | "four" | "five" | "six" | "seven" | "eight" | "nine"
            teen ≈ "ten" | "eleven" | "twelve" | "thirteen" | "fourteen" | "fifteen" | "sixteen" | "seventeen" | "eighteen" | "nineteen"
            tens ≈ "twenty" | "thirty" | "fourty" | "fifty" | "sixty" | "seventy" | "eighty" | "ninety"
        }
        digits ≈ '[0-9]{1,5}'
    }
}
"""#
let MediaParOut =
#"""
media ≈ movie | music  {
    movie ≈ ask  (title | director | actors)  {
        ask ≈ ("show" | "watch")  "movie"?
        title ≈ "title" movieTitle()
        director ≈ ("directed" | "shot") "by" movieDirector()
        actors ≈ (role | "starring")  movieActor()
        role ≈ "with" | "played by" | "acted by"
    }

    music ≈ ask  (search | song)  "music"? {
        ask ≈ "play" | "listen to"
        song ≈ artist | track | genre  {
            track ≈ next | prev | goto  {
                next ≈ goPlayThe "next" songtrack?
                prev ≈ goPlayThe "previous" songtrack?
                goto ≈ goPlay "track" trackNum
                goPlay ≈ ("go" | "to" | "play" ){2,3}
                goPlayThe ≈ goPlay "the"
                songtrack ≈ "song" | "track"
            }
            genre ≈ "genre" musicGenre()
            artist ≈ ("artist" | "performed" | "played")  "by"? musicArtist()
        }
        search ≈ ("find" | "search" | "look") "for"? typetype
    }

    change ≈ volume | balance {
        volume ≈ ask (amount | louder | quieter)  {
            ask ≈ "make" ("music" | "sound")
            amount ≈ "a little" | "a lot" | "much"
            louder ≈ "louder" | "boom"
            quieter ≈ "quieter" | "sush"
            onoff ≈ "on" | "off"
        }

        balance ≈ "balance" ("left" | "center" | "right")
    }

    trackNum ≈ digits | wordNum  {
        wordNum ≈ zero | ones | teen | tens  {
            zero ≈ "zero" | "oh" | "zed"
            ones ≈ "one" | "two" | "three" | "four" | "five" | "six" | "seven" | "eight" | "nine"
            teen ≈ "ten" | "eleven" | "twelve" | "thirteen" | "fourteen" | "fifteen" | "sixteen" | "seventeen" | "eighteen" | "nineteen"
            tens ≈ "twenty" | "thirty" | "fourty" | "fifty" | "sixty" | "seventy" | "eighty" | "ninety"
        }
        digits ≈ '[0-9]{1,5}'
    }
}
"""#
let MediaParAndOr =
#"""
wordnum ≈ words fraction? | digits {
    words ≈ 'one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|thirty|forty|fifty|sixty|ninety'
    fraction ≈ 'tenths?|quarter|half'
    digits ≈ '[0-9]{1,5}'
}
"""#

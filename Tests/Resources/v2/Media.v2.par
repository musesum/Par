
media ~ (movie | music) {
    
    movie ~ ask (title | director | actors) {
        
        ask ~ ("show" | "watch") "movie"?
        title ~ "title" movieTitle()
        director ~ ("directed" | "shot") "by" movieDirector()
        actors ~ ("with" | ("played" | "acted") "by" | "starring") movieActor()
    }
    
    music ~ ask (search | song) "music"? {
        
        ask ~ "play" | "listen to"
        
        song ~ artist | track | genre {
            
            track ~ next | prev | goto {
                
                next ~ goPlayThe "next" songtrack?
                prev ~ goPlayThe "previous" songtrack?
                goto ~ goPlay "track" trackNum
                goPlay ~ ("go" | "to" | "play"){2,3}
                goPlayThe ~ goPlay "the"
                songtrack ~ "song" | "track"
            }
            genre ~ "genre" musicGenre()
            artist ~ ("artist" | "performed" | "played") "by"? musicArtist()
        }
        
        search ~ ("find" | "search" | "look") "for"? type {
            type ~ "song" | "movie"
        }
    }
    change ~ volume | balance {
        
        volume ~ ask (amount | louder | quieter) {
            
            ask ~ "make" ("music" | "sound")
            amount ~ "a little" | "a lot" | "much"
            louder ~ "louder" | "boom"
            quieter ~ "quieter" | "sush"
            onoff ~ "on" | "off"
        }
        balance ~ "balance" ("left" | "center" | "right")
    }
    
    trackNum ~ digits | wordNum {
        
        wordNum ~ zero | ones | teen | tens {
            
            zero ~ "zero" | "oh" | "zed"
            ones ~ "one" | "two" | "three" | "four" | "five" | "six" | "seven" | "eight" | "nine"
            teen ~ "ten" | "eleven" | "twelve" | "thirteen" | "fourteen" | "fifteen" | "sixteen" | "seventeen" | "eighteen" | "nineteen"
            tens ~ "twenty" | "thirty" | "fourty" | "fifty" | "sixty" | "seventy" | "eighty" | "ninety"
        }
        digits ~ '[0-9]{1,5}'
    }
}

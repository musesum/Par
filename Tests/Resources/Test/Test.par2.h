 test ~ ask (show | hide | setting | clear) {
    
    ask ~ 'test' 'please'?
    show ~ ('show' | 'reveal') type
    hide ~ ('hide' | 'remove') type
    clear ~ 'clear' type

    type ~ 'all'? ('alarms' | 'marks' | events | memos) match? {

        events ~ 'event' events()
        memos ~ 'memos' memos()
        match? ~ ('with' 'keyword' | 'matching')+
   }

    setting ~ 'set' (speech | debug) onoff {
        
        speech ~ ('speaker' | 'speech')
        debug ~ 'debug'
        onoff ~ ('on' | 'off')
    }

    refresh ~ ('refresh' | 'reset') 'screen'?
}

test {
    (show | hide) (calendars | reminders | routine | memos)
    (say | skip) (event | time | memo)
    (hear | mute) (speaker | earbuds)
    preview (memos | routine)
}

test show all marks
test show "meetings" matching "study group"
test set speech on
test refresh screen

menu ~ calendar | reminders | memos | routine | more {
    calendars ~ Calendars.shared.sourceCals()
    reminders
}

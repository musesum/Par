test ~ ask (show | hide | setting | clear) {
    
    ask ~ 'test' 'please'?
    show ~ ('show' | 'reveal') type
    hide ~ ('hide' | 'remove') type
    clear ~ 'clear' type

    type ~ 'all'? ('alarms' | 'marks' | events | memos) match? {

        events ~ 'event' eventList()
        memos ~ 'memos' memos()
        match ~ ('with' 'keyword' | 'matching')+ matches()
    }

    setting ~ 'set' (speech | debug) onoff {
        
        speech ~ ('speaker' | 'speech')
        debug ~ 'debug'
        onoff ~ ('on' | 'off')
    }
     refresh ~ ('refresh' | 'reset') 'screen'?
}


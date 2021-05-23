test ~ ask (see | say | hear | more) {
    
    ask ~ 'test' 'now'?

    see ~ show (cal | 'reminders' | 'routine' | 'memo' | 'dial' ) {
        show ~ ('show' show() | 'hide' hide())
        cal ~ ('calendars' | 'calendar'? calendar() )
    }
    say ~ ('say' | 'skip') ('event' | 'time' | 'memo')
    hear ~ ('hear' | 'mute') ('speaker' | 'earbuds')
    more ~ 'more'? ('about' | 'support' | 'blog' | 'tour')
}

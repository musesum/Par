`routine ~ ask (add | remove) dow+ tod dur? title {

    ask ~ 'routine'
    add ~ 'add' | 'insert'
    remove ~ 'remove' | 'delete'

    title ~ '/(?=\S)\W/'

    dow ~ mon | tue | wed | thu | fri | sat | sun {
        mon ~ 'mon' | 'monday'
        tue ~ 'tue' | 'tuesday'
        wed ~ 'wed' | 'wednesday'
        thu ~ 'thu' | 'thursday'
        fri ~ 'fri' | 'friday'
        sat ~ 'sat' | 'saturday'
        sun ~ 'sun' | 'sunday'
        weekday ~ 'weekday' | 'week day'
        weekend ~ 'weekend' | 'week end'
    }

    tod ~ hour min? ampm? {
        hour ~ '([0-2]?[0-9])'
        min ~ '[:.]([0-5][0-9])'
    }

    range ~ from time to time {
        from ~ 'from' | 'at'
        time ~ dow | tod
        to ~ 'to' | 'until'
    }
    duration ~ for amount unit {
        for ~ 'for'
        amount ~ wordnum
        unit ~ 'h(ou)?rs?' | 'minu?t?e?s?'
    }

    wordnum ~ words fraction? | digits {
        words ~ 'one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|thirty|forty|fifty|sixty|ninety'
        fraction ~ prefix 'tenths?|quarter|half'
    }
}


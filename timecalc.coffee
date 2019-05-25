##==============================================================================
# Suger for getter and setter method of CoffeeScript.
Function::property = (prop, desc)->
    Object.defineProperty @prototype, prop, desc

##==============================================================================
# 行で分割する。空行は空文字列として残す。
splitByLine = (s)->
    return s if s.length is 0
    s.replace /\r\n|\n\r|\r/g, '\n'
        .split '\n'

##==============================================================================
# 入力1行を表す。
class Line
    constructor: (line)->
        m = reg.exec line
        if m?
            @label = line.substring(0, m.index).trim()
            @time1 = newTime m
            m = reg.exec line
            @time2 = newTime m
            m = reg.exec line while m?
        else
            @label = line.trim()
            @time1 = newTime()
            @time2 = newTime()
    toLine: (abs, total)->
        if @time1.zero
            t1 = ''
            t2 = ''
        else if @time2.zero
            {total, text: t1} = @time1.addTo abs, total
            t2 = ''
        else
            {total, text: t1} = @time1.addTo 'R', total
            {total, text: t2} = @time2.addTo 'S', total
        return
            total: total
            time: "#{t1}, #{t2}"
            csv: "\"#{@label}\", \"#{t1}\", \"#{t2}\""

    reg = /\b([a-zA-Z]?)(\d+)(:)?(\d{1,2})?/g
    newTime = (m)->
        absolute = if m? and m[1]? then m[1] else ''
        minutes = if m? and m[2]? then parseInt(m[2]) else 0
        minutes *= 60 if m? and m[3]?
        minutes += parseInt(m[4]) if m? and m[4]?
        new Time absolute, minutes

##==============================================================================
# 入力のうち、時間部分を表す。
class Time
    constructor: (@absolute, @minutes)->
    @property 'zero',
        get: -> @minutes is 0
    addTo: (abs, total)->
        if not not @absolute
            abs = @absolute
            total = @minutes
        else
            total += @minutes
        return
            total: total
            text: fromM abs, total

    fromM = (abs, m)-> "#{abs}#{z(Math.floor(m/60))}:#{z(m%60)}"
    z = (m)-> ("00" + m).slice -2

################################################################################
# jQuery 開始
$ ->
    $input = $ "#input"
    $time = $ "#time"
    $csv = $ "#csv"

    $input.on "input", (e)->
        total = 0
        timebuf = []
        csvbuf = []
        lines = splitByLine ($ @).val().trimEnd()
        for line, linnum in lines
            {total, time, csv} = (new Line line).toLine (if linnum+1 < lines.length then 'P' else 'R'), total
            timebuf.push time
            csvbuf.push csv

        $time.val timebuf.join '\n'
        $csv.val csvbuf.join '\n'

    $input.trigger "input"

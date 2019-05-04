splitByLine = (s)->
    return s if s.length is 0
    s.replace /\r\n|\n\r|\r/g, '\n'
        .split '\n'

toMinutes = (t)->
    return 0 if t.length is 0
    m = t.match(/\d+/g)
    if not m? then 0 else if m.length is 1 then parseInt(m[0])
    else
        parseInt(m[0]) * 60 + parseInt(m[1])

fromMinutes = (m)->
    ("00" +  Math.floor(m/60)).slice(-2) + ":" + ("00" + m%60).slice(-2)
isAbsolute = (t)-> t.trim().match /^[^\d]/

$ ->
    $input = $ "#input"
    $output = $ "#output"
    $label = $ "#label"
    $csv = $ "#csv"

    $input.bind "input", (e)->
        wholeInMinutes = 0
        outtext = []
        csvtext = []
        labels = splitByLine $label.val().trimEnd()
        for line, linenum in splitByLine ($ @).val().trimEnd()
            outline = []
            absStr = ""
            if line.length is 0
                outtext.push ""
                csvtext.push '"' + labels[linenum] + '", "", ""'
                continue
            for time in line.split(',')
                m = toMinutes time
                absStr = isAbsolute time
                if absStr
                    wholeInMinutes = m
                else
                    wholeInMinutes += m
                outline.push fromMinutes wholeInMinutes
            outtext.push outline.join ', '

            csvline = []
            csvline.push '"' + labels[linenum] + '"'
            if outline.length is 0
                csvline.push '""'
                csvline.push '""'
            else if outline.length is 1
                head = (if absStr then absStr[0].toUpperCase() else 'P')

                if labels.length <= linenum + 1 or head is 'R'
                    csvline.push '"R' + outline[0] + '"'
                    csvline.push '""'
                else if head is 'S'
                    csvline.push '""'
                    csvline.push '"S' + outline[0] + '"'
                else
                    csvline.push '"P' + outline[0] + '"'
                    csvline.push '""'
            else
                csvline.push '"R' + outline[0] + '"'
                csvline.push '"S' + outline[1] + '"'

            csvtext.push csvline.join ', '

        $output.val outtext.join '\n'
        $csv.val csvtext.join '\n'

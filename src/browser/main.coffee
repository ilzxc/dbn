dba = require './lang/dba'

variables = {}

colors = {
    a: ["aliceblue", "antiquewhite", "aqua", "aquamarine", "azure"]
    b: ["beige", "bisque", "black", "blanchedalmond", "blue", "blueviolet", "brown", "burlywood"]
    c: ["cadetblue", "chartreuse", "chocolate", "coral", "cornflowerblue", "cornsilk", "crimson", 
        "cyan"]
    f: ["firebrick", "floralwhite", "forestgreen", "fuchsia"]
    g: ["gainsboro", "ghostwhite", "gold", "goldenrod", "gray", "green", "greenyellow"]
    h: ["honeydew", "hotpink"]
    i: ["indianred", "indigo", "ivory"]
    k: ["khaki"]
    n: ["navajowhite", "navy"]
    o: ["oldlace", "olive", "olivedrab", "orange", "orangered", "orchid"]
    p: ["palegoldenrod", "palegreen", "paleturquoise", "palevioletred", "papayawhip", "peachpuff",
        "peru", "pink", "plum", "powderblue", "purple"]
    r: ["rebeccapurple", "red", "rosybrown", "royalblue"]
    s: ["saddlebrown", "salmon", "sandybrown", "seagreen", "seashell", "sienna", "silver", 
        "skyblue", "slateblue", "slategray", "snow", "springgreen", "steelblue"]
    t: ["tan", "teal", "thistle", "tomato", "turquoise"]
    v: ["violet"]
    w: ["wheat", "white", "whitesmoke"]
    y: ["yellow", "yellowgreen"]
}

specialColors = {
    d: {
        prefix: 'dark'
        endings: ["blue", "cyan", "goldenrod", "gray", "green", "khaki", "magenta", "olivegreen", 
            "orange", "orchid", "red", "salmon", "seagreen", "slateblue",
            "slategray", "turquoise", "violet"]
        others: ["deeppink", "deepskyblue", "dimgray", "dodgerblue"]
    }
    l: {
        prefix: 'light'
        endings: ["blue", "coral", "cyan", "goldenrodyellow", "gray", "green", "pink", "salmon", 
            "seagreen", "skyblue", "slategray", "steelblue", "yellow"]
        others: ["lavender", "lavenderblush", "lawngreen", "lemonchiffon", "lime", "limegreen", "linen"]
    }
    m: {
        prefix: 'medium'
        endings: ["aquamarine", "blue", "orchid", "purple", "seagreen", "slateblue", "springgreen", 
            "turquoise", "violetred"]
        others: ["magenta", "maroon", "midnightblue", "mintcream", "mistyrose", "moccasin"]
    }
}

isColor = (word) ->
    check = colors[word[0]]
    if check == undefined then return isSpecialColor word
    for color in check
        if word == color then return true
    return false

isVariable = (word) ->
    variables[word] != undefined

isSpecialColor = (word) ->
    check = specialColors[word[0]]
    if check == undefined then return false
    if word.substr(0, check.prefix.length) == check.prefix
        ending = word.substr check.prefix.length
        for color in check.endings
            if ending == color then return true
        return false
    else
        for color in check.others
            if word == color then return true
    return false

getFirstOfType = (args, type, defaultValue) ->
    for arg in args
        if arg.type == type then return arg.value
    return defaultValue

getColor = (args) ->
    test = getFirstOfType args, 'word', '#000000'
    if test[0] == '#' then return test
    if isColor test then return test
    return undefined

getWeight = (args) ->
    return getFirstOfType args, 'number', 1

makeCircle = (statement) ->
    origin = new Point 0, 0
    radius = 100
    fill = '#00000000'
    strokeColor = 'black'
    strokeWeight = 0

    for arg in statement.attributes
        switch arg.attribute
            when '@fill' then fill = getColor arg.args
            when '@stroke'
                strokeColor = getColor arg.args
                strokeWeight = getWeight arg.args
            when '@radius' then radius = getWeight arg.args
            when '@origin'
                if arg.args.length == 1
                    switch arg.args[0].value
                        when 'center' then origin = view.center
                else
                    origin = new Point arg.args[0].value, arg.args[1].value
            else
                console.log "unrecognized attribute in makeCircle"

    result = new Path.Circle {
        center: origin
        radius: radius
        fillColor: fill
        strokeColor: strokeColor
        strokeWidth: strokeWeight
    }
    result

makeLine = (statement) ->
    return

makePaper = (statement) ->
    result = null
    for arg in statement.attributes
        switch arg.attribute
            when '@color'
                result = getColor arg.args
            else continue
    console.log result
    document.getElementById('didl').style.backgroundColor = result
    return

makeAssign = (statement) ->
    for arg in statement.attributes
        data = undefined
        if arg.args.length == 1
            data = arg.args[0]
        else
            data = []
            for aarg in arg.args
                data.push aarg
        variables[arg.attribute.substr 1] = data
    return

statementProcessor = (statement) ->
    for arg, i in statement.attributes
        for aarg, j in arg.args
            if aarg.type == 'word' and isVariable aarg.value
                statement.attributes[i].args[j] = variables[aarg.value]

    switch statement.keyword
        when 'CIRCLE' then makeCircle statement
        when 'PAPER' then makePaper statement
        when 'SET' then makeAssign statement
    return

paper.install window
window.onload = () ->
    paper.setup 'didl'

    codeBox = CodeMirror document.getElementById('code'), {
        lineNumbers: true,
        theme: 'monokai'
    }

    codeBox.on "change", () ->
        try
            a = dba.parse codeBox.getValue()
        catch error
            return

        variables = {}
        paper.project.clear()
        for statement in a.body
            statementProcessor statement
        return

    window.onresize()
    return

window.onresize = () ->
    didlRef = document.getElementById('didl').style
    didlRef.width = window.innerWidth / 2 + 'px'
    didlRef.height = window.innerHeight + 'px'

    codeRef = document.getElementById('code')
    codeRef.style.width = window.innerWidth / 2 + 'px'
    codeRef.style.height = codeRef.children[0].style.height = window.innerHeight + 'px'
    codeRef.style.left = Math.floor(window.innerWidth / 2) + 'px'
    return

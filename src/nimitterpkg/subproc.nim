import
    strutils, rdstdin, json, httpClient, terminal


proc inputContents*(msg: string): string =
    var
        lines: seq[string]
        contents = ""
    echo msg
    while true:
        try:
            lines.add(readLineFromStdin(""))
        except IOError:
            break
    for line in lines:
        contents &= line & "%0A"
    result = contents


proc selectTweet*(msg: string): int =
    echo msg
    var str = readLineFromStdin(" > ")
    if str != "":
        result = str.parseInt
    else: result = 0


proc writeWithColor*(s: string, color: ForegroundColor) =
    stdout.setForegroundColor(color)
    stdout.write(s)
    stdout.resetAttributes


proc checkConnections(connections: JsonNode): bool =
    result = false
    for i in connections:
        if i.getStr() == "following":
            writeWithColor("[Following] ", fgBlue)
            result = true
        elif i.getStr() == "followed_by":
            writeWithColor("[Follows you] ", fgMagenta)
            result = true
        elif i.getStr() == "following_requested":
            writeWithColor("[Follower requests]", fgGreen)
            result = true
        elif i.getStr() == "blocking":
            writeWithColor("[Blocked] ", fgRed)
            result = true
        elif i.getStr() == "muting":
            writeWithColor("[Muting] ", fgRed)
            result = true


proc renderProfileContents*(user: JsonNode, res: Response) =
    echo "[Profile]"
    writeWithColor(user["name"].getStr(), fgCyan)
    stdout.write("@")
    writeWithColor(user["screen_name"].getStr()&"\n", fgGreen)
    if res != nil:
        var connections = res.body.parseJson
        connections = connections[0]["connections"]
        if checkConnections(connections):
            echo ""
    else:
        writeWithColor("! Not available the relationship information\n  due to the request has reached the limit.\n", fgRed)
    echo user["description"].getStr() & "\n"
    writeWithColor(" " & $user["friends_count"], fgYellow)
    stdout.write(" following,")
    writeWithColor(" " & $user["followers_count"], fgYellow)
    echo " followers"
    echo """
  location: $1, url: $2
    """ % [user["location"].getStr(), user["url"].getStr()]


proc viewTweetContent*(tw: JsonNode, idx: int) =
    var contents = tw["text"].getStr().replace("\n", "\n  ")
    stdout.write("[" & $(idx+1) & "]")
    writeWithColor(tw["user"]["name"].getStr(), fgCyan)
    stdout.write("@")
    writeWithColor(tw["user"]["screen_name"].getStr()&"\n", fgGreen)
    resetAttributes(stdout)
    echo """
  $1
  - $2""" % [contents, tw["created_at"].getStr()]


proc viewTimeline*(res: Response) = 
    var
        timeline = res.body.parseJson
        flag: bool
    for i in countdown(len(timeline)-1, 0):
        flag = false
        timeline[i].viewTweetContent(i)
        if timeline[i]["favorited"].getBool() == true:
            stdout.write(" > 💙")
            flag = true
        if timeline[i]["retweeted"].getBool() == true:
            stdout.write(" > 🔃")
            flag = true
        if flag == true:
            echo "\n\n"
        else:
            echo "\n"


proc encoder*(str: string): string =
    var tmp = str
    if tmp.count(' ').bool:
        tmp = tmp.replace(" ", "%20")
    if tmp.count('!').bool:
        tmp = tmp.replace("!", "%21")
    if tmp.count('#').bool:
        tmp = tmp.replace("#", "%23")
    if tmp.count('&').bool:
        tmp = tmp.replace("&", "%26")
    if tmp.count("'").bool:
        tmp = tmp.replace("'", "%27")
    if tmp.count('(').bool:
        tmp = tmp.replace("(", "%28")
    if tmp.count(')').bool:
        tmp = tmp.replace(")", "%29")
    if tmp.count('+').bool:
        tmp = tmp.replace("+", "%2A")
    if tmp.count(',').bool:
        tmp = tmp.replace(",", "%2C")
    if tmp.count('-').bool:
        tmp = tmp.replace("-", "%2D")
    if tmp.count('/').bool:
        tmp = tmp.replace("/", "%2F")
    if tmp.count(':').bool:
        tmp = tmp.replace(":", "%3A")
    if tmp.count(';').bool:
        tmp = tmp.replace(";", "%3B")
    if tmp.count('<').bool:
        tmp = tmp.replace("<", "%3C")
    if tmp.count('=').bool:
        tmp = tmp.replace("=", "%3D")
    if tmp.count('>').bool:
        tmp = tmp.replace(">", "%3E")
    if tmp.count('[').bool:
        tmp = tmp.replace("[", "%5B")
    if tmp.count(']').bool:
        tmp = tmp.replace("]", "%5D")
    if tmp.count('^').bool:
        tmp = tmp.replace("^", "%5E")
    result = tmp
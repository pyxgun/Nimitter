import strutils

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


proc selectTweet*(msg: string): int =
    echo msg
    result = stdin.readLine.parseInt
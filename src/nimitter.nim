import
    httpClient, terminal

import
    nimitterpkg/[accountinfo, objs, getmethod, mainmenu]

from nimitterpkg/subproc import writeWithColor

when isMainModule:
    var 
        client = newHttpClient()
        res: Response

    var keys: Keys
    keys.apiKey   = apiKey
    keys.apiSec   = apiSec
    keys.tokenKey = tokenKey
    keys.tokenSec = tokenSec

    if keys.apiKey == "" or keys.apiSec == "" or
        keys.tokenKey == "" or keys.tokenSec == "":
            writeWithColor("Error: you must set all of API key/secret and Access Token key/secret", fgRed)
            quit 1

    var userInfo: UserInfo
    userInfo.screenName = screenName
    if userInfo.screenName == "":
        writeWithColor("Error: you must set screen name.", fgRed)
        quit 1
    userInfo.userName = client.getUserName(keys, userInfo.screenName)
    if userInfo.userName == "": quit 1

    if client.checkLimitState(keys).bool == false:
        writeWithColor("Error: GET /statuses/home_timeline request has reached the limit.\nAfter a while, please try again.", fgRed)
        quit 1
    res = client.getHomeTimeline(keys)

    setControlCHook(proc() {.noconv.} =
        echo "\n\nExit Nimitter..."
        system.addQuitProc(resetAttributes)
        quit 1)


while true:
    client.mainMenu(keys, userInfo, res)
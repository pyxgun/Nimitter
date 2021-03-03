import
    httpClient, terminal

import
    nimitterpkg/[config, objs, getmethod, menus]

from nimitterpkg/subproc import writeWithColor


when isMainModule:
    var 
        client = newHttpClient()
        res: Response

    var keys: Keys
    keys.apiKey   = config.apiKey
    keys.apiSec   = config.apiSec
    keys.tokenKey = config.tokenKey
    keys.tokenSec = config.tokenSec

    # check config file
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

    # check the limit to get home timeline
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
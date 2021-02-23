import httpClient

import
    nimitterpkg/[config, objs, getmethod, mainmenu]


# main
when isMainModule:
    var keys: Keys
    keys.apiKey   = apiKey
    keys.apiSec   = apiSec
    keys.tokenKey = tokenKey
    keys.tokenSec = tokenSec

    if keys.apiKey == "" or keys.apiSec == "" or
        keys.tokenKey == "" or keys.tokenSec == "":
            echo "Error: you must set all of API key/secret and Access Token key/secret"
            quit 1

    var userInfo: UserInfo
    userInfo.userName   = userName
    userInfo.screenName = screenName

    if userInfo.userName == "" or userInfo.screenName == "":
        echo "Error: you must set both of user name and screen name."
        quit 1

    var 
        client = newHttpClient()
        res: Response

    if client.checkLimitState(keys).bool == false:
        echo "Error: GET /statuses/home_timeline request has reached the limit."
        echo "After a while, please try again."
        quit 1
    res = client.getHomeTimeline(keys)

    setControlCHook(proc() {.noconv.} =
        echo "\n", "Quit Nimitter..."
        quit 1)


while true:
    client.mainMenu(keys, userInfo, res)
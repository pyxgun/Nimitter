import 
    rdstdin, strutils, httpClient, json, browsers, terminal

import
    objs, subproc, postmethod, getmethod, profilemenu, systeminfo, help, otherusermenu

{.push header:"<stdlib.h>".}
proc system(cmd:cstring)
{.pop.}


proc reloadHome(client: HttpClient, keys: Keys, res: var Response) =
    if client.checkLimitState(keys).bool == false:
        writeWithColor("Error: GET /statuses/home_timelint request has reached the limit.\nAfter a while, please try again.", fgRed)
        discard readLineFromStdin("Press any key to return to home...")
    else:
        res = client.getHomeTimeline(keys)


proc tweet(client: HttpClient, keys: Keys, res: var Response) =
    var contents = inputContents("[What's happening?]")
    if contents != "":
        if client.postTweet(keys, contents).contains("200"):
            echo "Tweet success."
            if client.checkLimitState(keys).bool == false:
                writeWithColor("Error: GET /statuses/home_timline request has reached the limit.\nAfter a while, please try again.", fgRed)
            else:
                res = client.getHomeTimeline(keys)
        else:
            echo "Failed to tweet."
    else:
        echo "The sending of the tweet has been canceled."
    discard readLineFromStdin("Press any key to return to home...")


proc reply(client: HttpClient, keys: Keys, res: var Response) =
    echo "Which Tweet do you want to reply?"
    stdout.write(" > ")
    var 
        id = stdin.readLine.parseInt
        contents = inputContents("[Tweet your reply]")
    if contents != "":
        var tw = res.body.parseJson
        if client.postTweet(keys, contents, tw[id-1]["id_str"].getStr()).contains("200"):
            echo "Retweet success."
            if client.checkLimitState(keys).bool == false:
                writeWithColor("Error: GET /statuses/home_timeline request has reached the limit.\nAfter a while, please try again.", fgRed)
            else:
                res = client.getHomeTimeline(keys)
        else:
            echo "Failed to reply."
    else:
        echo "The sending of the tweet has been canceled."
    discard readLineFromStdin("Press any key to return to home...")


proc favoriteTweet(client: HttpClient, keys: Keys, res: Response) =
    var
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to favorite?")
    if not client.postFavorite(keys, tweets[id-1]["id_str"].getStr()).contains("200"):
        echo "Failed to favorite. You've already favorited this tweet."
        discard readLineFromStdin("Press any key to return to home...")


proc unfavoriteTweet(client: HttpClient, keys: Keys, res: Response) =
    var
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to unfavorite?")
    if not client.postUnfavorite(keys, tweets[id-1]["id_str"].getStr()).contains("200"):
        echo "Failed to un-favorite. You haven't favorited this tweet yet."
        discard readLineFromStdin("Press any key to return to home...")


proc retweetTweet(client: HttpClient, keys: Keys, res: Response) =
    var 
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to retweet?")
    if not client.postRetweet(keys, tweets[id-1]["id_str"].getStr()).contains("200"):
        echo "Failed to retweet."
        discard readLineFromStdin("Press any key to return to home...")


proc unretweetTweet(client: HttpClient, keys: Keys, res: Response) =
    var 
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to unretweet?")
    if not client.postUnretweet(keys, tweets[id-1]["id_str"].getStr()).contains("200"):
        echo "Failed to un-retweet."
        discard readLineFromStdin("Press any key to return to home...")


proc viewLink(res: Response) =
    var
        tweets = res.body.parseJson
        idx = selectTweet("Which URL do you want to view?")
        urls = tweets[idx-1]["entities"]["urls"]
    if urls.len == 0:
        echo "Can't open this tweet.\nPress any key to return home..."
    else:
        openDefaultBrowser(urls[0]["url"].getStr())
        echo "Press any key to return home..."
    discard stdin.readLine


proc viewUserProfile(client: HttpClient, keys: Keys, userInfo: var UserInfo) =
    echo "Which user's profile do you want to display?"
    var 
        otherUserName = readLineFromStdin(" > @")
    if otherUserName == userInfo.screenName:
        client.profileMenu(keys, userInfo)
    else:
        client.otherUserMenu(keys, otherUserName, userInfo)



proc mainMenu*(client: HttpClient, keys:Keys, userInfo: var UserInfo, res: var Response) =
    system("clear")
    res.viewTimeline

    stdout.write("""$1@$2:HOME # """ % [userInfo.userName, userInfo.screenName])

    var op = stdin.readLine
    case op
    of "1", "rl" : client.reloadHome(keys, res)
    of "2", "t"  : client.tweet(keys, res)
    of "3", "r"  : client.reply(keys, res)
    of "4", "f"  : client.favoriteTweet(keys, res)
    of "5", "uf" : client.unfavoriteTweet(keys, res)
    of "6", "rt" : client.retweetTweet(keys, res)
    of "7", "urt": client.unretweetTweet(keys, res)
    of "8", "p"  : client.profileMenu(keys, userInfo)
    of "9", "up" : client.viewUserProfile(keys, userInfo)
    of "10", "vl": viewLink(res)
    of "11", "a" : viewSystemInfo()

    of "h", "help": help()

    # for developer command
    of "checklimit", "cl": client.getRateLimit(keys)
    else:
        discard
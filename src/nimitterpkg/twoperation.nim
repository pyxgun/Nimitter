import 
    httpclient, rdstdin, strutils, json, terminal, browsers

import
     subproc, postmethod, getmethod, objs

{.push header:"<stdlib.h>".}
proc system(cmd:cstring)
{.pop.}


proc reloadHome*(client: HttpClient, keys: Keys, res: var Response) =
    if client.checkLimitState(keys).bool == false:
        writeWithColor("Error: GET /statuses/home_timelint request has reached the limit.\nAfter a while, please try again.", fgRed)
        discard readLineFromStdin("Press ENTER to return to home...")
    else:
        res = client.getHomeTimeline(keys)


proc tweet*(client: HttpClient, keys: Keys, res: var Response) =
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
    discard readLineFromStdin("Press ENTER to return to home...")


proc reply*(client: HttpClient, keys: Keys, res: var Response) =
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
    discard readLineFromStdin("Press ENTER to return to home...")


proc favoriteTweet*(client: HttpClient, keys: Keys, res: Response) =
    var
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to favorite?")
    if not client.postFavorite(keys, tweets[id-1]["id_str"].getStr()).contains("200"):
        echo "Failed to favorite. You've already favorited this tweet."
        discard readLineFromStdin("Press ENTER to return to home...")


proc unfavoriteTweet*(client: HttpClient, keys: Keys, res: Response) =
    var
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to unfavorite?")
    if not client.postUnfavorite(keys, tweets[id-1]["id_str"].getStr()).contains("200"):
        echo "Failed to un-favorite. You haven't favorited this tweet yet."
        discard readLineFromStdin("Press ENTER to return to home...")


proc retweetTweet*(client: HttpClient, keys: Keys, res: Response) =
    var 
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to retweet?")
    if not client.postRetweet(keys, tweets[id-1]["id_str"].getStr()).contains("200"):
        echo "Failed to retweet."
        discard readLineFromStdin("Press ENTER to return to home...")


proc unretweetTweet*(client: HttpClient, keys: Keys, res: Response) =
    var 
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to unretweet?")
    if not client.postUnretweet(keys, tweets[id-1]["id_str"].getStr()).contains("200"):
        echo "Failed to un-retweet."
        discard readLineFromStdin("Press ENTER to return to home...")


proc viewLink*(res: Response) =
    var
        tweets = res.body.parseJson
        idx = selectTweet("Which URL do you want to view?")
        urls = tweets[idx-1]["entities"]["urls"]
    if urls.len == 0:
        echo "Can't open this tweet.\nPress ENTER to return home..."
    else:
        openDefaultBrowser(urls[0]["url"].getStr())
        echo "Press ENTER to return home..."
    discard stdin.readLine


proc deleteTweet*(client: HttpClient, keys: Keys, user: string, res: var Response) =
    var
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to delete?")
    if id != 0:
        stdout.write("Delete tweet? This can't be undone. Do you want to continue? [Y/n]: ")
        var confirm = stdin.readLine
        if confirm == "y":
            echo client.postDestroy(keys, tweets[id-1]["id_str"].getStr())
            res = client.getUserTimeline(keys, user)
        else: echo "Abort."
    else: echo "Abort."


proc deleteAllTweet*(client: HttpClient, keys: Keys, userInfo: UserInfo) =
    writeWithColor("Warning - You're trying deleting all tweets. This can't be undone.\nType 'CONFIRM', then will start to delete all tweets: ", fgRed)
    var confirm = stdin.readLine
    if confirm == "CONFIRM" or confirm == "confirm":
        echo client.postDestroyAll(keys, userInfo.screenName)
    else:
        echo "Abort."


proc followUser*(client: HttpClient, keys: Keys, user: string) =
    if client.postFriendCreate(keys, user).contains("200"):
        echo "Follow success."
    else:
        echo "Failed to follow."
    discard readLineFromStdin("Press ENTER to return to menu...")


proc unfollowUser*(client: HttpClient, keys: Keys, user: string) =
    var confirm = readLineFromStdin("Unfollow $1? [Y/n]: " % user)
    if confirm != "y": 
        echo "Abort."
        return
    if client.postFriendDestroy(keys, user).contains("200"):
        echo "Unfollow success."
    else:
        echo "Failed to unfollow."
    discard readLineFromStdin("Press ENTER to return menu...")


proc viewFollowList*(client: HttpClient, keys: Keys, user: string) =
    system("clear")
    var 
        i = 1
        res = client.getFriendsList(keys, user)
        followList = res.body.parseJson["users"]
    for user in followList:
        stdout.write("[" & $i & "]")
        writeWithColor(user["name"].getStr(), fgCyan)
        stdout.write("@")
        writeWithColor(user["screen_name"].getStr()&"\n", fgGreen)
        echo user["description"].getStr()
        echo ""
        i += 1
    resetAttributes(stdout)
    discard readLineFromStdin("Press ENTER to return menu...")


proc viewFollowerList*(client: HttpClient, keys: Keys, user: string) =
    system("clear")
    var 
        i = 1
        res = client.getFollowersList(keys, user)
        followList = res.body.parseJson["users"]
    for user in followList:
        stdout.write("[" & $i & "]")
        writeWithColor(user["name"].getStr(), fgCyan)
        stdout.write("@")
        writeWithColor(user["screen_name"].getStr()&"\n", fgGreen)
        echo user["description"].getStr()
        echo ""
        i += 1
    resetAttributes(stdout)
    discard readLineFromStdin("Press ENTER to return menu...")
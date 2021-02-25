import 
    rdstdin, strutils, httpClient, json

import
    objs, postmethod, getmethod, profilemenu, systeminfo

from subproc import selectTweet



proc inputContents(msg: string): string =
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


proc reloadHome(client: HttpClient, keys: Keys, res: var Response) =
    if client.checkLimitState(keys).bool == false:
        echo "Error: GET /statuses/home_timelint request has reached the limit."
        echo "After a while, please try again."
        discard readLineFromStdin("Press any key to return to home...")
    else:
        res = client.getHomeTimeline(keys)


proc tweet(client: HttpClient, keys: Keys, res: var Response) =
    var contents = inputContents(" --What's happening?")
    if contents != "":
        if client.postTweet(keys, contents).contains("200"):
            if client.checkLimitState(keys).bool == false:
                echo "Error: GET /statuses/home_timline request has reached the limit."
                echo "After a while, please try again."
            else:
                res = client.getHomeTimeline(keys)
        else:
            echo "Failed to tweet"
    else:
        echo "The sending of the tweet has been canceled."
        discard readLineFromStdin("Press any key to return to home...")


proc reply(client: HttpClient, keys: Keys, res: var Response) =
    echo "Which Tweet do you want to reply?"
    stdout.write(" > ")
    var 
        id = stdin.readLine.parseInt
        contents = inputContents(" --Tweet your reply")
    if contents != "":
        var tw = res.body.parseJson
        if client.postTweet(keys, contents, tw[id-1]["id_str"].getStr()).contains("200"):
            if client.checkLimitState(keys).bool == false:
                echo "Error: GET /statuses/home_timeline request has reached the limit."
                echo "After a while, please try again."
            else:
                res = client.getHomeTimeline(keys)
        else:
            echo "Failed to reply"
    else:
        echo "The sending of the tweet has been canceled."
        discard readLineFromStdin("Press any key to return to home...")


proc favoriteTweet(client: HttpClient, keys: Keys, res: Response) =
    var
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to favorite?")
    echo client.postFavorite(keys, tweets[id-1]["id_str"].getStr())


proc unfavoriteTweet(client: HttpClient, keys: Keys, res: Response) =
    var
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to unfavorite?")
    echo client.postUnfavorite(keys, tweets[id-1]["id_str"].getStr())


proc retweetTweet(client: HttpClient, keys: Keys, res: Response) =
    var 
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to retweet?")
    echo client.postRetweet(keys, tweets[id-1]["id_str"].getStr())


proc unretweetTweet(client: HttpClient, keys: Keys, res: Response) =
    var 
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to unretweet?")
    echo client.postUnretweet(keys, tweets[id-1]["id_str"].getStr())


proc viewUserProfile(client: HttpClient, keys: Keys, userInfo: var UserInfo) =
    echo "Which user's profile do you want to display?"
    var 
        otherUserName = readLineFromStdin(" > @")
        prof: string
    if otherUserName == userInfo.screenName:
        client.profileMenu(keys, userInfo)
    else:
        prof = client.getUserProfile(keys, otherUserName)
        if prof != "":
            echo prof
            discard client.getUserTimeline(keys, otherUserName)
        discard readLineFromStdin("Press any key to return to home...")


proc mainMenu*(client: HttpClient, keys:Keys, userInfo: var UserInfo, res: var Response) =
    res.viewTimeline
#[
    echo "\n", """
[Select operation]
  Reload:1,      Tweet:2,        Reply:3,
  Favorite:4,    Unfavorite:5,   Retweet:6,  Unretweet:7,
  My profile:8,  User profile:9  About:10"""
]#
    stdout.write("""$1@$2> """ % [userInfo.userName, userInfo.screenName])

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
    of "10", "a" : viewSystemInfo()

    of "h", "help": echo "Help menu"

    # for developer command
    of "checklimit", "CheckLimit", "cl", "CL": client.getRateLimit(keys)
    else:
        discard
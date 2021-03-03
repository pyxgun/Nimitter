import 
    strutils, httpClient, rdstdin

import
    objs, subproc, getmethod, postmethod, systeminfo, help, twoperation


{.push header:"<stdlib.h>".}
proc system(cmd:cstring)
{.pop.}

proc profileMenu*(client: HttpClient, keys: Keys, userInfo: var UserInfo)
proc viewUserProfile*(client: HttpClient, keys: Keys, userInfo: var UserInfo)



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
    of "checklimit", "cl": client.getRateLimit(keys)
    else:
        discard



proc updateProfile*(client: HttpClient, keys: Keys, userInfo: var UserInfo) = 
    echo """
 --Which items do you want to change?
  Name:1,  Bio:2,  Location:3,  URL:4"""
    stdout.write(" > ")
    var
        op = stdin.readLine
        param: string
        contents: string
    case op
    of "1", "n": param = "name"
    of "2", "b": param = "description"
    of "3", "l": param = "location"
    of "4", "u": param = "url"
    else:
        echo "Abort"
        return

    try:
        contents = readLineFromStdin(" New >> ")
        echo client.postUpdateProfile(keys, param, contents)
    except IOError:
        echo "Changes have been canceled."
        discard readLineFromStdin("Press any key to return profile menu...")
    if param == "name":
        userInfo.userName = client.getUserName(keys, userInfo.screenName)



proc profileMenu*(client: HttpClient, keys: Keys, userInfo: var UserInfo) =
    var res = client.getUserTimeline(keys, userInfo.screenName)
    while true:
        system("clear")
        res.viewTimeline
        discard client.getUserProfile(keys, userInfo.screenName)

        stdout.write("""$1@$2:PROFILE # """ % [userInfo.userName, userInfo.screenName])

        var op = stdin.readLine
        case op
        of "1", "e"  : client.updateProfile(keys, userInfo)
        of "2", "d"  : client.deleteTweet(keys, userInfo.screenName, res)
        of "3", "vf" : client.viewFollowList(keys, userInfo.screenName)
        of "4", "vfw": client.viewFollowerList(keys, userInfo.screenName)
        of "5", "b"  : break
        of "h", "help": help()
        of "destroyall", "da": client.deleteAllTweet(keys, userInfo)



proc otherUserMenu*(client: HttpClient, keys: Keys, user: string, userInfo: UserInfo) =
    var res = client.getUserTimeline(keys, user)
    if res.body.contains("not exist"):
        echo "@$1 doesn't exist.\nTry searching another.\n" % user
        discard readLineFromStdin("Press ENTER to return to home...")
        return
    while true:
        system("clear")
        if res.body.contains("Not authorized"):
            echo "These Tweets are protected.\nOnly confirmed followers can see @$1's Tweets." % user
        else:
            res.viewTimeline
        discard client.getUserProfile(keys, user)
        stdout.write("""$1@$2:@$3 PROFILE # """ % [userInfo.userName, userInfo.screenName, user])
        var op = stdin.readLine
        case op
        of "1", "fl" : client.followUser(keys, user)
        of "2", "ufl": client.unfollowUser(keys, user)
        of "3", "r"  : client.reply(keys, res)
        of "4", "f"  : client.favoriteTweet(keys, res)
        of "5", "uf" : client.unfavoriteTweet(keys, res)
        of "6", "rt" : client.retweetTweet(keys, res)
        of "7", "urt": client.unretweetTweet(keys, res)
        of "8", "vf" : client.viewFollowList(keys, user)
        of "9", "vfw": client.viewFollowerList(keys, user)
        of "10", "b" : break
        of "h", "help": help()



proc viewUserProfile*(client: HttpClient, keys: Keys, userInfo: var UserInfo) =
    echo "Which user's profile do you want to display?"
    var 
        otherUserName = readLineFromStdin(" > @")
    if otherUserName == userInfo.screenName:
        client.profileMenu(keys, userInfo)
    else:
        client.otherUserMenu(keys, otherUserName, userInfo)

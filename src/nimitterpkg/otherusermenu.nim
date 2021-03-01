import 
    httpclient, rdstdin, strutils, json

import 
    objs, postmethod, getmethod, subproc


{.push header:"<stdlib.h>".}
proc system(cmd:cstring)
{.pop.}


proc followUser(client: HttpClient, keys: Keys, user: string) =
    if client.postFriendCreate(keys, user).contains("200"):
        echo "Follow success."
    else:
        echo "Failed to follow."
    discard readLineFromStdin("Press ENTER to return to menu...")


proc unfollowUser(client: HttpClient, keys: Keys, user: string) =
    var confirm = readLineFromStdin("Unfollow $1? [Y/n]: " % user)
    if confirm != "y": 
        echo "Abort."
        return
    if client.postFriendDestroy(keys, user).contains("200"):
        echo "Unfollow success."
    else:
        echo "Failed to unfollow."
    discard readLineFromStdin("Press ENTER to return menu...")


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
        of "3", "f"  : client.favoriteTweet(keys, res)
        of "4", "uf" : client.unfavoriteTweet(keys, res)
        of "b": break
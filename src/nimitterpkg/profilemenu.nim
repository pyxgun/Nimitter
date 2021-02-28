import
    httpClient, json, rdstdin, strutils, terminal

import
    objs, postmethod, getmethod, help, subproc

from subproc import selectTweet



proc updateProfile(client: HttpClient, keys: Keys, userInfo: var UserInfo) = 
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



proc deleteTweet(client: HttpClient, keys: Keys, res: Response) =
    var
        tweets = res.body.parseJson
        id = selectTweet("Which Tweet do you want to delete?")
    if id != 0:
        stdout.write("Delete tweet? This can't be undone. Do you want to continue? [Y/n]: ")
        var confirm = stdin.readLine
        if confirm == "y":
            echo client.postDestroy(keys, tweets[id-1]["id_str"].getStr())
        else: echo "Abort."
    else: echo "Abort."



proc deleteAllTweet(client: HttpClient, keys: Keys, userInfo: UserInfo) =
    writeWithColor("Warning - You're trying deleting all tweets. This can't be undone.\nType 'CONFIRM', then will start to delete all tweets: ", fgRed)
    var confirm = stdin.readLine
    if confirm == "CONFIRM" or confirm == "confirm":
        echo client.postDestroyAll(keys, userInfo.screenName)
    else:
        echo "Abort."



proc profileMenu*(client: HttpClient, keys: Keys, userInfo: var UserInfo) =
    while true:
        discard client.getUserProfile(keys, userInfo.screenName)
        var res = client.getUserTimeline(keys, userInfo.screenName)

        stdout.write("""$1@$2:PROFILE # """ % [userInfo.userName, userInfo.screenName])

        var op = stdin.readLine
        case op
        of "1", "e": client.updateProfile(keys, userInfo)
        of "2", "d": client.deleteTweet(keys, res)
        of "3", "b": break
        of "h", "help": help()
        of "destroyall", "da": client.deleteAllTweet(keys, userInfo)
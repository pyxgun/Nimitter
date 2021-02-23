import
    oauth1, json, httpclient, strutils

import objs

from subproc import encoder
    

{.push header:"<stdlib.h>".}
proc system(cmd:cstring)
{.pop.}



# GET methods resource URL
const
    getHomeTimelineUrl   = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    getUserTimelineUrl*   = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    getUserProfileUrl    = "https://api.twitter.com/1.1/users/show.json"
    getRateLimitUrl      = "https://api.twitter.com/1.1/application/rate_limit_status.json"



proc shapeContent(tw: JsonNode): string =
    var contents = tw["text"].getStr().replace("\n", "\n  ")
    result = """
$1@$2
  $3
  - $4""" % [tw["user"]["name"].getStr(), tw["user"]["screen_name"].getStr(), contents, tw["created_at"].getStr()]


proc viewTimeline*(res: Response) = 
    var
        timeline = res.body.parseJson
        flag: bool
    system("clear")
    for i in countdown(len(timeline)-1, 0):
        flag = false
        echo "[" & $(i+1) & "]" & timeline[i].shapeContent
        if timeline[i]["favorited"].getBool() == true:
            stdout.write(" > 💙")
            flag = true
        if timeline[i]["retweeted"].getBool() == true:
            stdout.write(" > 🔃")
            flag = true
        if flag == true:
            echo "\n\n"
        else:
            echo "\n"


# GET methods
proc getHomeTimeline*(client: HttpClient, keys: Keys, count: int = 30): Response =
    var 
        resourceUrl = getHomeTimelineUrl & "?count=" & $count
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpGet)
    result = res


proc getUserTimeline*(client: HttpClient, keys: Keys, user: string, count: int = 10): Response =
    var
        resourceUrl = getUserTimelineUrl & "?screen_name=" & user & "&count=" & $count
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpGet)
        timeline = res.body.parseJson
        idx: int = 1
    echo "[Tweets]"
    for tw in timeline:
        echo "[" & $idx & "]" & tw.shapeContent
        echo ""
        idx += 1
    result = res


proc getUserProfile*(client: HttpClient, keys: Keys, user: string): string =
    var
        resourceUrl = getUserProfileUrl & "?screen_name=" & user
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpGet)
    if res.status.contains("200"):
        let userInfo = res.body.parseJson

        system("clear")
        result = """
[Profile]
$1@$2

$3

  $4 following, $5 followers
  location: $6,  url: $7
    """ % [userInfo["name"].getStr(), userInfo["screen_name"].getStr(),
            userInfo["description"].getStr(), $userInfo["friends_count"], $userInfo["followers_count"],
            userInfo["location"].getStr(), userInfo["url"].getStr()]
    else:
        echo "User not found."
        result = ""


proc getRateLimit*(client: HttpClient, keys: Keys) =
    var
        requestResource = "statuses,users,account"
        resourceUrl = getRateLimitUrl & "?resources=" & requestResource.encoder
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpGet)
        rate = res.body.parseJson
        limitHomeTimeline  = rate["resources"]["statuses"]["/statuses/home_timeline"]
        limitUserTimeline  = rate["resources"]["statuses"]["/statuses/user_timeline"]
        limitUpdateProfile = rate["resources"]["account"]["/account/update_profile"]
        limitUsersId       = rate["resources"]["users"]["/users/:id"]

    let info = """
[Limit Information]
"/statuses/home_timeline":
    Limit    : $1
    Remaining: $2
    Reset    : $3

"/statuses/user_timeline":
    Limit    : $4
    Remaining: $5
    Reset    : $6

"/account/update_profile":
    Limit    : $7
    Remaining: $8
    Reset    : $9

"/users/:id":
    Limit    : $10
    Remaining: $11
    Reset    : $12
""" % [$limitHomeTimeline["limit"], $limitHomeTimeline["remaining"], $limitHomeTimeline["reset"],
       $limitUserTimeline["limit"], $limitUserTimeline["remaining"], $limitUserTimeline["reset"],
       $limitUpdateProfile["limit"], $limitUpdateProfile["remaining"], $limitUpdateProfile["reset"],
       $limitUsersId["limit"], $limitUsersId["remaining"], $limitUsersId["reset"]]

    echo ""
    echo info
    stdout.write("Press any key to quit...")
    discard stdin.readLine


proc checkLimitState*(client: HttpClient, keys: Keys): int =
    var
        resourceUrl = getRateLimitUrl & "?resources=statuses"
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpGet)
        limitHomeTimeline = res.body.parseJson
    result = limitHomeTimeline["resources"]["statuses"]["/statuses/home_timeline"]["remaining"].getInt
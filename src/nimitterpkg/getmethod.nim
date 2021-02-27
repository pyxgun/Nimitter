import
    oauth1, json, httpclient, strutils

import
    objs, subproc
    

{.push header:"<stdlib.h>".}
proc system(cmd:cstring)
{.pop.}



# GET methods resource URL
const
    getHomeTimelineUrl   = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    getUserTimelineUrl*  = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    getUserProfileUrl    = "https://api.twitter.com/1.1/users/show.json"
    getRateLimitUrl      = "https://api.twitter.com/1.1/application/rate_limit_status.json"



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
        idx: int = 0
    echo "[Tweets]"
    for tw in timeline:
        tw.viewTweetContent(idx)
        echo ""
        idx += 1
    result = res


proc getUserProfile*(client: HttpClient, keys: Keys, user: string): Response.status =
    var
        resourceUrl = getUserProfileUrl & "?screen_name=" & user
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpGet)
    if res.status.contains("200"):
        let userInfo = res.body.parseJson
        system("clear")
        userInfo.viewProfileContent
    else:
        echo "User not found."
    result = res.status


proc getUserName*(client: HttpClient, keys: Keys, user: string): string =
    var 
        resourceUrl = getUserProfileUrl & "?screen_name=" & user
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpGet)
    if res.status.contains("200"):
        let userInfo = res.body.parseJson
        result = userInfo["name"].getStr()
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
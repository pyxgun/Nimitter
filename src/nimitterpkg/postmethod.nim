import
    oauth1, json, httpclient, strutils

import objs

from getmethod import getUserTimelineUrl
from subproc import encoder


# POST methods resource URL
const
    postTweetUrl           = "https://api.twitter.com/1.1/statuses/update.json"
    postDestroyUrl         = "https://api.twitter.com/1.1/statuses/destroy/"
    postRetweetUrl         = "https://api.twitter.com/1.1/statuses/retweet/"
    postUnretweetUrl       = "https://api.twitter.com/1.1/statuses/unretweet/"
    postFavoriteUrl        = "https://api.twitter.com/1.1/favorites/create.json"
    postUnfavoriteUrl      = "https://api.twitter.com/1.1/favorites/destroy.json"
    postUpdateProfileUrl   = "https://api.twitter.com/1.1/account/update_profile.json"
    postMediaUrl           = "https://upload.twitter.com/1.1/media/upload.json"



proc shapeContent*(tw: JsonNode): string =
    var contents = tw["text"].getStr().replace("\n", "\n  ")
    result = """
$1@$2 - $3
  $4""" % [tw["user"]["name"].getStr(), tw["user"]["screen_name"].getStr(), tw["created_at"].getStr(), contents]


# POST methods
proc postTweet*(client: HttpClient, keys: Keys, contents: string, reply: string = ""): Response.status =
    var
        bodyContent: string
        tweet = contents.encoder
    if reply != "":
        bodyContent = "status=" & tweet & "&in_reply_to_status_id=" & reply & "&auto_populate_reply_metadata=true"
    else:
        bodyContent = "status=" & tweet
    var 
        resourceUrl = bodyContent
        res = client.oAuth1Request(postTweetUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost, body = resourceUrl)
    result = res.status


proc postDestroy*(client: HttpClient, keys: Keys, id: string): Response.status =
    var 
        resourceUrl = postDestroyUrl & "/" & id & ".json"
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost)
    result = res.status
    

proc postDestroyAll*(client: HttpClient, keys: Keys, user: string): Response.status =
    var 
        resourceUrl = getUserTimelineUrl & "?screen_name=" & user & "&count=200"
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpGet)
        tmp = client.postTweet(keys, "Begin the process of deleting all tweets.")
        timeline = res.body.parseJson
    for tw in timeline:
        var destoyReq = postDestroyUrl & "/" & $tw["id"] & ".json"
        res = client.oAuth1Request(destoyReq, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                        httpMethod = HttpPost)
    tmp = client.postTweet(keys, "The process has been completed.")


proc postFavorite*(client: HttpClient, keys: Keys, id: string): Response.status =
    var 
        bodyContent = "id=" & id
        res = client.oAuth1Request(postFavoriteUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost, body = bodyContent)
    result = res.status


proc postUnfavorite*(client: HttpClient, keys: Keys, id: string): Response.status =
    var
        bodyContent = "id=" & id
        res = client.oAuth1Request(postUnfavoriteUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost, body = bodyContent)
    result = res.status        


proc postRetweet*(client: HttpClient, keys: Keys, id: string): Response.status =
    var
        resourceUrl = postRetweetUrl & id & ".json"
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost)
    result = res.status


proc postUnretweet*(client: HttpClient, keys: Keys, id: string): Response.status =
    var
        resourceUrl = postUnretweetUrl & id & ".json"
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost)
    result = res.status


proc postUpdateProfile*(client: HttpClient, keys: Keys, param: string, contents: string): Response.status =
    var
        paramContents = contents.encoder.replace(""""""", "%22")
        resourceUrl   = postUpdateProfileUrl & "?" & param & "=" & paramContents
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost)
    result = res.status
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
    postFriendCreateUrl    = "https://api.twitter.com/1.1/friendships/create.json"
    postFriendDestroyUrl   = "https://api.twitter.com/1.1/friendships/destroy.json"



proc shapeContent*(tw: JsonNode): string =
    var contents = tw["text"].getStr().replace("\n", "\n  ")
    result = """
$1@$2 - $3
  $4""" % [tw["user"]["name"].getStr(), tw["user"]["screen_name"].getStr(), tw["created_at"].getStr(), contents]


# POST methods
proc postTweet*(client: HttpClient, keys: Keys, contents: string, replyTo: string = ""): Response.status =
    var
        bodyContent: string
        tweet = contents.encoder
    if replyTo != "":
        bodyContent = "status=" & tweet & "&in_reply_to_status_id=" & replyTo & "&auto_populate_reply_metadata=true"
    else:
        bodyContent = "status=" & tweet
    var 
        res = client.oAuth1Request(postTweetUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost, body = bodyContent)
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
        timeline = res.body.parseJson
    for tw in timeline:
        var destoyReq = postDestroyUrl & "/" & $tw["id"] & ".json"
        res = client.oAuth1Request(destoyReq, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                        httpMethod = HttpPost)


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


proc postFriendCreate*(client: HttpClient, keys: Keys, user: string): Response.status =
    var
        resourceUrl = postFriendCreateUrl & "?screen_name=" & user
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost)
    result = res.status


proc postFriendDestroy*(client: HttpClient, keys: Keys, user: string): Response.status =
    var
        resourceUrl = postFriendDestroyUrl & "?screen_name=" & user
        res = client.oAuth1Request(resourceUrl, keys.apiKey, keys.apiSec, keys.tokenKey, keys.tokenSec,
                                    httpMethod = HttpPost)
    result = res.status
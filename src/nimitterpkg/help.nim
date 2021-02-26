import
    strutils, rdstdin

import systeminfo

{.push header: "<stdlib.h>".}
proc system(cmd:cstring)
{.pop.}


proc help*() =
    system("clear")

    echo """
$1 $2
$3

You can operate by entering the following number or strings.

[HOME TIMELINE]
    MAIN OPERATIONS:
        1, rl
            reload home timeline

        2, t
            tweet your message

        3, r
            reply your message to selected tweet
        
        4, f
            favorite (like) selected tweet

        5, uf
            un-favorite (un-like) the tweet that is already favorited/liked

        6, rt
            retweet selected tweet

        7, urt
            un-retweet the tweet that is already retweeted

        8, p
            view your account profile
        
        9, up
            view user profile

        10, a
            about this application

    OTHER:
        h, help
            view help page

        checklimit, cl
            check current some request limit (this is for developer)

[PROFILE]
    MAIN OPERATIONS:
        1, e
            edit your profile

        2, d
            delete the tweet you selected

        3, b
            back to home timeline

    EDIT MENU:
        1, n
            change name
        
        2, b
            change bio
        
        3, l
            change location

        4, u
            change url

    OTHER:
        destroyall, da
            delete your all tweet
    
[AUTHOR]
    written by $4
    """ % [systemName, systemVersion, systemDescription, systemAuthor]

    discard readLineFromStdin("Press any key to return to home...")
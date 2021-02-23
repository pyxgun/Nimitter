import strutils, rdstdin

const
    systemName        = "Nimitter"
    systemVersion     = "ver.0.1.0"
    systemDescription = "Simple Twitter client written in Nim"
    systemAuthor      = "PyxGun"
    infoGit           = "https://github.com/pyxgun"
    infoTwitter       = "https://twitter.com/pyxgun"


proc viewSystemInfo*() =
    echo """

$1 $2
  $3

Author: $4
Github: $5
Twitter $6
""" % [systemName, systemVersion, systemDescription, systemAuthor, infoGit, infoTwitter], "\n"
  
    discard readLineFromStdin("Press any key to return to home...")
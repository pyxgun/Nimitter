# Package

version       = "0.1.3"
author        = "PyxGun"
description   = "A simple twitter client written in Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["nimitter"]


# Dependencies

requires "nim >= 1.4.2"
requires "https://github.com/CORDEA/oauth >= 0.10"
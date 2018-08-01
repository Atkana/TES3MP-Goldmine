# 0.6.2hfx README

### YOU ARE NOT FORCED TO USE DEATHDROP IN RP, IT IS NOT SUGGESTED BUT IT IS PROVIDED TO YOU HERE TODAY!

## DO NOT OVERWRITE myMOD.lua AND server.lua WITH THE ONES IN THIS PACKAGE, DO SO AT YOUR OWN RISK!

MYMOD
```lua
tableHelper = require("tableHelper")
inventoryHelper = require("inventoryHelper")
starterItems = require("starterItems")
BannedItems = require("BannedItems")
require("actionTypes")
local time = require("time")
questFixer = require("questFixer")
```

SERVER
```lua
disableAssassins = require("disableAssassins")
require("config")
class = require("classy")
tableHelper = require("tableHelper")
require("utils")
require("guiIds")
require("color")
require("time")
```

playercells.json are to be placed if you have pre-populated errors around corescripts/data/playercells.json.
such as,

```bash
[2018-03-20 22:58:23] [WARN]: [Script]: Reading banlist.json
[2018-03-20 22:58:23] [WARN]: [Script]: Reading pluginlist.json
1, {Morrowind.esm, 7B6AF5B9, 34282D67}
2, {Tribunal.esm, F481F334, 211329EF}
3, {Bloodmoon.esm, 43DD2132, 9EB62F26}
[2018-03-20 22:58:23] [ERR]: ./CoreScripts/lib/lua/jsonInterface.lua:7: Error loading file: playercells.json
terminate called after throwing an instance of 'luabridge::LuaException'
  what():  ./CoreScripts/lib/lua/jsonInterface.lua:7: Error loading file: playercells.json
./tes3mp-server: line 7: 12287 Aborted                 LD_LIBRARY_PATH="./lib" ./tes3mp-server.x86_64 "$@"
```

If you are wanting cell resets to purge, while saving cell names in linux.

```bash
#Path to your data folder in CoreScripts
datadir=/home/USER/TES3MP/TES3MPPersonal/CoreScripts/data
#Path to a temporary folder to hold cells
tmpdir=/home/USER/TES3MP/TES3MPPersonal/tmp

#cells to save, copies to the temp folder
    cp "$datadir/cell/Gnisis, Arvs-Drelen.json" $tmpdir -f

#Purge cells from data
    rm $datadir/cell/* -f
    rm $datadir/world/* -f

#move cells that were saved back to data and clean out temporary folder
    cp $tmpdir/* $datadir/cell
    rm $tmpdir/*
```
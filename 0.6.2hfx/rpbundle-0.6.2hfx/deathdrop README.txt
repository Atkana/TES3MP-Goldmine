YOU ARE NOT FORCED TO USE DEATHDROP IN RP, IT IS NOT SUGGESTED BUT IT IS PROVIDED TO YOU HERE TODAY!


If you are running disableAssassins.lua BUT ARE ALSO running deathdrop.lua, replace the

deathDrop.OnObjectSpawn(pid, cellDescription)

with:

disableAssassins.OnObjectSpawn(pid, cellDescription)

inside server.lua


1.) Add deathDrop = require("deathdrop") near the top of server.lua under myMod = require("myMod")

2.) CTRL+F and find OnPlayerDeath inside server.lua then put deathDrop.OnPlayerDeath(pid) at the beginning of that block

3.) CTRL+F and find OnPlayerCellChange inside server.lua then put deathDrop.OnPlayerCellChange(pid) at the end of that block

4.) CTRL+F and find OnObjectSpawn inside server.lua then put deathDrop.OnObjectSpawn(pid, cellDescription) at the end of that block

Planned features never reached,

Moving safezone data into a json.
allowing reverse safezone allocation (everywhere is a safezone except cells listed)
removing disabling assassins from this script and having disableAssassins.lua detect deathDrop settings.
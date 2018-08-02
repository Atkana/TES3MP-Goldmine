---------------------------
-- spawnRandomizer by Texafornian (slight edits by Atkana - blame if things go wrong)
-- TES3MP v.0.6.1

--[[ INSTALLATION INSTRUCTIONS
1) Save this file as "spawnRandomizer.lua" in mp-stuff/scripts
2) Add [ spawnRandomizer = require("spawnRandomizer") ] to the top of server.lua
3) Add the following AFTER myMod.OnPlayerEndCharGen(pid) in OnPlayerEndCharGen in server.lua
[	spawnRandomizer.SpawnPosition(pid)
	spawnRandomizer.SpawnItems(pid)	]

]]

------------------
-- METHODS SECTION
------------------

Methods = {}

math.randomseed( os.time() )
math.random(); math.random() -- Try to improve RNG

local spawnTable = {
  {"-3, 6", -16523, 54362, 1973, 2.73}, -- Ald'Ruhn
  {"-11, 15", -89353, 128479, 110, 1.86}, -- Ald Velothi
  {"-3, -3", -20986, -17794, 865, -0.87}, -- Balmora
  {"-2, 2", -12238, 20554, 1514, -2.77}, -- Caldera
  {"7, 22", 62629, 185197, 131, -2.83}, -- Dagon Fel
  {"2, -13", 20769, -103041, 107, -0.87}, -- Ebonheart
  {"-8, 3", -58009, 26377, 52, -1.49}, -- Gnaar Mok
  {"-11, 11", -86910, 90044, 1021, 0.44}, -- Gnisis
  {"-6, -5", -49093, -40154, 78, 0.94}, -- Hla Oad
  {"-9, 17", -69502, 142754, 50, 2.89}, -- Khuul
  {"-3, 12", -22622, 101142, 1725, 0.28}, -- Maar Gan
  {"12, -8", 103871, -58060, 1423, 2.2}, -- Molag Mar
  {"0, -7", 2341, -56259, 1477, 2.13}, -- Pelagiad
  {"17, 4", 141415, 39670, 213, 2.47}, -- Sadrith Mora
  {"6, -6", 52855, -48216, 897, 2.36}, -- Suran
  {"14, 4", 122576, 40955, 59, 1.16}, -- Tel Aruhn
  {"14, -13", 119124, -101518, 51, 3.08}, -- Tel Branora
  {"13, 14", 106608, 115787, 53, -0.39}, -- Tel Mora
  {"3, -10", 36412, -74454, 59, -1.66}, -- Vivec
  {"11, 14", 101402, 114893, 158, -2.03}, -- Vos
}


Methods.SpawnItems = function(pid) -- Randomized clothes for new players + 250 gold
	local item = {}
	local race = string.lower(Players[pid].data.character.race)
	local spawnGold = { refId = "gold_001", count = 250, charge = -1 }
	local spawnPants = "common_pants_0"
	local spawnShirt = "common_shirt_0"
	local spawnSkirt = "common_skirt_0"
	local spawnShoes = "common_shoes_0"
	
	local rando = tostring(math.random(1,7))
	
	Players[pid].data.inventory = {}
	Players[pid].data.equipment = {}
	
	tes3mp.LogMessage(2, "++++ Adding gold to new character ++++")
	table.insert(Players[pid].data.inventory, spawnGold)
	
	tes3mp.LogMessage(2, "++++ Randomizing new player's clothes ++++")
	spawnShirt = spawnShirt .. rando
	item = { refId = spawnShirt, count = 1, charge = -1 }
	Players[pid].data.equipment[8] = item
	
	if Players[pid].data.character.gender == 0 then
		rando = tostring(math.random(1,5))
		spawnSkirt = spawnSkirt .. rando
		item = { refId = spawnSkirt, count = 1, charge = -1 }
		Players[pid].data.equipment[10] = item
	else
		rando = tostring(math.random(1,7))
		spawnPants = spawnPants .. rando
		item = { refId = spawnPants, count = 1, charge = -1 }
		Players[pid].data.equipment[9] = item
	end
	
	if race ~= "argonian" and race ~= "khajiit" then
		rando = tostring(math.random(1,5))
		spawnShoes = spawnShoes .. rando
		item = { refId = spawnShoes, count = 1, charge = -1 }
		Players[pid].data.equipment[7] = item
	end
	
	Players[pid]:LoadInventory()
	Players[pid]:LoadEquipment()
end

Methods.SpawnPosition = function(pid) -- Randomized spawn position based on spawnTable in this script
	local tempRef = math.random(1,#spawnTable) -- Pick a random value from the spawn table
	
	tes3mp.LogMessage(2, "++++ Spawning new player in cell ... ++++")
	tes3mp.LogMessage(2, "++++ (" .. spawnTable[tempRef][1] .. ") ++++")
	tes3mp.SetCell(pid, spawnTable[tempRef][1])
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, spawnTable[tempRef][2], spawnTable[tempRef][3], spawnTable[tempRef][4])
	tes3mp.SetRot(pid, 0, spawnTable[tempRef][5])
	tes3mp.SendPos(pid)
end


return Methods

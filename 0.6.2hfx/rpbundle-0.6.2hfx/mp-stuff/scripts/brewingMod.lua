--[[ReinhartXIV's Custom Potions V0.04]]
-- Read the readme for installation and usage.

brewingMod = {}

	math.randomseed( os.time() )

	--Create tables for alchemy
	local alchemyTable = {}	
	local tableContent = {}
	local tableKey = ""
	
	local potionTable = {}
	local validPotions = {}
	local validEffects = {}
	
	brewingMod.pickedIngredients = {}
	brewingMod.pickedIngredientsCount = 0
	brewingMod.qualityThresholds = { 0 , 10, 20, 35, 50 }
	brewingMod.ingredientNames = {}
	
	local validPotionCount = 0
	local selectedPotionId = 0
	
	brewingMod.label = ""
	
	--Store ingredient names and refIds in a table
	local home = os.getenv("MOD_DIR") .. "/"
	local file = io.open(home .. "brewingModData/ingredientNames.txt", "r")
		
	local tempCount = 0
	local tempName = ""
	local tempRefId = ""
	
	for line in file:lines() do
		if tempCount == 0 then 
			tempName = line
		elseif tempCount == 1 then
			tempRefId = line
			brewingMod.ingredientNames[tempRefId] = tempName
			tempCount = -1
		end
		tempCount = tempCount + 1
	end

	file:close()
	
	local file = io.open(home .. "brewingModData/alchemy.txt", "r")

	for line in file:lines() do
		if string.match(line, '%l') then --Parse by lowercase letters
			table.insert(tableContent, line)
		else
			alchemyTable[tableKey] = tableContent
			tableContent = {}
			--Change the table key
			tableKey = line
		end
	end

	file:close()

	local file = io.open(home .. "brewingModData/potions.txt", "r")

	tableContent = {}

	for line in file:lines() do
		if string.match(line, '%l') then --Parse by lowercase letters
			table.insert(tableContent, line)
		else
			potionTable[tableKey] = tableContent
			tableContent = {}
			--Change the table key
			tableKey = line
		end
	end

	file:close()

	brewingMod.GetRefIdCount = function(pid,refId)
		for index,item in pairs(Players[pid].data.inventory) do
			if string.find(item.refId, refId, 1, true) then
				return item.count
			end
		end
	end

	brewingMod.GetRefId = function(t,key,id)
		for k,v in pairs(t) do
			if k == key then
				for i,_ in pairs(v) do
					if id == i then
						return v[i]
					end
				end
			end
		end
	end
	
	brewingMod.GetNameByRefId = function(refId)
		local name = refId
		for k,v in pairs(brewingMod.ingredientNames) do
			if k == refId then 
				name = v 
			end
		end
		return name
	end
	
	brewingMod.CheckBottles = function(pid)
		local validBottles = {"misc_com_bottle_01","misc_com_bottle_02","Misc_Com_Bottle_04","misc_com_bottle_05","misc_com_bottle_06","Misc_Com_Bottle_08","misc_com_bottle_09","misc_com_bottle_10","misc_com_bottle_11","misc_com_bottle_13","Misc_Com_Bottle_14","misc_com_bottle_15"}

		for index,item in pairs(Players[pid].data.inventory) do			
			for i, bottle in ipairs(validBottles) do
				if string.match(item.refId,bottle) then										
					return item.refId
				end
			end
		end
		Players[pid]:Message(color.Red.."No empty bottles found in your inventory! \n"..color.Default)
		return false
	end
	
	brewingMod.CheckIngredients = function(pid)
		
		--temp lists
		local ingredientsId = {}
		local validIngredients = {}
		
		--Clear some lists
		validPotions = {}
		validEffects = {}
			
		for index,item in pairs(Players[pid].data.inventory) do
			if string.match(item.refId, "ingred") or string.match(item.refId, "food_kwama_egg") or string.match(item.refId, "poison_goop00") then					
				table.insert(ingredientsId, item.refId)
			end
		end
		
		--Compare ingredients ref ID to alchemy table
		for i,_ in pairs(ingredientsId) do --Iterate ref ID's
			for k,value in pairs(alchemyTable) do --Iterate through alchemytable
				for v,_ in pairs(value) do --Iterate through alchemy table values which are tables						
					if ingredientsId[i] == value[v] then --Inventory ingredient ref ID matches to alchemytable ref ID
						
						--Create a table if empty
						if validIngredients[k] == nil then
							validIngredients[k] = {}
						end
						
						--Dump content into list of valid ingredients by key
						table.insert(validIngredients[k],value[v])
					end
				end
			end
		end

		for key,value in pairs(validIngredients) do
			local count = 0
			for v,_ in pairs(value) do
				count = count + 1
			end
			
			if count > 1 then --Check if there are more than 1 ingredients
				--Store list of valid effects that the player can make potions out of
				validEffects[key] = value
			end
		end
		
		--Compare valid effects to the potion table to determine what potions are possible to make with current resources
		for k,v in pairs(validEffects) do
			for k2,v2 in pairs(potionTable) do
				--Match has been found, store result in the list of valid potions to make
				if k == k2 then					
					--Check that it's possible to make atleast one potion
					local count = 0
					for v3,_ in pairs(v2) do --Count entries in table
						count = count + 1
					end
					
					--There is atleast one possible potion, add a valid potion to the list
					if validPotions[k2] == nil and count > 0 then
						validPotions[k2] = {}
					end
				end
			end
		end
		
		local stringToSend = ""
		validPotionCount = 0
		
		--Prepare a string to be sent
		for k,v in pairs(validPotions) do
			stringToSend = stringToSend .. k .. ";"
			validPotionCount = validPotionCount + 1
		end
		
		stringToSend = stringToSend .. "|                              Cancel                              |;"
		
		GUI.ShowPotionList(pid,stringToSend)	
	end	
	
	brewingMod.PickBrewable = function(pid,data)
		local count = -1
		local ingredientsNeeded = 2
		brewingMod.pickedIngredientsCount = 0
		
		selectedPotionId = tonumber(data)
		
		if tonumber(data) < validPotionCount then
			local stringToSend = ""

			for k,v in pairs(validPotions) do
				count = count + 1
				if count == tonumber(data) then --data matches key
					--Players[pid]:Message(k)
					for k2,v2 in pairs(validEffects) do
						if k2 == k then --Match by key
							tableKey = k
							for i,_ in pairs(v2) do --list all the ingredients that player can use in a potion
								local itemCount = brewingMod.GetRefIdCount(pid,v2[i])
																
								if itemCount ~= nil then 
									stringToSend = stringToSend .. brewingMod.GetNameByRefId(v2[i]) .. " X" .. itemCount
									
									--If ingredient is already selected, add a tag to it
									for e,_ in pairs(brewingMod.pickedIngredients) do 
										if brewingMod.pickedIngredients[e] == i then
											stringToSend = stringToSend .. " [Selected]"
											brewingMod.pickedIngredientsCount = brewingMod.pickedIngredientsCount + 1
										end
									end
									
									stringToSend = stringToSend .. ";"
								else
									brewingMod.pickedIngredients = {}
									brewingMod.CheckIngredients(pid)
									return
								end
							end
						end 
					end
					--Skooma exception, need to have all the ingredients
					if k == "SKOOMA" then
						ingredientsNeeded = 4
					end
				end
			end
						
			if brewingMod.pickedIngredientsCount == ingredientsNeeded then 
				stringToSend = stringToSend .. "Brew a potion;"
			else
				stringToSend = stringToSend .. "Back;"
			end
			
			brewingMod.label = "Choose " .. ingredientsNeeded .. " ingredients to combine:"
			GUI.ShowIngredientList(pid,stringToSend)
		end
	end
		
	brewingMod.PickIngredient = function(pid,data)
		for k,v in pairs(validEffects) do
			if k == tableKey then
				for i,_ in pairs(v) do
					if tonumber(data)+1 == i then 
						--Check if ingredient is already on the list
						for e,_ in pairs(brewingMod.pickedIngredients) do
							if brewingMod.pickedIngredients[e] == i then
								table.remove(brewingMod.pickedIngredients,e) --Remove it
								brewingMod.PickBrewable(pid,selectedPotionId)
								return
							end
						end
						--Ingredient not on the list yet, add it
						table.insert(brewingMod.pickedIngredients,i)
						brewingMod.PickBrewable(pid,selectedPotionId)
						return
					end
				end
			end
		end
		
		if brewingMod.pickedIngredientsCount < 2 then --Back was selected 
			--Clear the list of selected ingredients
			brewingMod.pickedIngredients = {}
			brewingMod.CheckIngredients(pid)
		else --Finally brew the potion with the selected ingredients
			local tempRefIds = {}
			for i,_ in pairs(brewingMod.pickedIngredients) do
				table.insert(tempRefIds,brewingMod.GetRefId(validEffects,tableKey,brewingMod.pickedIngredients[i]))
			end
			
			brewingMod.BrewPotion(pid,tableKey,tempRefIds)
		end
	end
	
	--x=AlchemySkill+0.1(Intelligence)+0.1(Luck) //Formula for determining success
	--Create Potion: +1.0 progression per successful potion
	brewingMod.BrewPotion = function(pid,tableKey,refIdList)
		
		local chosenBottle = brewingMod.CheckBottles(pid)
		--Check for empty bottles
		if chosenBottle == false then
			brewingMod.PickBrewable(pid,selectedPotionId)
			return
		end
		
		--Delete the ingredients
		for i,_ in pairs(refIdList) do
			for index,item in pairs(Players[pid].data.inventory) do
				if string.find(item.refId, refIdList[i],1,true) then
					--Remove the item
					if item.count == 1 then
						Players[pid].data.inventory[index] = nil
					else --Decrement item count
						Players[pid].data.inventory[index] = 
						{  
							refId = item.refId,
							count = item.count-1,
							charge = item.charge
						}
					end
				end
			end
		end
		
		--Roll the dice
		local diceRoll = math.random(0,100)  
		
		local alchemy = tes3mp.GetSkillBase(pid,tes3mp.GetSkillId("Alchemy")) --+ tes3mp.GetSkillCurrent(pid,tes3mp.GetSkillId("Alchemy"))--Players[pid].data.skills["Alchemy"]
		local intelligence = tes3mp.GetAttributeBase(pid,tes3mp.GetAttributeId("Intelligence")) --+ tes3mp.GetAttributeCurrent(pid,tes3mp.GetAttributeId("Intelligence"))--Players[pid].data.attributes["Intelligence"]
		local luck = tes3mp.GetAttributeBase(pid,tes3mp.GetAttributeId("Luck")) --+ tes3mp.GetAttributeCurrent(pid,tes3mp.GetAttributeId("Luck"))--Players[pid].data.attributes["Luck"]
		local spec = tes3mp.GetClassSpecialization(pid)
		local specModifier = 1.0
		
		--Magic specialization
		if spec == 1 then 
			specModifier = 0.8
		end
		
		local alchemyMajorMinor = false
		
		--Get major and minor skills
		for i = 0, 4, 1 do
			if tes3mp.GetSkillName(tonumber(tes3mp.GetClassMajorSkill(pid, i))) == "Alchemy" or tes3mp.GetSkillName(tonumber(tes3mp.GetClassMinorSkill(pid, i))) == "Alchemy" then
				alchemyMajorMinor = true
			end
        end
		
		local apparatusQuality = 0
		local apparatusMessage = color.DarkRed .. "No tools were chosen for this task."
		
		--Find out the best apparatus for the task
		for index,item in pairs(Players[pid].data.inventory) do
			if string.match(item.refId, "apparatus_a") and apparatusQuality <= 0.5 then			
				apparatusQuality = 0.5
				apparatusMessage = color.LightSteelBlue .. "Apprentice level tool was chosen for this task."
			elseif string.match(item.refId, "apparatus_j") and apparatusQuality <= 1.0 then
				apparatusQuality = 1.0
				apparatusMessage = color.LightSeaGreen .. "Journeyman level tool was chosen for this task."
			elseif string.match(item.refId, "apparatus_m") and apparatusQuality <= 1.2 then
				apparatusQuality = 1.2
				apparatusMessage = color.LightYellow .. "Master level tool was chosen for this task."
			elseif string.match(item.refId, "apparatus_g") and apparatusQuality <= 1.5 then
				apparatusQuality = 1.5
				apparatusMessage = color.MistyRose .. "Grandmaster level tool was chosen for this task."
			end
		end
		
		
		local chanceToSucceed = alchemy+(0.1*intelligence)+(0.1*luck) 
		local potionStrength = (chanceToSucceed * apparatusQuality) / 3
		
		--Determine quality of potion
		local qualityId = 0
		for i,_ in pairs(brewingMod.qualityThresholds) do
			if potionStrength >= brewingMod.qualityThresholds[i]  then 
				qualityId=qualityId + 1 
			end
		end
	
		--Compare to potion list to determine the resulting potion
		local potionRefId = ""
		for k,v in pairs(potionTable) do
			if tableKey == k then
				for i,_ in pairs(v) do
					if i == qualityId then 
						potionRefId = v[i]
					end
				end
			end
		end
		
		--Some failure states for the potions
		if potionRefId == "failure" then 
			chanceToSucceed = -1
		end
		
		Players[pid]:Message(apparatusMessage .. "\n" ..color.Default)
		
		if diceRoll <= chanceToSucceed then 
			--Players[pid]:Message(color.Blue.. "Alchemy: " .. alchemy .. " Int: " .. intelligence .. " Luck: " .. luck .. " \n"..color.Default)
			Players[pid]:Message(color.Green.."You have successfully created a potion! \n"..color.Default)
			--Increase skill progression
			if alchemy < 100 then 
				Players[pid].data.skillProgress["Alchemy"]=Players[pid].data.skillProgress["Alchemy"] + 1.0
			end
						
			--Players[pid]:Message(color.LightBlue.. "qId: " .. qualityId .. " Created potion: " .. potionRefId .."\n"..color.Default)
			
			local potionAlreadyExists = false
			
			--Check if item already exists
			for index,item in pairs(Players[pid].data.inventory) do
				if string.match(item.refId, potionRefId) then	
					Players[pid].data.inventory[index] = --Increment potion count
					{  
						refId = item.refId,
						count = item.count+1, 
						charge = item.charge
					}
					potionAlreadyExists = true
				end
				
				--Remove the empty bottle that was tagged for removal earlier
				if string.match(item.refId,chosenBottle) then										
					--Remove the bottle
					if item.count == 1 then
						Players[pid].data.inventory[index] = nil
					else --Decrement bottle count
						Players[pid].data.inventory[index] = 
						{  
							refId = item.refId,
							count = item.count-1,
							charge = item.charge
						}
					end
				end
			end
			
			if potionAlreadyExists == false then 
				--Add created potion to the inventory
				Players[pid].data.inventory[#Players[pid].data.inventory+1] = 
				{ 
					refId = potionRefId, 
					count = 1,
					charge = -1 
				}
			end
		else
			Players[pid]:Message(color.Red.."Potion failed! \n"..color.Default)
			if chanceToSucceed == -1 then --Creation of potion is impossible at this skill level
				Players[pid]:Message(color.DarkRed.."This task seems impossible at your skill level. \n"..color.Default)
			end
		end
		
		--Level up alchemy skill
		if Players[pid].data.skillProgress["Alchemy"] >= alchemy * specModifier then 
			Players[pid].data.attributeSkillIncreases["Intelligence"] = Players[pid].data.attributeSkillIncreases["Intelligence"] + 1
			Players[pid].data.skills["Alchemy"] = Players[pid].data.skills["Alchemy"] + 1
			Players[pid].data.skillProgress["Alchemy"] = 0
			Players[pid]:Message(color.LightGreen.."Your alchemy level increased! \n"..color.Default)	
				
			--Player has a major or minor in alchemy
			if alchemyMajorMinor == true then 
				Players[pid].data.stats["levelProgress"] = Players[pid].data.stats["levelProgress"] + 1
				
				if Players[pid].data.stats["levelProgress"] >= 10 then 
					Players[pid]:Message(color.LightGreen.."You should rest and meditate on what you have learned. \n"..color.Default)
				end
			end
		end
				
		--Save changes to player stats
		Players[pid]:LoadSkills()
		Players[pid]:LoadInventory()
		Players[pid]:LoadEquipment()
		
		brewingMod.PickBrewable(pid,selectedPotionId)
	end
	
	
	
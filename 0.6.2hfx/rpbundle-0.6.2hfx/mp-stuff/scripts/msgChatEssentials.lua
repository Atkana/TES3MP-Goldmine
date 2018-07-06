DO_NOTHING = 1
HIDE_DEFAULT_CHAT = 2
COMMAND_EXECUTED = 3

local registered = {}
local keys = {}
local info = {}

local USES_MESSAGE_EVENT = 1
local USES_COMMAND_EVENT = 2
local USES_INIT = 3

local Methods = {}

Methods.Init = function()
	info = jsonInterface.load("scripts.json")
	
	if info == nil then
		info = {}
	end
	
	local i = 1
	
	for key,_ in pairs(info) do
		
		local b,err = pcall(Methods.RegisterScript, key, i)
		
		if b then
			keys[key] = i
			i = i + 1
			print("Loaded chat script \""..key.."\".")
			if info[key][USES_INIT] == true then
				registered[keys[key]].Init()
			end
		else
			print("Could not load script with the name of \""..key.."\".")
			print(err)
		end
	end
end

Methods.RegisterScript = function(tag, index)
	local s = require (tag)
	registered[index] = s
end

Methods.OnPlayerSendCommand = function(pid, cmd, message)
	for tag,index in pairs(keys) do
		if info[tag][USES_COMMAND_EVENT] == true then
			local result = registered[index].OnPlayerSendCommand(pid, cmd, message)
			if result ~= DO_NOTHING then
				if result == COMMAND_EXECUTED then
					return true
				else
					return false
				end
			end
		end
	end
end

Methods.OnPlayerSendMessage = function(pid, message)
	for tag,index in pairs(keys) do
		if info[tag][USES_MESSAGE_EVENT] == true then
			local result = registered[index].OnPlayerSendMessage(pid, message)
			if result ~= DO_NOTHING then
				if result == HIDE_DEFAULT_CHAT then
					return false
				else
					return true
				end
			end
		end
	end
end

Methods.GetScript = function(tag)
	return registered[keys[tag]]
end

return Methods
Methods = {}

-- In scripts.json you set the first boolean to true if you are using OnPlayerSendMessage and if you are also using OnPlayerSendCommand then set the second boolean to true.

Methods.OnPlayerSendCommand = function(pid, cmd, message)
	if cmd[1] == "hello" then
		tes3mp.SendMessage(pid, "Hello World!", false)
		return COMMAND_EXECUTED
	end
	
	return DO_NOTHING
end

return Methods
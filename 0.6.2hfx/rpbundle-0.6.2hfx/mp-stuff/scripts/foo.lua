Methods = {}

-- In scripts.json you set the first boolean to true if you are using OnPlayerSendMessage and if you are also using OnPlayerSendCommand then set the second boolean to true.

Methods.OnPlayerSendMessage = function(pid, message)

	print("Player "..pid.." sent a message!")

	return DO_NOTHING -- We dont want to return a value because it would stop other scripts from being able to run. Scripts that use returns to show/hide chat should be at the top of the scripts.json
	
end

return Methods
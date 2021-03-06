Methods = {}


-- Add [ disableAssassins = require("disableAssassins") ] to the top of server.lua
-- Find "OnObjectSpawn" inside server.lua then put [ disableAssassins.OnObjectSpawn(pid, cellDescription) ] at the end


Methods.OnObjectSpawn = function(pid, cellDescription)

    tes3mp.ReadLastEvent() -- Server doesnt save objects to memory so we only get access to the current packet sent which was "OnObjectSpawn"

    local found = 0
    local Assassins = {}

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do -- Loop through all objects sent in packet
        local refId = tes3mp.GetObjectRefId(i)
        if string.match(refId, "db_assassin") ~= nil then
            local isObjectAssassin = true
            Assassins[found] = tes3mp.GetObjectMpNum(i) -- This is how we get the MP num for actors
            found = found + 1
        end
    end

    if found > 0 then
        for i,p in pairs(Players) do -- Do this for each player online
            for index,a in pairs(Assassins) do -- Sometimes more than one assassin spawns
                tes3mp.InitializeEvent(p.pid)
                tes3mp.SetEventCell(cellDescription)
                tes3mp.SetObjectRefNumIndex(0)
                tes3mp.SetObjectMpNum(a) 
                tes3mp.AddWorldObject() -- Add actor to packet
                tes3mp.SendObjectDelete() -- Send Delete

                if LoadedCells[cellDescription] ~= nil then

                    local refIndex = "0-" .. a
                    LoadedCells[cellDescription].data.objectData[refIndex] = nil
                    tableHelper.removeValue(LoadedCells[cellDescription].data.packets.spawn, refIndex)
                    tableHelper.removeValue(LoadedCells[cellDescription].data.packets.actorList, refIndex)
                    LoadedCells[cellDescription]:Save()
                end
            end
        end
    end

end

return Methods
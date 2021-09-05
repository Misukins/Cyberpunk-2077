Locator = {
	name = "Locator",
	description = "get your current location.",
	author = "Misukins",
	version = "1.0",
	rootPath = "Misu - Locator"
}

function Locator:new()

    registerHotkey("locator_hotkey", "Print location", function()
		Locator:PrintmyLocation()
	end)

    return Locator
end

function Locator:PrintmyLocation()
    
	local player = Game.GetPlayer()
	local pos = player:GetWorldPosition()
	print("[Misu - Locator] Current position: X =", pos.x, "Y =", pos.y, "Z =", pos.z)

end

return Locator:new()
--[[ 
	[Death Alternative]
	Version: 2.2.0
	Orig Creator: 3nvy
	Edit: Amy (Misukins) 
	Date: August+++
--]]

local DeathAlternative = {
	title = "Death Alternative",
	description = "Death Alternative",
	version = "2.2",
	creator = "3nvy",
	editby = "Misukins"
}
local showSettings = false
local useOldFeatures = false
local TPtoVApartment = false

-- !TODO
-- tp medical center near you-- just like in gta5 :P
-- when ever i find every hospital in game

local userSettingsFile = "config/settings.AltD.json"
local IProps = {
	deltaTime = 0,
	timeLoaded = 0,
	activePackage = nil,
	drawSetupMenu = false,
	canPayRevive = false,
	canDrawDeathScreen = false,
	canDrawBuyLifePackScreen = false,
	hospitalCoords = {
		{ x = -1337.394,  y = 1745.6206 },
		{ x = -1331.4171, y = 1745.0977 },
		{ x = -1361.3032, y = 1747.7123 },
		{ x = -1367.2804, y = 1748.2352 },
	},
}

local ripperDocsSpawnTable = { -- RipperDocs
	[1] =  { -346.79602,    221.25322,    27.59404  },
	[2] =  { -1090.759155,  2147.218262,  13.330742 },
	[3] =  { -1686.586182,  2386.400879,  18.344055 },
	[4] =  { -712.370605,   871.832458,   11.982414 },
	[5] =  { -1245.325439,  1945.930908,   8.030479 },
	[6] =  { -573.507813,   795.048279,   24.906097 },
	[7] =  { -1040.245972,  1440.913696,   0.500221 },
	[8] =  { -40.347633,   -52.439484,     7.179688 },
	[9] =  {  3438.949463, -380.475800,  133.569855 },
	[10] = {  1814.132202,  2274.446289, 182.176987 },
	[11] = {  588.132568,  -2179.594482,  42.437347 },
	[12] = { -2361.011475, -929.024597,   12.266129 },
	[13] = { -2411.207764,  393.523010,   11.837067 },
	[14] = { -1546.726196,  1227.393066,  11.520233 },
	[15] = { -705.582397,  -395.248322,    8.199997 },
	[16] = { -2607.956787, -2498.076660,  17.334549 },
	[17] = { -1072.172729, -1274.062866,  11.456871 },
}

local CPS = require("config/CPStyling")
local Utils = require("config/utilities")
local heme = CPS.theme
local color = CPS.color
local Config = {
	lifePackages = {
		{ name = "Platinum", time = 1, healthRegen = 100, price = 50000 },
		{ name = "Gold", time = 3, healthRegen = 50, price = 25000 },
		{ name = "Silver", time = 5, healthRegen = 25, price = 10000 },
	}
}

function hasGodMode(player)
	return Game.GetGodModeSystem():HasGodMode(player:GetEntityID(), "Immortal")
end

function enableGodMod(player)
	gms:EnableOverride(player:GetEntityID(), "Immortal", CName.new("SecondHeart"))
end

function disableGodMod(player)
	gms:DisableOverride(player:GetEntityID(), CName.new("SecondHeart"))
end

function revivePlayer(player)
	local player = Game.GetPlayer()
	if player and IProps.canDrawDeathScreen then
		local lpDetails = Config.lifePackages[IProps.activePackage]
		local x,y,z = unpack(ripperDocsSpawnTable[math.random(1,#ripperDocsSpawnTable)])
		Game.Heal(lpDetails.healthRegen)
		ts:RemoveItem(player, myMoney, lpDetails.price)
		if (useOldFeatures == false) and (TPtoVApartment == false) then
			Game.TeleportPlayerToPosition(x, y, z) --ripperdocs random
		elseif (useOldFeatures == false) and (TPtoVApartment == true) then
			Game.TeleportPlayerToPosition(-1380.580566, 1271.436035, 123.064896) --V's Apartment
		else
			Game.TeleportPlayerToPosition(-372.268982, 271.240143, 215.515579) --(old location / room ((you need to add shortcut to exit!)))
		end
		Game.GetPlayer():SetWarningMessage("Player Revived")
		Game.SetTimeDilation(0)
		IProps.canDrawDeathScreen = false
	end
end

function cancelRevive(player)
	local player = Game.GetPlayer()
	if player and IProps.canDrawDeathScreen then
		qs:SetFactStr("activeHealthPack", 0)
		IProps.activePackage = nil
		disableGodMod(player)
		player:Kill()
		Game.SetTimeDilation(0)
		IProps.canDrawDeathScreen = false
	end
end

function lowHealthThresholdReached(player)
	local player = Game.GetPlayer()
	local isInVehicle = Game['GetMountedVehicle;GameObject'](Game.GetPlayer())
	if not isInVehicle and IProps.activePackage > 0 then
		local playerMoney = ts:GetItemQuantity(player, myMoney)
		local packageValue = Config.lifePackages[IProps.activePackage].price
		if playerMoney < packageValue then
			IProps.canPayRevive = false
		else
			IProps.canPayRevive = true
		end
		IProps.canDrawDeathScreen = true
		Game.SetTimeDilation(0.00001)
	else
		IProps.canDrawDeathScreen = true
		cancelRevive(player)
	end
end

function checkActiveLifePack()
	IProps.activePackage = qs:GetFactStr("activeHealthPack")
end

function playerIsInDistance(coordsList, maxDistance)
	local player = Game.GetPlayer()
	if player then
		local pLoc = player:GetWorldPosition()
		for _, coords in pairs(coordsList) do 
			local dx = coords.x - pLoc.x
			local dy = coords.y - pLoc.y
			local distance = math.sqrt( dx * dx + dy * dy )
			if distance <= maxDistance then
				return true
			end
		end
	end
	return false
end

function runUpdates(player)
	local player = Game.GetPlayer()
	if not player then
		return
	end
	checkActiveLifePack()
	if not hasGodMode(player) then
		enableGodMod(player)
	end
	playerHealth = ss:GetStatPoolValue(playerID, 'Health', true)
	if playerHealth == 1 then 
		lowHealthThresholdReached(player, IProps.activePackage) 
	end
	if (useOldFeatures == true) then
		if playerIsInDistance(IProps.hospitalCoords, 3) then
			IProps.canDrawBuyLifePackScreen = true
		else
			IProps.canDrawBuyLifePackScreen = false
		end
	end
end

function drawDeathScreen()
	if IProps.canDrawDeathScreen then 
		local lp = Config.lifePackages[IProps.activePackage]
		CPS.setThemeBegin()
		CPS.colorBegin("WindowBg", {0,0,0,1})
		ImGui.SetNextWindowSize(wWidth, wHeight)
		ImGui.Begin("DeathScreen", true, ImGuiWindowFlags.NoResize + ImGuiWindowFlags.AlwaysAutoResize + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoMove + ImGuiWindowFlags.NoBringToFrontOnFocus)
		ImGui.SetWindowPos(0,0)
		ImGui.End()
		ImGui.SetNextWindowSize(240, 220)
		ImGui.Begin("PopUp", true, ImGuiWindowFlags.NoResize + ImGuiWindowFlags.AlwaysAutoResize + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoMove)
		ImGui.SetWindowPos(wWidth / 2 - 120, wHeight / 2 - 110)
		ImGui.Spacing()
		ImGui.SameLine(95)
		ImGui.Text("You Died")
		ImGui.Spacing()
		ImGui.Separator()
		ImGui.Spacing()
		ImGui.Spacing()
		ImGui.Text("Your Current Pack: "..lp.name)
		ImGui.Spacing()
		ImGui.Spacing()
		ImGui.Separator()
		ImGui.Spacing()
		ImGui.Spacing()
		if IProps.canPayRevive then
			ImGui.Text("Revive Time: "..lp.time.." day(s)")
			ImGui.Spacing()
			ImGui.Spacing()
			ImGui.Text("Health Regenerated: "..lp.healthRegen.."%%")
			ImGui.Spacing()
			ImGui.Spacing()
			ImGui.Text("Revive Price: "..lp.price.." eddies")
		else
			ImGui.Text("You don't have enouth money")
			ImGui.Text("in you bank account to revive.")
			ImGui.Spacing()
			ImGui.Spacing()
			ImGui.Text("Trauma team has canceled your")
			ImGui.Text("insurance and wont be coming.")
		end
		ImGui.Spacing()
		ImGui.Spacing()
		ImGui.Separator()
		ImGui.Spacing()
		ImGui.Spacing()
		ImGui.Spacing()
		if IProps.canPayRevive then
			revivePressed = CPS.CPButton("Revive", 100, 30)
			if revivePressed then
				revivePlayer()
			end
		end
		ImGui.SameLine(130)
		dieAndReload = CPS.CPButton("Die & Reload", 100, 30)
		if dieAndReload then
			cancelRevive()
		end
		ImGui.End()
		CPS.colorEnd(1)
		CPS.setThemeEnd()
	end
end

function drawActiveLifePackage()
	CPS.setThemeBegin()
	CPS.colorBegin("WindowBg", {0,0,0,0.5})
	ImGui.SetNextWindowSize(190, 10)
	if ImGui.Begin("ActiveLifePack", true, ImGuiWindowFlags.NoResize + ImGuiWindowFlags.NoMove + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoScrollbar) then
		ImGui.SetWindowPos(wWidth - 270, 328)
		if IProps.activePackage then
			ImGui.Text("Life Insurance: "..IProps.activePackage)
		else
			ImGui.Text("Life Insurance: None")
		end
	end
	ImGui.End()
	CPS.colorEnd(1)
	CPS.setThemeEnd()
end

function buyPackage(packageID, packageName)
	local qs = Game.GetQuestsSystem()
	IProps.activePackage = packageID
	qs:SetFactStr("activeHealthPack", packageID)
	Game.GetPlayer():SetWarningMessage(packageName.." Insurance Package Activated")
end

function drawBuyLifePack()
	if IProps.canDrawBuyLifePackScreen then
		CPS.setThemeBegin()
		CPS.colorBegin("WindowBg", {0,0,0,1})
		ImGui.SetNextWindowSize(240, 472)
		if ImGui.Begin("BuyLifePack", true, ImGuiWindowFlags.NoResize + ImGuiWindowFlags.AlwaysAutoResize + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoMove) then
			ImGui.SetWindowPos(wWidth / 2 - 120, wHeight / 2 + 30)
			ImGui.Spacing()
			ImGui.SameLine(70)
			ImGui.Text("Trauma Team HQ")
			ImGui.Spacing()
			for packageID, packDetails in pairs(Config.lifePackages) do 
				ImGui.Separator()
				ImGui.Spacing()
				ImGui.Spacing()
				if packDetails.name == "Gold" then
					CPS.colorBegin("Text", color.yellow)
				elseif packDetails.name == "Silver" then
					CPS.colorBegin("Text", color.silver)
				elseif packDetails.name == "Platinum" then
					CPS.colorBegin("Text", color.cyan)
				else
					CPS.colorBegin("Text", color.red)
				end
				ImGui.Text(packDetails.name.." Insurance Package")
				CPS.colorEnd(1)
				ImGui.Spacing()
				ImGui.Spacing()
				ImGui.Text("Treatment Time: "..packDetails.time.." day(s)")
				ImGui.Spacing()
				ImGui.Text("Health Regenerated: "..packDetails.healthRegen.."%%")
				ImGui.Spacing()
				ImGui.Text("Revive Cost: "..packDetails.price.." eddies")
				ImGui.Spacing()
				ImGui.Spacing()
				if IProps.activePackage > 0 and packDetails.name == Config.lifePackages[IProps.activePackage].name then
					CPS.CPButton("Already Owned", 222, 30)
				else
					local buy = CPS.CPButton("Activate "..packDetails.name.." Package", 222, 30)
					if buy then
						buyPackage(packageID, packDetails.name)
					end
				end
				ImGui.Spacing()
				ImGui.Spacing()
			end
		end
		ImGui.End()
		CPS.colorEnd(1)
		CPS.setThemeEnd()
	end
end

registerForEvent("onInit", function()
	player = Game.GetPlayerSystem():GetLocalPlayerMainGameObject()
	ts = Game.GetTransactionSystem()
	qs = Game.GetQuestsSystem()
	gms = Game.GetGodModeSystem()
	playerID = player:GetEntityID()
	ss = Game.GetStatPoolsSystem()
	wWidth, wHeight = GetDisplayResolution()
	myMoney = GetSingleton("gameItemID"):FromTDBID(TweakDBID.new("Items.money"))
	load_settings(userSettingsFile)
	print("[Death Alternative] Initialized | Version: 1.0.0 - Orig Creator: 3nvy | Edit by Amy")
end)

registerForEvent("onOverlayOpen", function()
	showSettings = true
	if(useOldFeatures == false) then
		IProps.canDrawBuyLifePackScreen = true
	end
end)

registerForEvent("onOverlayClose", function()
	showSettings = false
	IProps.canDrawBuyLifePackScreen = false
end)

registerForEvent("onUpdate", function(deltaTime)
	IProps.deltaTime = IProps.deltaTime + deltaTime
	if IProps.deltaTime > 1 then
		runUpdates()
        IProps.deltaTime = IProps.deltaTime - 1
    end
end)

registerHotkey("exit_hotel", "Exit Hotel", function()
	local coords = {{x = -364.96457, y = 267.6644}}
	local canTeleport = playerIsInDistance(coords, 3)
	if canTeleport then
		Game.TeleportPlayerToPosition(-346.79602, 221.25322, 27.59404)
	end
end)

registerForEvent("onDraw", function()
	if (showSettings) then
		ImGui.Begin(DeathAlternative.title .. " Version " .. tostring(DeathAlternative.version) .. ".")
		ImGui.Text("Original Creator: " .. tostring(DeathAlternative.creator) .. ".")
		ImGui.Text("Continued by: " .. tostring(DeathAlternative.editby) .. ".")
		ImGui.Separator()
		ImGui.Text("Use old features:")
		ImGui.Text("This will use original locations for everything,")
		ImGui.Text("not modded by me just 1.3fix.")
		ImGui.Text("!! Remember set hotkey to exit hotel room! !!")
		ImGui.Text(" ")

		state, pressed = ImGui.Checkbox("Use old features", useOldFeatures)
		if pressed then 
			useOldFeatures = state
		end

		ImGui.Separator()

		state, pressed = ImGui.Checkbox("Teleport to V's Apartment", TPtoVApartment)
		if pressed then 
			TPtoVApartment = state
		end

		ImGui.Separator()

		ImGui.Text("Life Packs:")
		ImGui.Text("this is just for me.. im just lazy tp go there... everytime")
		ImGui.Text("Will be removed")
		if ImGui.Button("Teleport to Drama Team HQ") then
			Game.TeleportPlayerToPosition(-1361.7752685547, 1741.9836425781, 18.190002441406)
		end

		ImGui.Separator()

		if ImGui.Button("Save settings") then
			save_settings(userSettingsFile)
		end

		ImGui.SameLine()

		if ImGui.Button("Load settings") then
			load_settings(userSettingsFile)
		end

		ImGui.End()
	end

	drawDeathScreen()
	drawBuyLifePack()
end)

function save_settings(filename)
	data = {
		useOldFeatures = useOldFeatures,
		TPtoVApartment = TPtoVApartment,
	}
	local file = io.open(filename, "w")
	local j = json.encode(data)
	file:write(j)
	file:close()
	print("Death Alternative: settings saved to " .. filename)
	return true
end

function load_settings(filename)

	if not file_exists(filename) then
		print("Vs Pro Cyberpsycho: loading settings from " .. filename .. " failed, file didnt exist?")
		return false
	end

	local file = io.open(filename,"r")
	local j = json.decode(file:read("*a"))
	file:close()

	useOldFeatures = j["useOldFeatures"]
	TPtoVApartment = j["TPtoVApartment"]

	print("Death Alternative: loaded settings from " .. filename)
	return true

end

function file_exists(filename) -- https://stackoverflow.com/a/4991602
    local f=io.open(filename,"r")
    if f~=nil then io.close(f) return true else return false end
end
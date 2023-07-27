--NTB (CLIENT) by Dudekahedron, 2022

local M = {}

local logTag = "NTB"
local gui_module = require("ge/extensions/editor/api/gui")
local gui = {setupEditorGuiTheme = nop}
local im = ui_imgui
local windowOpen = im.BoolPtr(true)
local ffi = require('ffi')

local players = {}
local playersPerms = {}

local playersVehiclesTab = {}

function window()
	if windowOpen[0] then
		windowOpen = im.BoolPtr(false)
	else
		windowOpen = im.BoolPtr(true)
	end
end


function getPlayers(data)
	if data then
		players = jsonDecode(data)
	end

end

function playersVehicles(data)
	-- if data then
	-- 	playersVehiclesTab = jsonDecode(data)
	-- end
end

		-- todo Régler les bugs quand il y'a plusieurs joueurs

function playersPermissions(data)
	if data then
		playersPerms = jsonDecode(data)
	end
end




local inputText = ffi.new("char[?]", 100) -- Allocate memory for the C-style string
local windowInstance = {}
local timeElements =  {s = "seconds", m = "minutes", h = "hours", d = "days"}
local selectedKey = "s"	--Value who will be send to the server when confirmed
local intNumber = ffi.new("int[?]", 100) -- Allocate memory for the C-style int

local currentWindowState = {
    playerName = "",
    command = "",
    timeInput = false,
	windowSize = im.ImVec2(400, 120), -- Taille par défaut de la fenêtre
    windowPos = im.ImVec2(0, 0) -- Position par défaut de la fenêtre
}

local function askWindow(playerName, command, timeInput)

	if currentWindowState.playerName ~= playerName or currentWindowState.command ~= command or currentWindowState.timeInput ~= timeInput then
        -- Mettre à jour l'état actuel de la fenêtre
        currentWindowState.playerName = playerName
        currentWindowState.command = command
        currentWindowState.timeInput = timeInput



        -- Configurer la taille et la position de la fenêtre de demande
        im.SetNextWindowSize(currentWindowState.windowSize, im.ImGuiCond_FirstUseEver)
        im.SetNextWindowPos(currentWindowState.windowPos, im.ImGuiCond_FirstUseEver)
    end


		gui.setupWindow("ASK")
		im.Begin(command .. " " .. playerName)


		if not im.IsWindowAppearing() and not im.IsWindowCollapsed() then
			currentWindowState.windowPos = im.GetWindowPos()
			currentWindowState.windowSize = im.GetWindowSize()
		end

		local listIndex = 1
		local finalvalue = {name = playerName, cmd = command, timebool = timeInput}
		for k,v in pairs(windowInstance) do
			if windowInstance[k] ~= nil then
				listIndex = k
				windowInstance[k] = finalvalue
			end
		end
		if #windowInstance == 0 then
			table.insert(windowInstance, finalvalue)
		end
		--test

		if im.InputTextWithHint("Reason", "Enter reasons here", inputText, ffi.sizeof(inputText)) then
			
		end

		if timeInput then
			im.PushItemWidth(100)

			im.Text("During")

			im.SameLine()
			if im.InputInt("", intNumber, 1) then
				if intNumber[0] < 0 then
					intNumber[0] = 0
				end
			end

			im.SameLine()

			if im.BeginCombo("\u{00A0}", timeElements[selectedKey]) then --invisible char in label because if its an empty string its not working
				for key, value in pairs(timeElements) do
					local isSelected = (key == selectedKey)
					if im.Selectable1(value, isSelected) then
						selectedKey = key
					end
		
					if isSelected then
						im.SetItemDefaultFocus()
					end
				end
				im.EndCombo()
			end
		end
		local userInputInt = intNumber[0]
		local userInputString = ffi.string(inputText)
		if im.SmallButton("Confirm") then
			if not timeInput then
				TriggerServerEvent("interfaceCommand", command .. " " .. playerName .. " " .. userInputString)
			else
				TriggerServerEvent("interfaceCommand", command .. " " .. playerName .. " " .. userInputInt .. selectedKey .. " " .. userInputString)
			end
			table.remove(windowInstance, listIndex)
		end
		im.SameLine()
		if im.SmallButton("Cancel") then
			table.remove(windowInstance, listIndex)
		end
	im.End()

	-- im.PopFont()
end



local function mainWindow()
	gui.setupWindow("N.I")

	im.PushStyleColor2(im.Col_Border, im.ImVec4(0.2, 0.2, 0.2, 1.0))
	im.PushStyleColor2(im.Col_ResizeGrip, im.ImVec4(0.15, 0.15, 0.15, 1.0))
	im.PushStyleColor2(im.Col_ResizeGripHovered, im.ImVec4(0.18, 0.18, 0.18, 1.0))
	im.PushStyleColor2(im.Col_ResizeGripActive, im.ImVec4(0.2, 0.2, 0.2, 1.0))
	im.PushStyleColor2(im.Col_TitleBg, im.ImVec4(0.25, 0.25, 0.25, 1.0))
	im.PushStyleColor2(im.Col_TitleBgActive, im.ImVec4(0.18, 0.18, 0.18, 1.0))
	im.PushStyleColor2(im.Col_TitleBgCollapsed, im.ImVec4(0.1, 0.1, 0.1, 1.0))
	im.PushStyleColor2(im.Col_Tab, im.ImVec4(0.2, 0.2, 0.2, 1))
	im.PushStyleColor2(im.Col_TabHovered, im.ImVec4(0.2, 0.2, 0.2, 0.7))
	im.PushStyleColor2(im.Col_TabActive, im.ImVec4(0.15, 0.15, 0.15, 1.0))
	im.PushStyleColor2(im.Col_FrameBg, im.ImVec4(0.2, 0.2, 0.2, 0.8))
	im.PushStyleColor2(im.Col_FrameBgHovered, im.ImVec4(0.4, 0.4, 0.4, 0.5))
	im.PushStyleColor2(im.Col_FrameBgActive, im.ImVec4(0.2, 0.2, 0.2, 0.9))
	im.PushStyleColor2(im.Col_Header, im.ImVec4(0.2, 0.2, 0.2, 1.0))
	im.PushStyleColor2(im.Col_HeaderHovered, im.ImVec4(0.25, 0.25, 0.25, 1.0))
	im.PushStyleColor2(im.Col_HeaderActive, im.ImVec4(0.3, 0.3, 0.3, 1.0))
	im.PushStyleColor2(im.Col_Separator, im.ImVec4(0.25, 0.25, 0.25, 0.75))
	im.PushStyleColor2(im.Col_SeparatorHovered, im.ImVec4(0.3, 0.3, 0.3, 0.75))
	im.PushStyleColor2(im.Col_SeparatorActive, im.ImVec4(0.35, 0.35, 0.35, 0.5))
	im.PushStyleColor2(im.Col_Button, im.ImVec4(0.1, 0.1, 0.1, 1.0))
	im.PushStyleColor2(im.Col_ButtonHovered, im.ImVec4(0.3, 0.3, 0.3, 1.0))
	im.PushStyleColor2(im.Col_ButtonActive, im.ImVec4(0.2, 0.2, 0.2, 1.0))
	
	-- Changer l'alpha de la couleur de fond de la fenêtre	
	im.SetNextWindowBgAlpha(0.777)
	im.Begin("Nickel Interface")

	if im.BeginTabBar("Tab") then
        if im.BeginTabItem("Players") then
            -- Contenu de l'onglet 1
			-- local players = MPVehicleGE.getPlayers()

			--playerlist data

			for key, value in pairs(players) do
				if im.CollapsingHeader1("[" .. key .. "] " .. value.name) then
					-- Contenu déroulant (options) ici
					im.NewLine()

					if playersPerms.banip then
						im.SameLine()
						if im.SmallButton("Banip##" .. key) then
							askWindow(value.name, "banip", false)
						end
					end

					if playersPerms.ban then
						im.SameLine()
						if im.SmallButton("Ban##" .. key) then
							askWindow(value.name, "ban", false)
						end
					end
					
					if playersPerms.tempban then
						im.SameLine()
						if im.SmallButton("Tempban##" .. key) then
							askWindow(value.name, "tempban", true)
						end
					end
				
					if playersPerms.kick then
						im.SameLine()
						if im.SmallButton("Kick##" .. key) then
							TriggerServerEvent("interfaceCommand", "kick " .. value.name)
						end
					end
					
					if playersPerms.votekick then
						im.SameLine()
						if im.SmallButton("Votekick##" .. key) then
							TriggerServerEvent("interfaceCommand", "votekick " .. value.name)
						end
					end
					
					if playersPerms.mute then
						im.SameLine()
						if im.SmallButton("Mute##" .. key) then
							askWindow(value.name, "mute", false)
						end
					end
				
					if playersPerms.tempmute then
						im.SameLine()
						if im.SmallButton("Tempmute##" .. key) then
							askWindow(value.name, "tempmute", true)
						end
					end


					--vehicle list

				end
			end

            im.EndTabItem()
        end
        if im.BeginTabItem("Tab2") then
            -- Contenu de l'onglet 2
            im.Text("Coming soon")
            im.EndTabItem()
        end
        -- Ajoutez d'autres onglets ici si nécessaire
        im.EndTabBar()
    end
	im.End()
end

local function onUpdate(dt)
	if worldReadyState == 2 then
		if windowOpen[0] == true then
			mainWindow()
		end
	end
    for key, value in pairs(windowInstance) do
        askWindow(value.name, value.cmd, value.timebool)
    end
end

local function onPreRender(dt)

end

local function onExtensionLoaded()
	gui_module.initialize(gui)
	gui.registerWindow("N.I", im.ImVec2(100, 300))
	gui.showWindow("N.I")
	log('W', logTag, "Nickel interface LOADED")
	if AddEventHandler then AddEventHandler("getPlayers", getPlayers) AddEventHandler("playersPermissions", playersPermissions) AddEventHandler("playersVehicles", playersVehicles) AddEventHandler("window", window) end --Event called serverside by the Nickel plugin
end

local function onExtensionUnloaded()
	log('W', logTag, "Nickel interface UNLOADED")
end

M.dependencies = {"ui_imgui"}

M.onUpdate = onUpdate
M.onPreRender = onPreRender

M.onWorldReadyState = onWorldReadyState

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

return M

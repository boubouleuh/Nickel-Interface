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






function getPlayers(data)
	players = jsonDecode(data)
end



function playersPermissions(data)
	playersPerms = jsonDecode(data)
end



local function drawNTB()
	gui.setupWindow("N.I")
	im.Begin("Nickel Interface")


	if im.BeginTabBar("Tab") then
        if im.BeginTabItem("Tab1") then
            -- Contenu de l'onglet 1
			-- local players = MPVehicleGE.getPlayers()
			local inputTextBuffer = ""

			--playerlist data
			for i = 1, #players do
				if im.CollapsingHeader1(players[i].name) then
					-- Contenu déroulant (options) ici


					if playersPerms.ban then
						if im.SmallButton("Ban") then
							TriggerServerEvent("interfaceCommand", "ban " .. players[i].name .. inputTextBuffer)
						end
					end
					if playersPerms.tempban then
						if im.SmallButton("Tempban") then

							TriggerServerEvent("interfaceCommand", "tempban " .. players[i].name .. inputTextBuffer)
						end
					end
					im.SameLine()
					if playersPerms.kick then
						if im.SmallButton("Kick") then
							TriggerServerEvent("interfaceCommand", "kick " .. players[i].name)
						end
					end
					im.SameLine()
					if playersPerms.votekick then
						if im.SmallButton("Votekick") then
							TriggerServerEvent("interfaceCommand", "votekick " .. players[i].name)
						end
					end
					im.SameLine()
					if playersPerms.mute then
						if im.SmallButton("Mute") then
							TriggerServerEvent("interfaceCommand", "mute " .. players[i].name .. inputTextBuffer)
						end
					end
					im.SameLine()
					if playersPerms.tempmute then
						if im.SmallButton("Tempmute") then
							TriggerServerEvent("interfaceCommand", "tempmute " .. players[i].name .. inputTextBuffer)
						end
					end
					local c_str = ffi.new("char[?]", #inputTextBuffer + 1)
					ffi.copy(c_str, inputTextBuffer)

					if im.InputTextWithHint("Reason", "Enter reasons here", c_str, 128) then
					end
				end
			end

            im.EndTabItem()
        end
        if im.BeginTabItem("Tab2") then
            -- Contenu de l'onglet 2
            im.Text("Content 2")
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
			drawNTB()
		end
	end
end

local function onPreRender(dt)

end

local function onExtensionLoaded()
	gui_module.initialize(gui)
	gui.registerWindow("N.I", im.ImVec2(100, 56))
	gui.showWindow("N.I")
	log('W', logTag, "Nickel interface LOADED")
	if AddEventHandler then AddEventHandler("getPlayers", getPlayers) AddEventHandler("playersPermissions", playersPermissions) end --Event called serverside by the Nickel plugin
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

local M = {}


local initialized = false
local roles = {}
local playerlist = {}
local searchPlayerlist = {}
local isSearching = false

local serverinfos = {}
local self_action_perm = {}
local time = require("ge.extensions.beamng.time")
local usercommands = {}
local globalcommands = {}
local interfaceValues = {}
local bypassNametagsBool = false
local jsinitiated = false
local applied_environment = {}
local environment = {
    temperature = 0,
    time = {0, 0},
    gravity = 0,
    wind = 0,
    meteo = ""
}
local lastEnvironment = {
    temperature = 0,
    time = {0, 0},
    gravity = 0,
    wind = 0,
    meteo = ""
}

local weatherPresets


local function resetSearch()
    searchPlayerlist = {}
end



local function updateEnvironment(newEnv)
    local hasChanged = false
    
    for key, value in pairs(newEnv) do
        if not deepCompare(lastEnvironment[key], value) then
            environment[key] = deepCopy(value)
            lastEnvironment[key] = deepCopy(value)
            hasChanged = true

        end
    end
    
    if hasChanged then
        TriggerServerEvent("SyncEnvironment", jsonEncode(environment))
    end 
end




function deepCompare(t1, t2, visited)
  if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return t1 == t2 end

    -- Vérifier les métatables
    if getmetatable(t1) ~= getmetatable(t2) then return false end

    -- Détecter les cycles
    visited = visited or {}
    if visited[t1] and visited[t1] == t2 then return true end
    visited[t1] = t2

    -- Vérifier les tailles des tables
    local function tableLength(t)
        local count = 0
        for _ in pairs(t) do
            count = count + 1
        end
        return count
    end

    if tableLength(t1) ~= tableLength(t2) then return false end

    -- Comparer les clés et les valeurs
    for k, v in pairs(t1) do
        if not deepCompare(v, t2[k], visited) then return false end
    end

    for k, v in pairs(t2) do
        if t1[k] == nil then return false end
    end

    return true
end

function deepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[k] = deepCopy(v)
        end
    else
        copy = orig
    end
    return copy
end

function setTemp(temp)
    environment.temperature = temp
    updateEnvironment(environment)
end

function setTime(hours, minutes)
    environment.time = {hours, minutes}
    updateEnvironment(environment)
end

function setGravity(grav)
    environment.gravity = grav
    updateEnvironment(environment)

end

function setWind(x, y, z)
    environment.wind = x
    updateEnvironment(environment)
   --[[  updateEnvironment({wind = {x, y, z}}) ]]
end

function setMeteo(meteo)
    environment.meteo = meteo
    updateEnvironment(environment)
end

function getTemp()
    return environment.temperature
end

function getTime()
    return time.getTimeOfDay()
end

function getGravity()
    return environment.gravity
end

function getWind()
    return environment.wind
end

function getMeteo()
    return environment.meteo
end

function clientSyncEnvironment()
    applied_environment = deepCopy(environment)
    core_weather.activate(environment.meteo)
    scenetree.TheLevelInfo:setTemperatureCurveC({{0, environment.temperature}, {1, environment.temperature},{0, 0}, {0, 0}, {0, 0}})
    time.setTimeOfDay(environment.time[1] .. ":" .. environment.time[2])
    core_environment.setGravity(environment.gravity)
    be:queueAllObjectLua("obj:setWind(0,".. environment.wind..",0)")
    core_environment.requestState()
    core_environment.onInit()


end



local function receiveEnvironment(newEnv)
    newEnv = jsonDecode(newEnv)
    if deepCompare(newEnv, applied_environment) then
        log('D', "Nickel", "Environment already applied, skipping update")
        return
    end
    environment = newEnv

    clientSyncEnvironment()
    guihooks.trigger('SyncEnvironment', environment)

end



local function onExtensionLoaded()
    log('D', "Nickel", "Loaded")
end

local function onExtensionUnloaded()
    log('D', "Nickel", "Unloaded")
end




-- Fonction pour convertir une valeur temporelle en hh:mm
function formatTimeOfDay(value)
    -- Étape 1: Multipliez par 24 pour obtenir les heures fractionnaires
    local total_hours = value.time * 24

    -- Étape 2: Ajoutez 12 heures pour que 0.0 corresponde à midi
    total_hours = total_hours + 12
    if total_hours >= 24 then
        total_hours = total_hours - 24
    end

    -- Séparez les heures et les minutes
    local hours = math.floor(total_hours)
    local minutes_fraction = total_hours - hours

    -- Convertissez les minutes fractionnaires en minutes entières
    local minutes = math.floor(minutes_fraction * 60)

    -- Formatez le résultat en hh:mm
    local formatted_time = {hours, minutes}

    return formatted_time
end

local function initializeInterface(offset)
    isSearching = false
    searchPlayerlist = {}
    if not initialized then
        log('D', "Nickel", "Initialized interface via AngularJS")
        log('D', "Nickel", "Offset is " .. offset)
        TriggerServerEvent("initInterface", offset)
        initialized = true
    end
    guihooks.trigger('SyncWeatherPresets', core_weather.getPresets())
    guihooks.trigger('SyncEnvironment', environment)
    guihooks.trigger("NKgetServerValues", serverinfos)
    guihooks.trigger("NKgetUserValues", self_action_perm)
    guihooks.trigger("getPlayers", playerlist)
    guihooks.trigger("getRoles", roles)
    guihooks.trigger("NKgetUserCommands", usercommands)
    guihooks.trigger("NKgetGlobalCommands", globalcommands)
    guihooks.trigger("NKgetInterfaceValues", interfaceValues)

end

local function resetPlayerList()
    playerlist = {}
    usercommands = {}
    initialized = false
    initializeInterface(0)
end

local function onWorldReadyState(state)
    if state == 2 then
        log('D', "Nickel", "Nickel interface ready in this instance")
    end
end

--searchPlayer
local function searchPlayer(search)
    isSearching = true
    searchPlayerlist = {}
    TriggerServerEvent("searchPlayer", search)
end


local function updatePlayerList()
    TriggerServerEvent("initInterface", #playerlist)
end

local function NKgetServerValues(data) -- Receive event with parameters
    local finaldata = jsonDecode(data)

    serverinfos = finaldata

    log('D', "Nickel", "getServerValues called with version " .. finaldata.server_version)

    guihooks.trigger("NKgetServerValues", serverinfos)
end

local function NKgetUserValues(data)
    local finaldata = jsonDecode(data)
    self_action_perm = finaldata
    guihooks.trigger("NKgetUserValues", self_action_perm)
end

local function getUserCommands(data)
    local finaldata = jsonDecode(data)
    usercommands = finaldata
    print("triggering getUserCommands")
    guihooks.trigger("NKgetUserCommands", usercommands)
end

local function getGlobalCommands(data)
    local finaldata = jsonDecode(data)
    globalcommands = finaldata
    print("triggering getGlobalCommands")
    guihooks.trigger("NKgetGlobalCommands", globalcommands)
end

local function NKinsertPlayers(data)
    local finaldata = jsonDecode(data)
    local list = isSearching and searchPlayerlist or playerlist

    for i, player in ipairs(finaldata) do
        local updated = false
        -- Vérifie si le joueur existe déjà et le met à jour si nécessaire
        for i, v in ipairs(list) do
            if tostring(v.beammpid) == tostring(player.beammpid) then
                list[i] = player -- Mise à jour de l'entrée existante
                updated = true
                break
            end
        end

        -- Si le joueur n'existe pas, l'ajouter à la liste
        if not updated then
            table.insert(list, player)
        end
    end
end

local function NKgetPlayers()
    local list = isSearching and searchPlayerlist or playerlist
    guihooks.trigger("getPlayers", list)
end

local function NKgetRoles(data)
    local finaldata = jsonDecode(data)
    roles = finaldata
    guihooks.trigger("getRoles", roles)
end

local function getInterfaceValues(data)
    local finaldata = jsonDecode(data)
    interfaceValues = finaldata
    if not bypassNametagsBool then
        MPVehicleGE.hideNicknames(not interfaceValues.showNameplates)     
    else
        MPVehicleGE.hideNicknames(false)
    end

    guihooks.trigger("NKgetInterfaceValues", interfaceValues)
end

local function SyncInterfaceValues(key, value)
    local newInterfaceValues = interfaceValues
    newInterfaceValues[key] = value
    local newInterfaceValuesJson = jsonEncode(newInterfaceValues)
    TriggerServerEvent("SyncInterfaceValues", newInterfaceValuesJson)
end



local function addRole(rolename, player)
    local data = jsonEncode({command = "grantrole", args = {rolename, player}})
    TriggerServerEvent("runCommand", data)
end
local function removeRole(rolename, player)
    local data = jsonEncode({command = "revokerole", args = {rolename, player}})
    TriggerServerEvent("runCommand", data)
end

local function sendCommand(command, args)
    local data = jsonEncode({command = command, args = args})
    TriggerServerEvent("runCommand", data)
end

local function initiate()
    jsinitiated = true
    M.checkInitiate()
end

local function checkInitiate()
    guihooks.trigger("NKisInitiated", jsinitiated)
end

local function bypassNametags(value)
    local data = jsonEncode(value)
    if value == "on" then
        bypassNametagsBool = true
    elseif value == "off" then
        bypassNametagsBool = false
    end
end

AddEventHandler("getInterfaceValues", getInterfaceValues)
AddEventHandler("clientSyncEnvironment", clientSyncEnvironment)
AddEventHandler("receiveEnvironment", receiveEnvironment)
AddEventHandler("NKgetServerInfos", NKgetServerValues) 
AddEventHandler("NKgetUserInfos", NKgetUserValues) 
AddEventHandler("NKinsertPlayers", NKinsertPlayers) 
AddEventHandler("NKgetPlayers", NKgetPlayers) 
AddEventHandler("NKResetSearch", resetSearch)
AddEventHandler("NKResetPlayerList", resetPlayerList)
AddEventHandler("NKgetRoles", NKgetRoles) 
AddEventHandler("NKgetUserCommands", getUserCommands)
AddEventHandler("NKgetGlobalCommands", getGlobalCommands) -- Add our events handler to the list managed by BeamMP
AddEventHandler("bypassNametags", bypassNametags)
M.NKgetPlayers = NKgetPlayers
M.syncInterfaceValues = SyncInterfaceValues
M.checkInitiate = checkInitiate
M.initiate = initiate
M.sendCommand = sendCommand
M.getUserCommands = getUserCommands
M.getGlobalCommands = getGlobalCommands
M.getInterfaceValues = getInterfaceValues
M.addRole = addRole
M.removeRole = removeRole
M.getTemp = getTemp
M.getMeteo = getMeteo
M.getWind = getWind
M.getGravity = getGravity
M.getTime = getTime
M.setMeteo = setMeteo
M.setTemp = setTemp
M.setWind = setWind
M.setGravity = setGravity
M.setTime = setTime
M.jsUpdateEnvironment = jsUpdateEnvironment
M.emptyPlayerList = emptyPlayerList
M.NKgetUserValues = NKgetUserValues
M.NKgetServerValues = NKgetServerValues
M.updatePlayerList = updatePlayerList
M.searchPlayer = searchPlayer
M.resetSearch = resetSearch
M.resetPlayerList = resetPlayerList
M.initializeInterface = initializeInterface
M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded
M.onWorldReadyState = onWorldReadyState
M.onInit = function() setExtensionUnloadMode(M, "manual") end

return M
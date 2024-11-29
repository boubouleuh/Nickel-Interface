local M = {}

local initialized = false
local roles = {}
local playerlist = {}
local serverinfos = {}

local time = require("ge.extensions.beamng.time")

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
        guihooks.trigger('SyncEnvironment', environment)
    end 
end

function deepCompare(t1, t2)
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return t1 == t2 end
    
    for k, v in pairs(t1) do
        if not deepCompare(v, t2[k]) then return false end
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
end

function setTime(hours, minutes)
    environment.time = {hours, minutes}
end

function setGravity(grav)
    environment.gravity = grav
end

function setWind(x, y, z)
    environment.wind = x
   --[[  updateEnvironment({wind = {x, y, z}}) ]]
end

function setMeteo(meteo)
    environment.meteo = meteo
end


function jsUpdateEnvironment()
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
    environment = newEnv
--[[     updateEnvironment(newEnv)
 ]]end



local function onExtensionLoaded()
    log('D', "Nickel", "Loaded")
end

local function onExtensionUnloaded()
    log('D', "Nickel", "Unloaded")
end

local function onWorldReadyState(state)
    if state == 2 then
        log('D', "Nickel", "Nickel interface ready in this instance")
    end
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
    if not initialized then
        log('D', "Nickel", "Initialized interface via AngularJS")

        TriggerServerEvent("initInterface", offset)
        weatherPresets = core_weather.getPresets()
        initialized = true
    elseif initialized then
        print("already initialized")
        guihooks.trigger('SyncWeatherPresets', weatherPresets)
        guihooks.trigger('SyncEnvironment', environment)
        guihooks.trigger("getServerValues", serverinfos)
        guihooks.trigger("getPlayers", playerlist)
        guihooks.trigger("getRoles", roles)
    end
end

local function updatePlayerList()
    TriggerServerEvent("initInterface", #playerlist)
end

local function getServerValues(data) -- Receive event with parameters
    local finaldata = jsonDecode(data)

    serverinfos = finaldata

    log('D', "Nickel", "getServerValues called with version " .. finaldata.server_version)

    guihooks.trigger("getServerValues", serverinfos)
end


local function NKinsertPlayers(data)
    local finaldata = jsonDecode(data)
    table.insert(playerlist, finaldata.beammpid, finaldata)
end

local function NKgetPlayers()
    guihooks.trigger("getPlayers", playerlist)
end

local function NKgetRoles(data)
    local finaldata = jsonDecode(data)
    roles = finaldata
    guihooks.trigger("getRoles", roles)
end



AddEventHandler("clientSyncEnvironment", clientSyncEnvironment)
AddEventHandler("receiveEnvironment", receiveEnvironment)
AddEventHandler("NKgetServerInfos", getServerValues) -- Add our event handler to the list managed by BeamMP
AddEventHandler("NKinsertPlayers", NKinsertPlayers) -- Add our event handler to the list managed by BeamMP
AddEventHandler("NKgetPlayers", NKgetPlayers) -- Add our event handler to the list managed by BeamMP

AddEventHandler("NKgetRoles", NKgetRoles) -- Add our event handler to the list managed by BeamMP



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
M.getServerValues = getServerValues
M.updatePlayerList = updatePlayerList
M.initializeInterface = initializeInterface
M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded
M.onWorldReadyState = onWorldReadyState

return M
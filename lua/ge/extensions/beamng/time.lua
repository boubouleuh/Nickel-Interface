-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

local time = {}

function time.getObjectByClass(className)
    local o = scenetree.findClassObjects(className)
    if not o or #o == 0 then return nil end
    o = scenetree.findObject(o[1])
    if not o then return nil end
    return o
end

-- sets the time. example: setTimeOfDay('13:00')
-- uses 24h time format
function time.setTimeOfDay(inp)
    local tod = getObjectByClass("TimeOfDay")
    if not tod then return false end
  
    if type(inp) == 'string' then
      -- parse the string then
      local h, m, s = string.match(inp, "([0-9]*):?([0-9]*):?([0-9]*)")
      inp = {
        hours = tonumber(h) or 0,
        mins = tonumber(m) or 0,
        secs = tonumber(s) or 0
      }
    end
    --dump(inp)
    tod.time = (((inp.hours * 3600 + inp.mins * 60 + inp.secs) / 86400) + 0.5) % 1
end

-- get time using 24h format
function time.getTimeOfDay()
    local tod = getObjectByClass("TimeOfDay")
    if not tod then return false end
    return tod.time
end

return time
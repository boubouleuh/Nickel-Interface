
local time = {}

function time.setTimeOfDay(timeStr, play, daylength)
  -- timeStr doit être au format "HH:MM"
  local h, m = timeStr:match("^(%d+):(%d+)$")
  h = tonumber(h)
  m = tonumber(m)
  if not h or not m or h < 0 or h > 23 or m < 0 or m > 59 then
    return
  end
  local time = ((h + m / 60) / 24 + 0.5) % 1
  core_environment.setTimeOfDay({
    time = time,
    play = play,
    dayScale = 1,
    nightScale = 1,
    dayLength = daylength or 86400,
    azimuthOverride = 0,
    startTime = time
  })
end

return time
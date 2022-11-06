functions = {}
local min = math.min
local max = math.max
local noise = love.math.noise
function functions.charSplit (inStr)
    local outStr, nextChar = inStr:sub(1, 1)
    for pos = 2, #inStr do
        nextChar = inStr:sub(pos, pos)
        if nextChar ~= outStr:sub(#outStr, #outStr) then
            outStr = outStr .. ", "
        end
        outStr = outStr .. nextChar
        out = {}
    end
    return outStr
end
function functions.createAndInsertTable(parentTable,childTable,value)
  if parentTable[childTable] ~= nil then
    table.insert(parentTable[childTable],value)
  else
    parentTable[childTable] = {}
    table.insert(parentTable[childTable],value)
  end
end
function functions.reverseTable(t)
  local n = #t
  local i = 1
  while i < n do
    t[i],t[n] = t[n],t[i]
    i = i + 1
    n = n - 1
  end
end
function functions.clamp(low, n, high) return min(max(n, low), high) end
function functions.generateTerrainNoise(octaves,x,y,z,value)
  local tmpNoise = 0
  value = value or 1
  if octaves == 1 then
      tmpNoise = noise(x*0.01,y * 0.01,z*0.01,value*0.01)
  elseif octaves == 2 then
      tmpNoise = noise(x*0.01,y * 0.01,z*0.01,value*0.01)
      tmpNoise = tmpNoise + noise(x * 0.01, y * 0.01, z * 0.02, value * 0.02)
  elseif octaves == 3 then
      tmpNoise = noise(x*0.01,y * 0.01,z*0.01,value*0.01)
      tmpNoise = tmpNoise + noise(x * 0.01, y * 0.01, z * 0.02, value * 0.02)
      tmpNoise = tmpNoise + noise(x * 0.01, y * 0.01)
  elseif octaves == 4 then
      tmpNoise = noise(x * 0.001, y * 0.001)
  end
  tmpNoise = tmpNoise / octaves
  return tmpNoise
end
--from https://stackoverflow.com/questions/26855156/how-to-make-a-weighted-rng-in-roblox-lua-like-csgo-cases
function weighted_random (weights)
  local summ = 0
  for i, weight in pairs (weights) do
      summ = summ + weight
  end
  if summ == 0 then return end
  -- local value = math.random (summ) -- for integer weights only
  local value = summ*math.random()
  summ = 0
  for i, weight in pairs (weights) do
      summ = summ + weight
      if value <= summ then
          return i
      end
  end
end

function functions.generatePlanets(amount,seed)
  math.randomseed(seed)
  local bodies = {}
  local orbitRadius = 1
  for name,v in pairs(global.planetTypes) do
    local planet = {}
    local planetVariants = v.variants
    local weightedList = {}
    for planetName,planet in pairs(planetVariants) do
      weightedList[planetName] = planet.weight 
    end 
    planet.variant = weighted_random(weightedList)
    planet.planetSize = math.random(5)
    planet.orbitRadius = amount*10
    planet.orbitalSpeed = amount*-10
    planet.type = name
    planet.chunks = {}
    planet.actors = {}
    planet.objects = {}
    planet.collisionMap = {}
    table.insert(bodies,planet)
    amount = amount + 1
  end
  return bodies
end
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end
function math.normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end
function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end
function table.findString(table,strings)
  local found = false
  local values = {}
  for _,string in pairs(strings) do
    for i,v in pairs(table) do 
      if v == string then
        values[string] = true
        break
      end
    end
  end
  return values
end
function table.length(table)
  local count = 0
  for i,v in pairs(table) do
    count = count + 1
  end
  return count
end
function get_date_from_unix(unix_time)
  local day_count, year, days, month = function(yr) return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365 end, 1970, math.ceil(unix_time/86400)

  while days >= day_count(year) do
      days = days - day_count(year) year = year + 1
  end
  local tab_overflow = function(seed, table) for i = 1, #table do if seed - table[i] <= 0 then return i, seed end seed = seed - table[i] end end
  month, days = tab_overflow(days, {31,(day_count(year) == 366 and 29 or 28),31,30,31,30,31,31,30,31,30,31})
  local hours, minutes, seconds = math.floor(unix_time / 3600 % 24), math.floor(unix_time / 60 % 60), math.floor(unix_time % 60)
  local period = hours > 12 and "pm" or "am"
  hours = hours > 12 and hours - 12 or hours == 0 and 12 or hours
  return string.format("%d/%d/%04d %02d:%02d:%02d %s", days, month, year, hours, minutes, seconds, period)
end
function checkForFlag(collisionMap,positionString,searchedFlag)
  local list = collisionMap[positionString]
  if list ~= nil then
    for _,v in pairs(list) do
      if v.flags[searchedFlag] ~= nil then
        return true
      end
    end
  else
    return false
  end
end
local createAndInsertTable = functions.createAndInsertTable
function processCollisions(planet)
  planet.collisionMap = {}
  local objectsToKeep = {}
  for objectIndex,object in pairs(planet.objects) do
    if object.removed == nil then
      createAndInsertTable(planet.collisionMap,object.position:__tostring(),object)
      table.insert(objectsToKeep,object)
    end
  end
  planet.objects = objectsToKeep
  for actorIndex,actor in pairs(planet.actors) do
    createAndInsertTable(planet.collisionMap,actor.position:__tostring(),actor)
  end
end
-- from https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua
--- Check if a file or directory exists in this path
function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
function isdir(path)
   -- "/" works on both Unix and Windows
   return exists(path.."/")
end
function addTableToTable(table1,table2) 
  for i,v in pairs(table2) do
    table.insert(table1,v)
  end
end
function pointOnACircle(radius,x,y,theta)
  return vector(x+radius*math.cos(theta),y+radius*math.sin(theta))
end
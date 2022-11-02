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
function functions.generatePlanets(amount,seed)
  math.randomseed(seed)
  local bodies = {}
  local orbitalRange = {}
  for i=1,amount do
    local planet = {}
    local orbitRadius = i
    while orbitalRange[orbitRadius] == 1 do
      orbitRadius = math.random(10)
    end
    planet.orbitRadius = orbitRadius*math.random(20,30)
    orbitalRange[orbitRadius] = 1
    planet.planetSize = math.random(5)
    planet.orbitalSpeed = math.random(10)
    planet.index = i
    planet.chunks = {}
    planet.actors = {}
    planet.objects = {}
    planet.collisionMap = {}
    table.insert(bodies,planet)
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
  universe.collisionMap = {}
  for objectIndex,object in pairs(planet.objects) do
    if object.removed == nil then
      createAndInsertTable(planet.collisionMap,object.position:__tostring(),object)
    end
  end
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
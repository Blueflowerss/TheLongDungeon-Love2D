classFactory = {}
local flagDefinitions = {}
local interactions = {"door","sign"}
local saveableData = {
    "pos","state","text"
}
local blueprints = {}
local objects = {}
local finishedObjects = {}
local createAndInsertTable = functions.createAndInsertTable
function classFactory.init()
  flagDefinitions = {
    ["base"]={["devname"]=""},
    ["item"]={["position"]=vector(0,0),["sprite"]=1,["displayname"]="",["weight"]=1,["meleedamage"]=1},
    ["furniture"]={["position"]=vector(0,0),["sprite"]=1},
    ["door"]={["state"]=false,["spriteTrue"]=1,["spriteFalse"]=1},
    ["sign"]={["text"]=""},
    ["tile"]={["position"]=vector(0,0),["sprite"]=1,["displayname"]=""}
}
  --get blueprint json files
  local workingDirectory = love.filesystem.getWorkingDirectory()
  assert(workingDirectory~=nil,"Couldn't find working directory")
  for index,blueprint in pairs(love.filesystem.getDirectoryItems("/data/blueprints/")) do
    local file = love.filesystem.read("/data/blueprints/"..blueprint)
    blueprints[index] = file
  end
  --assert(false,workingDirectory.."/The-Long-Dungeon-Love2D/data/blueprints/"..inspect(blueprints))
  --get objects from said files
  for _,object in pairs(blueprints) do
    local jsonFile = lunajson.decode(object)
    for _,item in pairs (jsonFile) do
      table.insert(objects,item)
    end
  end
  --turn objects into actual in-game objects
  for _,object in pairs(objects) do
    local o = {}
    o.flags = object.flags 
    o.interactions = {}
    for _,flag in pairs(o.flags) do
      if flagDefinitions[flag] ~= nil then
        definition = flagDefinitions[flag] 
        --add attributes indicated by object's flags
        for attributeName,attribute in pairs(definition) do
          o[attributeName] = attribute  
        end
      end
      --if there are any flags that indicate interactability, then note them down
      for _,interaction in pairs(interactions) do
        if flag == interaction and o.interactions[flag] == nil then
          table.insert(o.interactions,flag)
        end
      end
      --add rest of the data from the file
      for attributeName,attribute in pairs(object.data) do
        o[attributeName] = attribute
      end
    end
    assert(not finishedObjects[o.devname],"duplicate found by name of "..o.devname)
    finishedObjects[o.devname] = o
  end
end
function classFactory.getObject(devname)
  return table.shallow_copy(finishedObjects[devname])
end
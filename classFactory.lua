classFactory = {}
local flagDefinitions = {}
local init = {warp=true}
local process = {worldgenworm=true,duration=true}
function initObject(object,flag)
  function warp()
    local body = global.multiverse[global.currentUniverse].bodies[global.currentPlanet]
    local destination = math.random(#body.connections)
    object.warpTo = body.connections[destination]
  end
  local functions = {warp=warp}
  if functions[flag] then
    functions[flag]()
  end
end
local blueprints = {}
local objects = {}
--databaseLength is just length of the finishedObjects table, cheaper to do it this way.
classFactory.databaseLength = 0
classFactory.finishedObjectsIndexTable = {}
classFactory.finishedObjects = {}
local createAndInsertTable = functions.createAndInsertTable
function classFactory.init()
  flagDefinitions = {
    ["base"]={["devname"]=""},
    ["item"]={["position"]=vector(0,0),["sprite"]=1,["displayname"]="",["weight"]=1,["meleedamage"]=1},
    ["furniture"]={["position"]=vector(0,0),["sprite"]=1},
    ["door"]={["state"]=false,["spriteTrue"]=1,["spriteFalse"]=1},
    ["sign"]={["text"]=""},
    ["tile"]={["position"]=vector(0,0),["sprite"]=1,["displayname"]=""},
    ["floor"]={["renderLayer"]=0},
    ["warp"]={["init"]={"warp"}},
    ["worldgenworm"]={["process"]={}}
    
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
  for objectIndex,object in pairs(objects) do
    local o = {}
    o.flags = object.flags 
    o.interactions = {}
    o.process = {}
    for flag,_ in pairs(o.flags) do
      if flagDefinitions[flag] then
        definition = flagDefinitions[flag] 
        --add attributes indicated by object's flags
        for attributeName,attribute in pairs(definition) do
          o[attributeName] = attribute  
        end
      end
      --if there are any flags that indicate interactability, then note them down
      
        if interactionList[flag] == 0 and o.interactions[flag] == nil then
          table.insert(o.interactions,flag)
        end
        if process[flag] then
          table.insert(o.process,flag)
        end
        --if there are any objects which need initialization, then do so
        --add rest of the data from the file
        for attributeName,attribute in pairs(object.data) do
          o[attributeName] = attribute
        end
      end
      for i,data in pairs(object.data) do
        if process[i] then
          table.insert(o.process,i)
        end
      end
      assert(not classFactory.finishedObjects[o.devname],"duplicate found by name of "..o.devname)
    classFactory.databaseLength = classFactory.databaseLength + 1
    classFactory.finishedObjects[o.devname] = o
    classFactory.finishedObjectsIndexTable[objectIndex] = o.devname
  end
end
function classFactory.getObject(devname)
  local object = table.shallow_copy(classFactory.finishedObjects[devname])
  if object.init then
    for i,v in pairs(object.init) do
      initObject(object,v)
    end
  end
  return object
end
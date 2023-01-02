global = {}
space = {}
global.noiseSettings = {}
global.noiseSettings.tolerance = 0.5
global.font = love.graphics.newFont("LiberationSans-Italic.ttf",30)
global.chunkSize = 6
global.height = 2
global.heightMultiplier = 100
global.chunkUnloadDistance = 4
global.currentUniverse = 2200
global.currentPlanet = "earth"
global.currentActor = 0
global.planetAmount = 5
global.planetTypes = {}
global.biomes = {}
global.biomesIndexed = {}
global.biomeAmount = 0
global.buildSlot = 0
global.buildSlotName = ""
global.gameSprites = {}
global.multiverse = {}
global.spriteDistancing = 128
global.spriteScaling = 0.5
global.playerSpawnPoint = vector(460,20,100)
global.saveableData = {
    ["state"]=0,["text"]="",["warpTo"]=0
}
global.gameScene = null
global.scenes = {
  GAMESCENE = "main",
  SPACEMENU = "spaceMenu"
}
global.cameraPosition = vector(200,200)
global.playerData = {
  position=vector(0,0):__tostring(),
  world=global.currentUniverse,
  planet=global.currentPlanet
}
global.chunkFiles = {}
global.keyBindings = {["GAMESCENE"]={["up"]="moveup",['down']="movedown",['left']="moveleft",['right']="moveright",
w="moveup",s='movedown',d='moveright',a='moveleft',["k"]="stepback",["l"]="stepforward",[","]="climbup",["."]="climbdown",
g="debug",
b="build",v="destroy",[","]="buildSlotLeft",["."]="buildSlotRight",["space"]="interact",
kp8="moveup",kp2="movedown",kp6="moveright",kp4="moveleft",
kp9="moverightup",kp3="moverightdown",kp7="moveleftup",kp1="moveleftdown",
escape="escape",
m="spacemenu"},
["SPACEMENU"]={
  m="exitmenu",left="left",right="right",down="down",up="up",["kp+"]="plus",["kp-"]="minus",
  ["k"]="stepback",["l"]="stepforward",[","]="timeback",["."]="timeforward"
}}
interactionList = {door=0,sign=0,warp=0}
space.viewingUniverse = 2200
space.viewingPlanet = 1
space.viewingTime = 1
space.offset = vector(0,0)
space.zoom = 0
space.centralCircle = {}
space.dateString = ""
space.bodies = {}
function global.initializeGame()
  local playerData = love.filesystem.read("playerData.json")
  if playerData ~= nil then
    playerData = lunajson.decode(playerData)
    if playerData.position ~= nil then
      playerData.position = vector(playerData.position[1],playerData.position[2],playerData.position[3])
    end
    global.playerSpawnPoint = playerData.position
    global.currentUniverse = playerData.world
    global.currentPlanet = playerData.planet
    timer = playerData.timer
  else
    timer = 3471321600
  end
  
    local sprites = love.filesystem.getDirectoryItems("/sprites")
  global.chunkFiles = love.filesystem.getDirectoryItems("/"..global.currentUniverse.."/chunks/")
  global.chunkFiles = {}
  for i,chunk in pairs(global.chunkFiles) do
    global.chunkFiles[chunk] = 1
  end
  classFactory.init()
  for index,sprite in pairs(sprites) do
    local spriteSlot = tonumber(string.sub(sprite,1,4))
    global.gameSprites[spriteSlot] = love.graphics.newImage("/sprites/"..sprite) 
  end
  planetGeneration.generatePlanetTypes()
  planetGeneration.generateBiomes()
  global.multiverse[global.currentUniverse] = universe:new(global.currentUniverse)
  print(global.currentPlanet)
  global.multiverse[global.currentUniverse].bodies[global.currentPlanet].actors[global.currentActor] = playerObject:new(global.playerSpawnPoint)
  local universe = global.multiverse[global.currentUniverse]
  worldFunctions.chunkGeneration(universe.bodies[global.currentPlanet].actors[global.currentActor].position,3,universe,universe.bodies[global.currentPlanet])
end

function global.switchUniverse(originalUniverse,destinationUniverse,actor)
  local originalUniverseObject = global.multiverse[originalUniverse]
  local player = actor
  if global.multiverse[destinationUniverse] == nil then
    global.multiverse[destinationUniverse] = universe:new(destinationUniverse)
  end
  local destinationUniverseObject = global.multiverse[destinationUniverse]
  local destinationUniversePlanet = destinationUniverseObject.bodies[global.currentPlanet]
  worldFunctions.chunkGeneration(player.position,3,destinationUniverseObject,destinationUniversePlanet)
  processCollisions(destinationUniversePlanet)
  local objectList = destinationUniversePlanet.collisionMap
  local blocked = checkForFlag(objectList,player.position:__tostring(),"blocks")
  if not blocked then
    destinationUniversePlanet.actors[global.currentActor] = player
    table.remove(originalUniverseObject.bodies[global.currentPlanet].actors,global.currentActor)
    global.currentUniverse = destinationUniverse
    for chunkIndex,chunk in pairs(originalUniverseObject.bodies[global.currentPlanet].chunks) do 
        if chunk.altered then
          worldFunctions.saveChunk(originalUniverseObject,originalUniverseObject.bodies[global.currentPlanet],chunk)
        end
    end
    isChunkGenerated[originalUniverse] = nil
    global.multiverse[originalUniverse] = nil
  end
end  
function global.switchPlanet(originalPlanet,destinationPlanet,actor)
  local universe = global.multiverse[global.currentUniverse]
  local player = actor
  local destinationUniversePlanet = universe.bodies[destinationPlanet]
  worldFunctions.chunkGeneration(player.position,3,universe,destinationUniversePlanet)
  processCollisions(destinationUniversePlanet)
  local objectList = destinationUniversePlanet.collisionMap
  local blocked = checkForFlag(objectList,player.position:__tostring(),"blocks")
  if blocked then
    local i = 0
    --teleport correction, teleports the player upto 10 tiles higher
    while blocked and i<100 do
      blocked = checkForFlag(objectList,(player.position+vector(0,0,i)):__tostring(),"blocks")
      i = i + 1
    end
    if not blocked then
      player.position = player.position+vector(0,0,i)
    end
  end
  if not blocked then
    destinationUniversePlanet.actors[global.currentActor] = player
    table.remove(universe.bodies[originalPlanet].actors,global.currentActor)
    for chunkIndex,chunk in pairs(universe.bodies[global.currentPlanet].chunks) do 
        if chunk.altered then
          worldFunctions.saveChunk(universe,universe.bodies[global.currentPlanet],chunk)
        end
    end
    global.currentPlanet = destinationPlanet  
    universe.bodies[originalPlanet].objects = {}
  end
end  
function global.saveGame()
end
function global.processObject(object)
  function worldgenworm()
  end
  function duration()
    print(object.duration)
    object.duration = object.duration - 1
    if object.duration < 0 then
      object.removed = true
    end
  end
  local processables = {duration=duration,worldgenworm=worldgenworm}
  for i,process in pairs(object.process) do
    if processables[process] then
      processables[process]()
    end  
  end
end
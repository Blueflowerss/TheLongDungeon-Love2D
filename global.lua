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
global.currentPlanet = 2
global.currentActor = 0
global.planetAmount = 5
global.planetTypes = {}
global.buildSlot = 0
global.buildSlotName = ""
global.gameSprites = {}
global.multiverse = {}
global.spriteDistancing = 128
global.spriteScaling = 0.5
global.playerSpawnPoint = vector(460,20,100)
global.saveableData = {
    ["position"]=0,["state"]=0,["text"]=""
}
global.gameScene = null
global.scenes = {
  GAMESCENE = "main",
  SPACEMENU = "spaceMenu"
}
global.cameraPosition = vector(200,200)
global.playerData = {
  position=vector(0,0):__tostring(),
  world=global.currentUniverse
}
global.chunkFiles = {}
global.keyBindings = {["GAMESCENE"]={["up"]="moveup",['down']="movedown",['left']="moveleft",['right']="moveright",
w="moveup",s='movedown',d='moveright',a='moveleft',["k"]="stepback",["l"]="stepforward",[","]="climbup",["."]="climbdown",
g="debug",
b="build",v="destroy",[","]="buildSlotLeft",["."]="buildSlotRight",
kp8="moveup",kp2="movedown",kp6="moveright",kp4="moveleft",
kp9="moverightup",kp3="moverightdown",kp7="moveleftup",kp1="moveleftdown",
escape="escape",
m="spacemenu"},
["SPACEMENU"]={
  m="exitmenu",left="left",right="right",down="down",up="up",["kp+"]="plus",["kp-"]="minus"
}}
space.viewingUniverse = 2200
space.viewingPlanet = 1
space.viewingTime = 1
space.offset = vector(0,0)
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
  global.multiverse[global.currentUniverse] = universe:new(global.currentUniverse)
  global.multiverse[global.currentUniverse].bodies[global.currentPlanet].actors[global.currentActor] = playerObject:new(global.playerSpawnPoint)
  local universe = global.multiverse[global.currentUniverse]
  worldFunctions.chunkGeneration(universe.bodies[global.currentPlanet].actors[global.currentActor].position,3,universe,universe.bodies[global.currentPlanet])
end

function global.switchUniverse(originalUniverse,destinationUniverse)
  local originalUniverseObject = global.multiverse[originalUniverse]
  local player = originalUniverseObject.bodies[global.currentPlanet].actors[global.currentActor]
  if global.multiverse[destinationUniverse] == nil then
    global.multiverse[destinationUniverse] = universe:new(destinationUniverse)
  end
  local destinationUniverseObject = global.multiverse[destinationUniverse]
  local destinationUniversePlanet = destinationUniverseObject.bodies[global.currentPlanet]
  local dirOk = isdir(love.filesystem.getSaveDirectory().."/"..tostring(destinationUniverse).."/chunks/")
  global.chunkFiles = love.filesystem.getDirectoryItems("/"..destinationUniverse.."/chunks/")
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

function global.saveGame()
end

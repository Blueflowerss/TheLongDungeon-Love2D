global = {}

global.noiseSettings = {}
global.noiseSettings.tolerance = 0.5
global.font = love.graphics.newFont("LiberationSans-Italic.ttf",30)
global.chunkSize = 6
global.height = 2
global.heightMultiplier = 100
global.chunkUnloadDistance = 4
global.currentUniverse = 2200
global.currentActor = 0
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
global.cameraPosition = vector(200,200)
global.playerData = {
  position=vector(0,0):__tostring(),
  world=global.currentUniverse
}
global.chunkFiles = {}
global.keyBindings = {["up"]="moveup",['down']="movedown",['left']="moveleft",['right']="moveright",
w="moveup",s='movedown',d='moveright',a='moveleft',["k"]="stepback",["l"]="stepforward",[","]="climbup",["."]="climbdown",
g="debug",
b="build",v="destroy",[","]="buildSlotLeft",["."]="buildSlotRight",
kp8="moveup",kp2="movedown",kp6="moveright",kp4="moveleft",
kp9="moverightup",kp3="moverightdown",kp7="moveleftup",kp1="moveleftdown",
escape="escape"}

function global.initializeGame()
  local playerData = love.filesystem.read("playerData.json")
  if playerData ~= nil then
    playerData = lunajson.decode(playerData)
    if playerData.position ~= nil then
      playerData.position = vector(playerData.position[1],playerData.position[2],playerData.position[3])
    end
    global.playerSpawnPoint = playerData.position
    global.currentUniverse = playerData.world
  end
  
    local sprites = love.filesystem.getDirectoryItems("/sprites")
  global.chunkFiles = love.filesystem.getDirectoryItems("/"..global.currentUniverse.."/chunks/")
  for i,chunk in pairs(global.chunkFiles) do
    global.chunkFiles[chunk] = 1
  end
  classFactory.init()
  for index,sprite in pairs(sprites) do
    local spriteSlot = tonumber(string.sub(sprite,1,4))
    global.gameSprites[spriteSlot] = love.graphics.newImage("/sprites/"..sprite) 
  end
  global.multiverse[global.currentUniverse] = universe:new(global.currentUniverse)
  global.multiverse[global.currentUniverse].actors[global.currentActor] = playerObject:new(global.playerSpawnPoint)
end

function global.switchUniverse(originalUniverse,destinationUniverse)
  local originalUniverseObject = global.multiverse[originalUniverse]
  if global.multiverse[destinationUniverse] == nil then
    global.multiverse[destinationUniverse] = universe:new(destinationUniverse)
  end
  local destinationUniverseObject = global.multiverse[destinationUniverse]
  local dirOk = isdir(love.filesystem.getSaveDirectory().."/"..tostring(destinationUniverse).."/chunks/")
  if dirOk then
    global.chunkFiles = love.filesystem.getDirectoryItems("/"..destinationUniverse.."/chunks/")
    local player = originalUniverseObject.actors[global.currentActor]
    destinationUniverseObject.actors[global.currentActor] = player
    --hack to generate terrain because jesus it just doesn't work
    destinationUniverseObject.actors[global.currentActor].playerLastChunk = vector(-999,-999,-999)table.remove(originalUniverseObject.actors,global.currentActor)
    global.currentUniverse = destinationUniverse
  else
    global.chunkFiles = love.filesystem.getDirectoryItems("/"..destinationUniverse.."/chunks/")
    local player = originalUniverseObject.actors[global.currentActor]
    destinationUniverseObject.actors[global.currentActor] = player
    player.position = player.position + vector(0,0,1)
    --hack to generate terrain because jesus it just doesn't work
    destinationUniverseObject.actors[global.currentActor].playerLastChunk = vector(-999,-999,-999)
    table.remove(originalUniverseObject.actors,global.currentActor)
    global.currentUniverse = destinationUniverse
  
  isChunkGenerated = {}
  isTileGenerated = {} 
  isRampGenerated = {}   
  for chunkIndex,chunk in pairs(originalUniverseObject.chunks) do 
      if chunk.altered then
        worldFunctions.saveChunk(originalUniverseObject,chunk)
      end
      for i,object in pairs(chunk.objects) do
        object.removed = true
      end
  end
end  
end

function global.saveGame()
end

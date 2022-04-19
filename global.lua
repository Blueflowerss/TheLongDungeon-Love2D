global = {}

global.noiseSettings = {}
global.noiseSettings.tolerance = 0.5
global.font = love.graphics.newFont("LiberationSans-Italic.ttf",30)
global.chunkSize = 6
global.height = 1
global.heightMultiplier = 100
global.chunkUnloadDistance = 4
global.currentUniverse = 0
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
global.saveFile = {}
global.keyBindings = {["up"]="moveup",['down']="movedown",['left']="moveleft",['right']="moveright",
w="moveup",s='movedown',d='moveright',a='moveleft',["k"]="stepback",["l"]="stepforward",[","]="climbup",["."]="climbdown",
g="debug",b="build",[","]="buildSlotLeft",["."]="buildSlotRight",
kp8="moveup",kp2="movedown",kp6="moveright",kp4="moveleft",
kp9="moverightup",kp3="moverightdown",kp7="moveleftup",kp1="moveleftdown"}
function global.initializeGame()
  local sprites = love.filesystem.getDirectoryItems("/sprites")
  classFactory.init()
  for index,sprite in pairs(sprites) do
    local spriteSlot = tonumber(string.sub(sprite,1,4))
    global.gameSprites[spriteSlot] = love.graphics.newImage("/sprites/"..sprite) 
  end
  global.multiverse[0] = universe:new(0)
end
function global.saveChunk(chunk)
  local savedChunk = {["objects"]={},["position"]=chunk.chunkPosition:__tostring()}
  for i,object in pairs(chunk.objects) do
    local objectData = {}
    for dataType,data in pairs(object) do
      if global.saveableData[dataType] ~= nil then
        table.insert(objectData,{[dataType]=data})
      end
    end
    local compressedObject = {devname=object.devname,data=flags,position=object.position}
    table.insert(savedChunk.objects,compressedObject)
  end
  love.filesystem.createDirectory("chunk/"..savedChunk.position)
end
function global.loadChunk(chunk)
end
function global.saveGame()
end

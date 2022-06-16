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
global.chunkFiles = {}
global.keyBindings = {["up"]="moveup",['down']="movedown",['left']="moveleft",['right']="moveright",
w="moveup",s='movedown',d='moveright',a='moveleft',["k"]="stepback",["l"]="stepforward",[","]="climbup",["."]="climbdown",
g="debug",b="build",[","]="buildSlotLeft",["."]="buildSlotRight",
kp8="moveup",kp2="movedown",kp6="moveright",kp4="moveleft",
kp9="moverightup",kp3="moverightdown",kp7="moveleftup",kp1="moveleftdown"}
function global.initializeGame()
  local sprites = love.filesystem.getDirectoryItems("/sprites")
  global.chunkFiles = love.filesystem.getDirectoryItems("/0/chunks/")
  for i,chunk in pairs(global.chunkFiles) do
    global.chunkFiles[chunk] = 1
  end
  classFactory.init()
  for index,sprite in pairs(sprites) do
    local spriteSlot = tonumber(string.sub(sprite,1,4))
    global.gameSprites[spriteSlot] = love.graphics.newImage("/sprites/"..sprite) 
  end
  global.multiverse[0] = universe:new(0)
end
function global.switchUniverse(universe)
  global.chunkFiles = love.filesystem.getDirectoryItems(universe.index.."/chunks/")
end
function global.saveChunk(universe,chunk)
  --could couple multiple objects into one position, if save filesize becomes an issue.
  local savedChunk = {["objects"]={}}
  for i,object in pairs(universe.objects) do
    local objectData = {}
    for dataType,data in pairs(object) do
      if global.saveableData[dataType] ~= nil then
        table.insert(objectData,{[dataType]=data})
      end
    end
    print(object.position)
    local compressedObject = {devname=object.devname,data=object.flags,position={object.position:unpack()}}
    table.insert(savedChunk.objects,compressedObject)
  end
  love.filesystem.createDirectory(universe.index.."/chunks/")
  local file = love.filesystem.newFile(chunk.chunkPosition:__tostring())
  love.filesystem.write(universe.index.."/chunks/"..chunk.chunkPosition:__tostring(),lunajson.encode(savedChunk))
  global.chunkFiles[chunk.chunkPosition:__tostring()] = 1
end
function global.loadChunk(universe,chunkPosition)
  local chunkData = love.filesystem.read(universe.index.."/chunks/"..chunkPosition:__tostring())
  local chunk = chunkObject:new(chunkPosition)
  chunkData = lunajson.decode(chunkData)
  if chunkData ~= nil then
    for i,value in pairs(chunkData) do
      for i,object in pairs(value) do
        local newObject = classFactory.getObject(object.devname)
        if object.position ~= nil then
          newObject.position = vector(object.position[1],object.position[2],object.position[3])
        end
        table.insert(universe.objects,newObject)
      end
    end
  end
  return chunk
end
function global.saveGame()
end

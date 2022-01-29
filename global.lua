global = {}

global.noiseSettings = {}
global.noiseSettings.tolerance = 0.5
global.font = love.graphics.newFont("LiberationSans-Italic.ttf",30)
global.chunkSize = 8
global.height = 4
global.chunkUnloadDistance = 4
global.currentUniverse = 0
global.currentActor = 0
global.gameSprites = {}
global.multiverse = {}
global.spriteDistancing = 128
global.spriteScaling = 0.5
global.keyBindings = {["up"]="moveup",['down']="movedown",['left']="moveleft",['right']="moveright",w="moveup",s='movedown',d='moveright',a='moveleft',["k"]="stepback",["l"]="stepforward",[","]="climbup",["."]="climbdown"}
function global.initializeGame()
  local sprites = love.filesystem.getDirectoryItems("/sprites")
  classFactory.init()
  for index,sprite in pairs(sprites) do
    local spriteSlot = tonumber(string.sub(sprite,1,4))
    global.gameSprites[spriteSlot] = love.graphics.newImage("/sprites/"..sprite) 
  end
  global.multiverse[0] = universe:new(0)
end


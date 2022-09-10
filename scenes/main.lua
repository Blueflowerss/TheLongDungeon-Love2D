--[[
Scene usage example
]]
require "scene"

local cameraOffset = vector(0,0)
--Init
local s = {}
local reverseTable = functions.reverseTable
local createAndInsertTable = functions.createAndInsertTable
local height,width = love.graphics.getDimensions()
local floor = math.floor
local ceil = math.ceil
local saveTimer = 0
skyValue1 = {(width/50),(height/50)}
skyValue2 = {(width/66.6),(height/66.6)}
print(inspect(skyValue2))
function s.quit()
  print("exiting")
end
function s.load()
  love.keyboard.setKeyRepeat(true)
  processCollisions(global.multiverse[global.currentUniverse])
  global.multiverse[global.currentUniverse].actors[global.currentActor] = playerObject:new(global.playerSpawnPoint)
end
function s.unload()

end
function s.draw()
  generateVisible()
  local player = global.multiverse[global.currentUniverse].actors[global.currentActor]
  local height,width = love.graphics.getDimensions()
  local resolution = vector(height,width)
  local renderStack = {}
  cameraOffset = player.position *-global.spriteDistancing * global.spriteScaling
  local collisionMap = global.multiverse[global.currentUniverse].collisionMap
  local backroundCanvas = love.graphics.newCanvas(resolution.x*2,resolution.y*2)
  love.graphics.setCanvas(backroundCanvas)
  love.graphics.push()
  love.graphics.scale(2)
  love.graphics.setColor({0,1.5,1})
  
  for x=-1,resolution.x/32 do
    for y=-1,resolution.y/32 do
      local mask = player.position+vector(x,y)-vector(skyValue2[1] ,skyValue2[2])
      mask = mask:ceil()
      if collisionMap[mask:__tostring()] == nil and collisionMap[(mask-vector(0,0,1)):__tostring()] == nil then
          love.graphics.rectangle("fill",ceil((x*32)+skyValue1[1]),ceil((y*32)+skyValue1[2]),32,32)
      end

    end
  end
  love.graphics.setColor({255,255,255})
  love.graphics.pop()
  love.graphics.setCanvas()
  createAndInsertTable(renderStack,0,{backroundCanvas,0,0})
  if visible then
    for objectPos,object in pairs(visible) do
      if collisionMap[objectPos] then
        for _,object in pairs(collisionMap[objectPos]) do
          if object.sprite ~= nil then
            local renderCommand = {global.gameSprites[object.sprite],object.position.x*global.spriteDistancing*global.spriteScaling+cameraOffset.x+resolution.x,object.position.y*global.spriteDistancing*global.spriteScaling+cameraOffset.y+resolution.y}
            if object.renderLayer ~= nil then
              createAndInsertTable(renderStack,object.renderLayer,renderCommand)
            else
              createAndInsertTable(renderStack,2,renderCommand)
            end
          end
        end
      end
    end
  end
  createAndInsertTable(renderStack,1,{love.graphics.newText(global.font,player.position:__tostring()),10,10})
  createAndInsertTable(renderStack,1,{love.graphics.newText(global.font,global.buildSlotName),10,30})
  reverseTable(renderStack)
  love.graphics.scale(global.spriteScaling)
  for _,renderLayer in pairs(renderStack) do
    for _,renderCommand in pairs(renderLayer) do
      love.graphics.draw(renderCommand[1],renderCommand[2],renderCommand[3])
    end
  end
end
function s.keypressed(key)
  input:processInput(key)
end
function s.keyreleased(key)
end
function s.update(dt)
  saveTimer = saveTimer + dt 
  if saveTimer > 60 then
    
  end
  for i,universe in pairs(global.multiverse) do
    processCollisions(universe)
  end
  for i,actor in pairs(global.multiverse[global.currentUniverse].actors) do
    actor:update(dt)
  end

end
--[[function s.quit()
    print "exiting..."
end]]
function s.resize(w,h)
  skyValue1 = {(w/50),(h/50)}
  skyValue2 = {(w/66.6),(h/66.6)}
end
return s

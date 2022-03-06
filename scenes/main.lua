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
function s.load()
  love.keyboard.setKeyRepeat(true)
  global.multiverse[global.currentUniverse]:processCollisions()
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
  local collisionMap = global.multiverse[0].collisionMap
  local backroundCanvas = love.graphics.newCanvas(resolution.x*2,resolution.y*2)
  love.graphics.setCanvas(backroundCanvas)
  love.graphics.push()
  love.graphics.scale(2)
  love.graphics.setColor({0,1.5,1})
  
  for x=-1,resolution.x/32 do
    for y=-1,resolution.y/32 do
      local mask = player.position+vector(x,y)-vector(12,9)
      if collisionMap[mask:__tostring()] == nil and collisionMap[(mask-vector(0,0,1)):__tostring()] == nil then
          love.graphics.rectangle("fill",(x*32)+16,(y*32)+12,32,32)
      end

    end
  end
  love.graphics.setColor({255,255,255})
  love.graphics.pop()
  love.graphics.setCanvas()
  createAndInsertTable(renderStack,-2,{backroundCanvas,0,0})
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
  for i,universe in pairs(global.multiverse) do
    universe:processCollisions()
  end
  for i,actor in pairs(global.multiverse[global.currentUniverse].actors) do
    actor:update(dt)
  end

end
--[[function s.quit()
    print "exiting..."
end]]

return s

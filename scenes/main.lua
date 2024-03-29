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
function s.quit()
  for i,chunk in pairs(global.multiverse[global.currentUniverse].bodies[global.currentPlanet].chunks) do
    if chunk.altered then
      worldFunctions.saveChunk(global.multiverse[global.currentUniverse],global.multiverse[global.currentUniverse].bodies[global.currentPlanet],chunk)
    end
  end
  global.playerData.position = global.multiverse[global.currentUniverse].bodies[global.currentPlanet].actors[global.currentActor].position:array()
  global.playerData.world = global.currentUniverse
  global.playerData.planet = global.currentPlanet
  global.playerData.timer = timer
  love.filesystem.write("playerData.json",lunajson.encode(global.playerData))
  print("exiting")
end
function s.load()
  love.keyboard.setKeyRepeat(true)
  global.cameraPosition = global.multiverse[global.currentUniverse].bodies[global.currentPlanet].actors[global.currentActor].position
  processCollisions(global.multiverse[global.currentUniverse].bodies[global.currentPlanet])
  
end
function s.unload()

end
local frameRateTime = 0
function s.draw()
  generateVisible()
  local player = global.multiverse[global.currentUniverse].bodies[global.currentPlanet].actors[global.currentActor]
  local height,width = love.graphics.getDimensions()
  local resolution = vector(height,width)
  local renderStack = {}
  if player then
    global.cameraPosition = player.position
  end
  cameraOffset = global.cameraPosition*-global.spriteDistancing * global.spriteScaling
  local collisionMap = global.multiverse[global.currentUniverse].bodies[global.currentPlanet].collisionMap
  love.graphics.push()
  love.graphics.setColor({0,1.5,1})
  love.graphics.setShader()
  love.graphics.setColor({255,255,255})
  love.graphics.pop()
  love.graphics.setCanvas()
  drawToCanvas(renderStack,0)
  if visible then
    for objectPos,object in pairs(visible) do
      if collisionMap[objectPos] then
        for _,object in pairs(collisionMap[objectPos]) do
          if object.sprite ~= nil then
            if object.modulate then
              love.graphics.setShader(modulate)
              modulate:send("r",object.modulate[1])
              modulate:send("g",object.modulate[2])
              modulate:send("b",object.modulate[3])
            end
            if object.visibleTo then
              if player.flags[object.visibleTo] then
                if object.renderLayer ~= nil then
                  drawToCanvas(renderStack,object.renderLayer)
                else
                  drawToCanvas(renderStack,2)
                end
                love.graphics.draw(global.gameSprites[object.sprite],object.position.x*global.spriteDistancing*global.spriteScaling+cameraOffset.x+resolution.x,object.position.y*global.spriteDistancing*global.spriteScaling+cameraOffset.y+resolution.y)
              end
            else
              if object.renderLayer ~= nil then
                drawToCanvas(renderStack,object.renderLayer)
              else
                drawToCanvas(renderStack,2)
              end
              love.graphics.draw(global.gameSprites[object.sprite],object.position.x*global.spriteDistancing*global.spriteScaling+cameraOffset.x+resolution.x,object.position.y*global.spriteDistancing*global.spriteScaling+cameraOffset.y+resolution.y)
            end
          end
          love.graphics.setShader()
        end
      end
    end
  end
  love.graphics.setShader()
  --sky shader

  --
  drawToCanvas(renderStack,1)
  love.graphics.draw(love.graphics.newText(global.font,global.cameraPosition:__tostring()),10,10)
  love.graphics.draw(love.graphics.newText(global.font,global.buildSlotName),10,30)
  love.graphics.scale(global.spriteScaling)
  love.graphics.setCanvas()
  reverseTable(renderStack)
  for _,renderLayer in pairs(renderStack) do
    love.graphics.draw(renderLayer)
    --without this new canvases will be created and clog up the memory
    renderLayer:release()
  end
end
function s.keypressed(key)
  input:processInput(key)
end
function s.keyreleased(key)
end
function s.update(dt)
  frameRateTime = frameRateTime + 1
  if frameRateTime >= tick.framerate/2 then
    timer = timer + 1
    frameRateTime = 0
  end
  for i,universe in pairs(global.multiverse) do
    for i,planet in pairs(universe.bodies) do
      processCollisions(planet)
      for i,object in pairs(planet.processables) do
        global.processObject(object)
      end
      for i,actor in pairs(planet.actors) do
        actor:update(dt)
      end

    end
  end

end
--[[function s.quit()
    print "exiting..."
end]]
return s

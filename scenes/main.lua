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
  local backroundCanvas = love.graphics.newCanvas(resolution.x*2,resolution.y*2)
  love.graphics.setCanvas(backroundCanvas)
  love.graphics.push()
  love.graphics.scale(2)
  love.graphics.setColor({0,1.5,1})
  
--  for x=-1,resolution.x/32 do
--    for y=-1,resolution.y/32 do
--      local mask = player.position+vector(x,y)-vector(skyValue2[1] ,skyValue2[2])
--      mask = mask:ceil()
--      if collisionMap[mask:__tostring()] == nil and collisionMap[(mask-vector(0,0,1)):__tostring()] == nil then
--          love.graphics.rectangle("fill",ceil((x*32)+skyValue1[1]),ceil((y*32)+skyValue1[2]),32,32)
--      end
--
--    end
--  end
  love.graphics.setColor({255,255,255})
  love.graphics.pop()
  love.graphics.setCanvas()
  createAndInsertTable(renderStack,0,{backroundCanvas,0,0})
  if visible then
    for objectPos,object in pairs(visible) do
      if collisionMap[objectPos] then
        for _,object in pairs(collisionMap[objectPos]) do
          if object.sprite ~= nil then
            if object.visibleTo then
              if player.flags[object.visibleTo] then
                local renderCommand = {global.gameSprites[object.sprite],object.position.x*global.spriteDistancing*global.spriteScaling+cameraOffset.x+resolution.x,object.position.y*global.spriteDistancing*global.spriteScaling+cameraOffset.y+resolution.y}
                if object.renderLayer ~= nil then
                  createAndInsertTable(renderStack,object.renderLayer,renderCommand)
                else
                  createAndInsertTable(renderStack,2,renderCommand)
                end
              end
            else
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
  end
  createAndInsertTable(renderStack,1,{love.graphics.newText(global.font,global.cameraPosition:__tostring()),10,10})
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

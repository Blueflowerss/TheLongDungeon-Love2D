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
function generateVisible()
  local tw,th      = 8,8
  local px,py      = 1,1
  local radius     = 20
  local radius_type= 'square'
  local perm       = 5
  local angle      = 0
  local angle_size = 360
  local delta      = 5
  local width      = 800
  local height     = 800
  local player = global.multiverse[global.currentUniverse].actors[global.currentActor]
  local collisionMap = global.multiverse[global.currentUniverse].collisionMap
  visible = {}
	
	local isTransparent = function(x,y)
    local position = vector(x,y,player.position.z):__tostring()
    if collisionMap[position] then
      for _,object in pairs(collisionMap[position]) do
        if object.flags["blocks"] == nil then
          return collisionMap[position] 
        end
      end
    else
      return true
    end
		
	end
	
	local onVisible = function(x,y)
		local dx,dy = x-px,y-py
		if (dx*dx + dy*dy) > radius*radius + radius and radius_type == 'circle' then 
			return 
		end
		
		visible[vector(x,y,player.position.z):__tostring()]    = visible[vector(x,y,player.position.z):__tostring()] or {}
		visible[vector(x,y,player.position.z):__tostring()] = 1
	end
		
	fov(player.position.x,player.position.y,radius,isTransparent,onVisible,math.rad(angle-angle_size/2),math.rad(angle+angle_size/2),perm)
  print(inspect(visible))

end
function s.draw()
  generateVisible()
  local player = global.multiverse[global.currentUniverse].actors[global.currentActor]
  local height,width = love.graphics.getDimensions()
  local resolution = vector(height,width)
  local renderStack = {}
  cameraOffset = player.position *-global.spriteDistancing * global.spriteScaling
  local collisionMap = global.multiverse[0].collisionMap
--  for _,objectList in pairs(collisionMap) do
--    for _,object in pairs(objectList) do
--      if object.position.z == player.position.z then
--        if object.sprite ~= nil then
--          local renderCommand = {global.gameSprites[object.sprite],object.position.x*global.spriteDistancing*global.spriteScaling+cameraOffset.x+resolution.x,object.position.y*global.spriteDistancing*global.spriteScaling+cameraOffset.y+resolution.y}
--          if object.renderLayer ~= nil then
--            createAndInsertTable(renderStack,object.renderLayer,renderCommand)
--          else
--            createAndInsertTable(renderStack,2,renderCommand)
--          end
--        end
--      end
--    end
--  end
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
--[[
Scene usage example
]]
require "scene"
local reverseTable = functions.reverseTable
local createAndInsertTable = functions.createAndInsertTable
--Init
local s = {}
function s.load ()
  space.viewingUniverse = global.currentUniverse
  space.viewingPlanet = global.currentPlanet
  space.viewingTime = timer
  space.bodies = functions.generatePlanets(5,space.viewingUniverse)
  updateSpaceMenu()
end
function updateSpaceMenu()
  space.dateString = get_date_from_unix(space.viewingTime)
end
function s.unload()

end
function s.draw()
    local renderStack = {}
    local height,width = love.graphics.getDimensions()
    local resolution = vector(height,width)
    local planet = space.viewingPlanet
    space.centralCircle = {
      middleHeight = height/2,
      middleWidth = width/2,
      radius =  (height*width)/5000
    }
    local currentPlanetPosition = pointOnACircle(space.bodies[planet].orbitRadius,space.centralCircle.middleHeight+space.offset.y,space.centralCircle.middleWidth+space.offset.x,0.0001*space.viewingTime*space.bodies[planet].orbitalSpeed)
    local planetPositions = {}
    for i,v in pairs(space.bodies) do
      local planetType = global.planetTypes[v.type][v.variant]
      if i == planet then
        love.graphics.setColor(0.2,1,0.2)
      else
        love.graphics.setColor(0.2,0.2,0.2)
      end
      -- draw orbit line
      createAndInsertTable(renderStack,3,love.graphics.circle("line",space.centralCircle.middleHeight+space.offset.y,space.centralCircle.middleWidth+space.offset.x,v.orbitRadius*space.centralCircle.radius/100))
      -- find position on the orbit line
      local point = pointOnACircle(v.orbitRadius*space.centralCircle.radius/100,space.centralCircle.middleHeight,space.centralCircle.middleWidth,0.0001*space.viewingTime*v.orbitalSpeed)
      
      planetPositions[v.type] = point
      love.graphics.setColor(planetType.color)
      --draw planet
      createAndInsertTable(renderStack,3,love.graphics.circle("fill",point.x,point.y,v.planetSize))
      love.graphics.setColor(1,1,1)
    end
    createAndInsertTable(renderStack,3,love.graphics.print(tostring(space.viewingUniverse),width/2,20)) 
    createAndInsertTable(renderStack,3,love.graphics.print(space.dateString,width/2,40)) 
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

end
--[[function s.quit()
    print "exiting..."
end]]

return s 

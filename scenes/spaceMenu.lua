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
  space.bodies = functions.generatePlanets(5,space.viewingUniverse)
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
    local currentPlanetPosition = pointOnACircle(space.bodies[planet].orbitRadius,space.centralCircle.middleHeight+space.offset.y,space.centralCircle.middleWidth+space.offset.x,timer*space.bodies[planet].orbitalSpeed)
    for i,v in pairs(space.bodies) do
      if i == planet then
        love.graphics.setColor(0.2,1,0.2)
      else
        love.graphics.setColor(0.2,0.2,0.2)
      end
      createAndInsertTable(renderStack,3,love.graphics.circle("line",space.centralCircle.middleHeight+space.offset.y,space.centralCircle.middleWidth+space.offset.x,v.orbitRadius*space.centralCircle.radius/100))
      love.graphics.setColor(1,1,1)
      local point = pointOnACircle(v.orbitRadius*space.centralCircle.radius/100,space.centralCircle.middleHeight,space.centralCircle.middleWidth,timer+v.orbitalSpeed)
      createAndInsertTable(renderStack,3,love.graphics.circle("fill",point.x,point.y,v.planetSize))
    end
    love.graphics.setColor(2,44,55)
    createAndInsertTable(renderStack,3,love.graphics.print(tostring(space.viewingUniverse),width/2,20)) 
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

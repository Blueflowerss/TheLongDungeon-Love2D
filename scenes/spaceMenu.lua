--[[
Scene usage example
]]
require "scene"
local reverseTable = functions.reverseTable
local createAndInsertTable = functions.createAndInsertTable
--Init
local s = {}

function s.load ()
local system = {}
value = 0
end
function s.unload()

end
function s.draw()
    value = value + 0.1
    local renderStack = {}
    local height,width = love.graphics.getDimensions()
    local resolution = vector(height,width)
    local bodies = global.multiverse[global.currentUniverse].bodies
    local planet = global.currentPlanet
    local circle = {
      middleHeight = height/2,
      middleWidth = width/2,
      radius =  (height*width)/5000
    }
    local currentPlanetPosition = pointOnACircle(bodies[planet].radius,circle.middleHeight,circle.middleWidth,value)
    for i,v in pairs(bodies) do
      createAndInsertTable(renderStack,3,love.graphics.circle("line",circle.middleHeight,circle.middleWidth,v.radius*circle.radius/100))
      local point = pointOnACircle(v.radius,circle.middleHeight,circle.middleWidth,value)
      createAndInsertTable(renderStack,3,love.graphics.circle("fill",point.x,point.y,2))
    end
    love.graphics.setColor(2,44,55)
    createAndInsertTable(renderStack,3,love.graphics.circle("fill",currentPlanetPosition.x,currentPlanetPosition.y,10))
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

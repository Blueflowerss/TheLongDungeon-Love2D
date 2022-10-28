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
    local circle = {
      middleHeight = height/2,
      middleWidth = width/2,
      radius =  (height*width)/5000
    }
    for i,v in pairs(global.multiverse[global.currentUniverse].bodies) do
      createAndInsertTable(renderStack,3,love.graphics.circle("line",circle.middleHeight,circle.middleWidth,v.radius*circle.radius/100))
      local point = pointOnACircle(v.radius,circle.middleHeight,circle.middleWidth,value)
      createAndInsertTable(renderStack,3,love.graphics.circle("fill",point.x,point.y,2))
    end
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

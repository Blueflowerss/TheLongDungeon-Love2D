--[[
Scene usage example
]]
require "scene"
local reverseTable = functions.reverseTable
local createAndInsertTable = functions.createAndInsertTable
--Init
local s = {}
function s.load ()
end
function updateSpaceMenu()
end
function s.unload()

end
function s.draw()
    local worldMap = {}
    local renderStack = {}
    local height,width = love.graphics.getDimensions()
    local resolution = vector(height,width)
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

end
--[[function s.quit()
    print "exiting..."
end]]

return s 

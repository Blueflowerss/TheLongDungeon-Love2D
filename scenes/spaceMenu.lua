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
  space.offset = vector()
  space.zoom = 1
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
    local bodyCount = 0
    for i,v in pairs(space.bodies) do
      bodyCount = bodyCount + 1
    end
    local parentalBodies = {}
    for i,v in pairs(space.bodies) do
      local planetVariant = global.planetTypes[v.type].variants[v.variant]
      local planetType = global.planetTypes[v.type]
      if i == planet then
        love.graphics.setColor(0.2,1,0.2)
      else
        love.graphics.setColor(0.2,0.2,0.2)
      end
      --cycle 1 - draw all planets without parents
      if v.parent == nil then
        -- draw orbit line
        drawToCanvas(renderStack,5)
        love.graphics.circle("line",(space.centralCircle.middleHeight+space.offset.x)*space.zoom,(space.centralCircle.middleWidth+space.offset.y)*space.zoom,(v.orbitRadius*space.centralCircle.radius/100)*space.zoom)
        -- find position on the orbit line
        local point = pointOnACircle(v.orbitRadius*space.centralCircle.radius/100,space.centralCircle.middleHeight,space.centralCircle.middleWidth,0.0001*space.viewingTime*v.orbitalSpeed+planetType.orbitAhead)
        
        planetPositions[v.type] = point
        love.graphics.setColor(planetVariant.color)
        --draw planet
        drawToCanvas(renderStack,3)
        love.graphics.circle("fill",(point.x+space.offset.x)*space.zoom,(point.y+space.offset.y)*space.zoom,v.planetSize*space.zoom)
        --decrement parentless bodies
        bodyCount = bodyCount - 1
      else
        table.insert(parentalBodies,v.type)
      end
      
      love.graphics.setColor(1,1,1)
    end
    --cycle 2 - draw all parental bodies
    local count = 0
    while count <= bodyCount do
      for i,planet in pairs(parentalBodies) do
        local planetType = space.bodies[planet]
        local parentPlanet = space.bodies[planetType.parent]
        if planetPositions[planet] then
          count = count + 1
        elseif planetPositions[parentPlanet.type] then
          local parentPosition = planetPositions[parentPlanet.type]
          local point = pointOnACircle(planetType.orbitRadius,parentPosition.x,parentPosition.y,0.0001*space.viewingTime*planetType.orbitalSpeed+planetType.orbitalAhead)
          planetPositions[planet] = point
        end
      end
    end
    for planetName,planetPosition in pairs(planetPositions) do
      local planetType = space.bodies[planetName]
      local parentPosition = planetPositions[planetType.parent]
      if planetType.parent then
        drawToCanvas(renderStack,5)
        love.graphics.circle("line",(parentPosition.x+space.offset.x)*space.zoom,(parentPosition.y+space.offset.y)*space.zoom,planetType.orbitRadius*space.zoom)
        drawToCanvas(renderStack,3)
        love.graphics.circle("fill",(planetPosition.x+space.offset.x)*space.zoom,(planetPosition.y+space.offset.y)*space.zoom,planetType.planetSize*space.zoom)
      end
    end
    love.graphics.print(tostring(space.viewingUniverse),width/2,20) 
    love.graphics.print(space.dateString,width/2,40)
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

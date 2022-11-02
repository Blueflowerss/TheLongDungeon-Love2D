universe = {}
universe.__index = universe
local createAndInsertTable = functions.createAndInsertTable
function universe:new(index,vectorOfSpawn)
    local o = {}
    o.collisionMap = {}
    o.bodies = functions.generatePlanets(global.planetAmount,index)
    o.index = index
    o.chunks = {}
    o.actors = {}
    o.objects = {}
    return o
end
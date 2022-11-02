universe = {}
universe.__index = universe
local createAndInsertTable = functions.createAndInsertTable
function universe:new(index,vectorOfSpawn)
    local o = {}
    o.bodies = functions.generatePlanets(global.planetAmount,index)
    o.index = index
    return o
end
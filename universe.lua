universe = {}
universe.__index = universe
local createAndInsertTable = functions.createAndInsertTable
function universe:new(index)
    local o = {}
    o.collisionMap = {}
    o.chunks = {}
    o.index = index
    o.actors = {}
    o.objects = {}
    worldFunctions.chunkGeneration(global.playerSpawnPoint,3,o)
    
    return o
end
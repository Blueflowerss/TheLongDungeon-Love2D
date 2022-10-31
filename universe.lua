universe = {}
universe.__index = universe
local createAndInsertTable = functions.createAndInsertTable
function universe:new(index,vectorOfSpawn)
    local o = {}
    o.collisionMap = {}
    o.chunks = {}
    o.index = index
    o.actors = {}
    o.objects = {}
    o.bodies = {}
    --temporary for now
    o.bodies[1] = {radius=0.1, color=255}
    o.bodies[2] = {radius=20,color=144}
    o.bodies[3] = {radius=37,color=144}
    return o
end
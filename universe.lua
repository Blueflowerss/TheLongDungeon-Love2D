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
    o.bodies["sun"] = {radius=0.1, color=255}
    o.bodies["body1"] = {radius=20,color=144}
    o.bodies["body2"] = {radius=37,color=144}
    return o
end
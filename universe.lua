universe = {}
universe.__index = universe
local createAndInsertTable = functions.createAndInsertTable
function universe:new(index)
    local o = {}
    function o:processCollisions() 
      o.collisionMap = {}
      for chunkPos,chunk in pairs(o.chunks) do
        for objectIndex,object in pairs(chunk.objects) do
          createAndInsertTable(o.collisionMap,object.position:__tostring(),object)
        end
      end
      for actorIndex,actor in pairs(o.actors) do
        createAndInsertTable(o.collisionMap,actor.position:__tostring(),actor)
      end
    end
    o.chunks = {}
    o.index = index
    o.actors = {}
    for x=1,10 do
      for y=1,10 do
        o.chunks[vector(x,y)] = chunkObject:new(vector(x,y))
      end
    end
    return o
end
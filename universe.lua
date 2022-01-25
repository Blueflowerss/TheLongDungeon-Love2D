universe = {}
universe.__index = universe
 
function universe:new(index)
    local o = {}
    function o:processCollisions() 
      o.collisionMap.lookup = {}
      o.collisionMap.collisions={}
      for chunkPos,chunk in pairs(o.chunks) do
        for objectIndex,object in pairs(chunk.objects) do
          o.collisionMap:insert(vector(object.position.x,object.position.y),object)
        end
      end
      for actorIndex,actor in pairs(o.actors) do
        o.collisionMap:insert(actor.position,actor)
      end
    end
    o.chunks = {}
    o.index = index
    o.collisionMap = {lookup={},collisions={}}
    function o.collisionMap:insert(pos,object)
      if o.collisionMap.lookup[pos] == nil then
        o.collisionMap.collisions[pos] = {}
        table.insert(o.collisionMap.collisions[pos],object)
        o.collisionMap.lookup[pos] = true
      else 
        table.insert(o.collisionMap.collisions[pos],object)
      end
    end
    function o.collisionMap:getList(pos)
      if o.collisionMap.lookup[pos] then
        return o.collisionMap.collisions[pos]
      else
        return {}
      end
    end
    o.actors = {}
    for x=1,10 do
      for y=1,10 do
        o.chunks[vector(x,y)] = chunkObject:new(vector(x,y))
      end
    end
    for i,v in pairs(o.chunks) do
      for x=1,4 do
        for y=1,4 do
          table.insert(v.objects,tileObject:new(vector(x*global.chunkSize,y*global.chunkSize,1),400))
        end
      end
    end
    return o
end
playerObject = {}
 
function playerObject:new(x,y,z)
    local o = {}
    o.sprite = 3
    o.renderLayer = 1
    o.position = vector(x,y,z)
    o.walkingTo = o.position
    o.playerLastChunk = o.position / global.chunkSize
    function o:move(moveVector)
      o.walkingTo = o.position+moveVector
    end
    function o:update(dt)
      if o.position ~= o.walkingTo then
        local direction = (o.walkingTo-o.position):norm()
        local tile = global.multiverse[global.currentUniverse].collisionMap[o.position+direction]
        if tile ~= nil then
          print(tile)
        end
        o.position = o.position + direction
      end
      local chunkPosition = (o.position/global.chunkSize):floor()
      if o.playerLastChunk ~= chunkPosition then
        worldFunctions.chunkGeneration((o.position/global.chunkSize):floor(),3,global.multiverse[global.currentUniverse])
        o.playerLastChunk = chunkPosition
      end
    end
    return o
end
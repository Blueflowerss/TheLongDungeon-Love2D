playerObject = {}
 
function playerObject:new(x,y)
    local o = {}
    o.sprite = 3
    o.renderLayer = 1
    o.position = vector(x,y)
    o.playerLastChunk = o.position / global.chunkSize
    function o:move(moveVector)
      o.position = o.position+moveVector
    end
    function o:update(dt)
      local chunkPosition = (o.position/global.chunkSize):floor()
      if o.playerLastChunk ~= chunkPosition then
        worldFunctions.chunkGeneration((o.position/global.chunkSize):floor(),3,global.multiverse[global.currentUniverse])
        o.playerLastChunk = chunkPosition
      end
    end
    return o
end
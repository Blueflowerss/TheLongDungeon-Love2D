playerObject = {}
 
function playerObject:new(x,y,z)
    local o = {}
    o.sprite = 3
    o.renderLayer = 1
    o.flags = {}
    o.position = vector(x,y,z)
    o.walkingTo = o.position
    o.playerLastChunk = o.position / global.chunkSize
    function o:move(moveVector)
      o.walkingTo = o.position+moveVector
    end
    function o:update(dt)
      if o.position ~= o.walkingTo then
        local direction = (o.walkingTo-o.position):norm()
        objectList = global.multiverse[global.currentUniverse].collisionMap
        local blocked = false
        if objectList[(o.position+direction):__tostring()] ~= nil then
          local tile = objectList[(o.position+direction):__tostring()]
          for _,object in pairs(tile) do
            if object.flags["blocks"] then
                blocked = true
              break
            end
          end
        else
          o.position = (o.position+direction-vector(0,0,1))
          o.walkingTo = o.position
        end
        if not blocked then
          o.position = o.position + direction
        else
          --walking up hills
          local ceilingBlocked = false
          local tile = objectList[(o.position+vector(0,0,1)):__tostring()]
          if tile ~= nil then
            for _,object in pairs(tile) do
              if object.flags["floor"] then
                ceilingBlocked = true
                break
              end
            end
          end
          if not ceilingBlocked then
            local blockedByHigherWall = false
            tile = objectList[(o.position+direction+vector(0,0,1)):__tostring()]
            if tile ~= nil then
              for _,object in pairs(tile) do
                if object.flags["blocks"] then
                  blockedByHigherWall = true
                  break
                end
              end
              if not blockedByHigherWall then
                o.position = (o.position+direction+vector(0,0,1))
              end
            end
          end
        end
      end
      
      local chunkPosition = (vector(o.position.x,o.position.y)/global.chunkSize):floor()
      if o.playerLastChunk ~= chunkPosition then
        worldFunctions.chunkGeneration((o.position/global.chunkSize):floor(),3,global.multiverse[global.currentUniverse])
        o.playerLastChunk = chunkPosition
      end
    end
    return o
end
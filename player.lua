playerObject = {}
local floor = math.floor
function playerObject:new(spawnVector)
    local o = {}
    o.sprite = 3
    o.renderLayer = 1
    o.flags = {}
    o.position = spawnVector
    o.walkingTo = o.position
    o.playerLastChunk = o.position
    o.gravity = vector(0,0,1)
    function o:move(moveVector)
      o.walkingTo = o.position+moveVector
    end
    function o:update(dt)
      --global.cameraPosition = o.position
      local chunkPosition = (vector(o.position.x/global.chunkSize,o.position.y/global.chunkSize,o.position.z/global.height)):floor()
      if o.playerLastChunk ~= chunkPosition then
        worldFunctions.chunkGeneration(o.position,3,global.multiverse[global.currentUniverse])
        o.playerLastChunk = chunkPosition
      end
      local objectList = global.multiverse[global.currentUniverse].collisionMap
      local tile =  objectList[o.position:__tostring()]
        local falling = true
      for _,object in pairs(tile) do
        if object.flags["floor"] then
          falling = false
          break
        end
      end
      if falling and not global.gravityToggle then
        o.position = o.position-o.gravity
        o.walkingTo = o.position
        if o.position.z < 0 then
          o.position.z = 100
        end
      end
      if o.position ~= o.walkingTo then
        local direction = ((o.walkingTo-o.position):norm()):specialCeil()
        local blocked = false
        if objectList[(o.position+direction):__tostring()] then
          local tile = objectList[(o.position+direction):__tostring()]
          for _,object in pairs(tile) do
              if object.flags["blocks"] then
                blocked = true
                break
              end
        end
        else
        end
        if not blocked then
          o.position = o.position + direction
        else
          local onRamp = true
          --for _,object in pairs(tile) do
          --  if object.flags["ramp"] then
          --    onRamp = true
          --    break
          --  end
          --end
            if onRamp then
            --walking up hills
            local ceilingBlocked = false
            local tile = objectList[(o.position+vector(0,0,1)):__tostring()]
            if tile then
              for _,object in pairs(tile) do
                if object.flags["floor"] or object.flags["blocks"] then
                  ceilingBlocked = true
                  break
                end
              end
            end
            if not ceilingBlocked then
              local blockedByHigherWall = false
              tile = objectList[(o.position+direction+vector(0,0,1)):__tostring()]
              if tile then
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
      end
      

    end
    return o
end

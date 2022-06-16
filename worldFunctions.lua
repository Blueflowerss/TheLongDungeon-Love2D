worldFunctions = {}
local noise = love.math.noise
local floor = math.floor
local ceil = math.ceil
local max = math.max
local clamp = functions.clamp
local generateTerrainNoise = functions.generateTerrainNoise
local normalize = functions.normalize
local isTileGenerated = {}
local isChunkGenerated = {}
function worldFunctions.chunkGeneration(centerOfRemovalVector,range,universeObject) 
  local centerOfRemoval = vector(centerOfRemovalVector.x/global.chunkSize,centerOfRemovalVector.y/global.chunkSize,centerOfRemovalVector.z/global.height):floor()
  local height = global.height
  for x=-range,range do
    for y=-range,range do
      for z=-height,height do
        local chunkPositionString = (centerOfRemoval+vector(x,y,z)):__tostring()
        local chunkPosition = centerOfRemoval+vector(x,y,z)
        if isChunkGenerated[chunkPositionString] == nil then
          if global.chunkFiles[chunkPositionString] == nil then
            local chunk = chunkObject:new(chunkPosition)
            worldFunctions.generateTerrain(chunk,universeObject)
            isChunkGenerated[chunk.chunkPosition:__tostring()] = true
            universeObject.chunks[chunk.chunkPosition:__tostring()] = chunk
          else
            local chunk = global.loadChunk(universeObject,chunkPosition)
            isChunkGenerated[chunk.chunkPosition:__tostring()] = true
            universeObject.chunks[chunk.chunkPosition:__tostring()] = chunk          
          end
        end
      end
    end 
  end
  local chunksToKeep = {}
  for chunkIndex,chunk in pairs(universeObject.chunks) do 
    local distanceFromPlayer = floor(chunk.chunkPosition.dist(centerOfRemoval,chunk.chunkPosition))
    if distanceFromPlayer <= global.chunkUnloadDistance then
      chunksToKeep[chunkIndex] = chunk
    else
      isChunkGenerated[chunk.chunkPosition:__tostring()] = nil 
      if chunk.altered then
        global.saveChunk(universeObject,chunk)
      end
      for x = 0,global.chunkSize do
        for y = 0,global.chunkSize do
          for z = 0,global.height do
            local position = vector(chunk.chunkPosition.x*global.chunkSize,chunk.chunkPosition.y*global.chunkSize,chunk.chunkPosition.z*global.height)+vector(x,y,z)
            local listPosition =universeObject.collisionMap[position:__tostring()]
            if listPosition ~= nil then
              for i,object in pairs(listPosition) do
                object.removed = true
              end
              isTileGenerated[position:__tostring()] = nil
            end
            
          end
        end
      end
    end
    universeObject.chunks[chunk.chunkPosition:__tostring()] = nil
  end
  universeObject.chunks = chunksToKeep
end
function worldFunctions.generateTerrain(chunk,universeObject) 
    local position = vector(chunk.chunkPosition.x*global.chunkSize,chunk.chunkPosition.y*global.chunkSize,chunk.chunkPosition.z*global.height)
    for x=0,global.chunkSize do
      for y=0,global.chunkSize do
        local height = generateTerrainNoise(3,x+position.x,y+position.y,global.currentUniverse)*global.heightMultiplier
        height = ceil(height)
          for z=0,global.height do
            local tilePosition = position+vector(x,y,z)
            if isTileGenerated[tilePosition:__tostring()] == nil and tilePosition.z<=height and tilePosition.z>= 0 then
              local tileType = ""
              if tilePosition.z == height then tileType = "ground" else tileType="wall" end
              local tile = classFactory.getObject(tileType)
              tile.position = tilePosition
              table.insert(universeObject.objects,tile) 
              isTileGenerated[tilePosition:__tostring()] = true
            end
          end
      end
    end
end
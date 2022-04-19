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
  --centerOfRemoval.z = 0
  local height = global.height
  for x=-range,range do
    for y=-range,range do
      for z=-height,height do
        if isChunkGenerated[(centerOfRemoval+vector(x,y,z)):__tostring()] == nil then
          local chunk = chunkObject:new(centerOfRemoval+vector(x,y,z))
          worldFunctions.generateTerrain(chunk)
          isChunkGenerated[chunk.chunkPosition:__tostring()] = true
          universeObject.chunks[chunk.chunkPosition:__tostring()] = chunk
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
        global.saveChunk(chunk)
      end
      for i,tile in pairs(chunk.objects) do
        isTileGenerated[tile.position:__tostring()] = nil
      end
      
    end
  end
  universeObject.chunks = chunksToKeep
end
function worldFunctions.generateTerrain(chunk) 
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
              table.insert(chunk.objects,tile) 
              isTileGenerated[tilePosition:__tostring()] = true
            end
          end
      end
    end
end
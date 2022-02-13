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
  local centerOfRemoval = (centerOfRemovalVector/global.chunkSize):floor()
  centerOfRemoval.z = 0
  for x=-range,range do
    for y=-range,range do
        if isChunkGenerated[(centerOfRemoval+vector(x,y)):__tostring()] == nil then
          local chunk = chunkObject:new(centerOfRemoval+vector(x,y))
          worldFunctions.generateTerrain(chunk)
          isChunkGenerated[chunk.chunkPosition:__tostring()] = true
          universeObject.chunks[chunk.chunkPosition:__tostring()] = chunk
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
      for i,tile in pairs(chunk.objects) do
        isTileGenerated[tile.position:__tostring()] = nil
      end
    end
  end
  universeObject.chunks = chunksToKeep
end
function worldFunctions.generateTerrain(chunk) 
    for x=1,global.chunkSize do
      for y=1,global.chunkSize do
        local height = generateTerrainNoise(3,x+chunk.chunkPosition.x,y+chunk.chunkPosition.y,global.currentUniverse)
        height = ceil(height)
          for z=0,height do
            if isTileGenerated[(vector(x,y,z)+chunk.chunkPosition*global.chunkSize):__tostring()] == nil then
              local tileType = ""
              if z == height then tileType = "ground" else tileType="wall" end
              local tile = classFactory.getObject(tileType)
              tile.position = (vector(x,y,z)+chunk.chunkPosition*global.chunkSize)
              table.insert(chunk.objects,tile) 
              isTileGenerated[tile.position:__tostring()] = true
            end
          end
      end
    end
end
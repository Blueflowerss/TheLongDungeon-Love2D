worldFunctions = {}
local noise = love.math.noise
local floor = math.floor
local max = math.max
function worldFunctions.chunkGeneration(centerOfRemovalVector,range,universeObject) 
  centerOfRemovalVector = centerOfRemovalVector
  lastChunk = universeObject.actors[global.currentActor].playerLastChunk
  for x=-range,range do
    for y=-range,range do
        if universeObject.chunks[centerOfRemovalVector+vector(x,y)] == nil then
          local chunk = chunkObject:new(centerOfRemovalVector+vector(x,y))
          worldFunctions.generateTerrain(chunk)
          
          universeObject.chunks[vector(x,y)+centerOfRemovalVector] = chunk
        end
    end
  end
  local chunksToRemove = {}
  for chunkIndex,chunk in pairs(universeObject.chunks) do 
    local distanceFromPlayer = floor(chunk.chunkPosition.dist(lastChunk,chunk.chunkPosition))
    if distanceFromPlayer >= global.chunkUnloadDistance then
      table.insert(chunksToRemove,chunkIndex)
    end
  end
  for _,toBeRemoved in pairs(chunksToRemove) do
    universeObject.chunks[toBeRemoved] = nil
  end
end
function worldFunctions.generateTerrain(chunk) 
    for x=1,global.chunkSize do
      for y=1,global.chunkSize do
        local noiseValue = functions.generateTerrainNoise(3,x+chunk.chunkPosition.x*global.chunkSize,y+chunk.chunkPosition.y*global.chunkSize,1,global.currentUniverse)
        if noiseValue >= global.noiseSettings.tolerance then
          table.insert(chunk.objects,tileObject:new((vector(x,y,1)+chunk.chunkPosition*global.chunkSize)))
        end
      end
    end
end
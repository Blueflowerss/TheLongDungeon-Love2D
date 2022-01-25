worldFunctions = {}
local noise = love.math.noise
local floor = math.floor
local max = math.max
function worldFunctions.chunkGeneration(centerOfRemovalVector,range,universeObject) 
  for x=-range,range do
    for y=-range,range do
        if universeObject.chunks[vector(x,y)+centerOfRemovalVector] == nil then
          local chunk = chunkObject:new(vector(x,y)+centerOfRemovalVector)
          worldFunctions.generateTerrain(chunk)
          universeObject.chunks[vector(x,y)+centerOfRemovalVector] = chunk
        end
    end
  end
  local chunksToRemove = {}
  for chunkIndex,chunk in pairs(universeObject.chunks) do 
    local distanceFromPlayer = floor(chunk.chunkPosition.dist(universeObject.actors[global.currentActor].playerLastChunk,chunk.chunkPosition))
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
        local noiseValue = 0
        noiseValue = noise(x+chunk.chunkPosition.x*global.chunkSize,y+chunk.chunkPosition.y*global.chunkSize)
        if noiseValue >= global.noiseSettings.tolerance then
          table.insert(chunk.objects,tileObject:new((vector(x,y)+chunk.chunkPosition*global.chunkSize)))
        end
      end
    end
end
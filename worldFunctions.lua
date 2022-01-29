worldFunctions = {}
local noise = love.math.noise
local floor = math.floor
local max = math.max
local clamp = functions.clamp
local generateTerrainNoise = functions.generateTerrainNoise
local normalize = functions.normalize
local isTileGenerated = {}
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
    for i,object in pairs(universeObject.chunks[toBeRemoved].objects) do
      isTileGenerated[object.position:__tostring()] = nil
    end
    universeObject.chunks[toBeRemoved] = nil
  end
end
function worldFunctions.generateTerrain(chunk) 
    for x=1,global.chunkSize do
      for y=1,global.chunkSize do
        local height = generateTerrainNoise(3,x+chunk.chunkPosition.x*global.chunkSize,y+chunk.chunkPosition.y*global.chunkSize,global.currentUniverse)
        height = floor(normalize(1,height*10,global.height))
          for z=1,height do
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
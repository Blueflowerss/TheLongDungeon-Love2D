worldFunctions = {}
local noise = love.math.noise
local floor = math.floor
local ceil = math.ceil
local max = math.max
local abs = math.abs
local clamp = functions.clamp
local generateTerrainNoise = functions.generateTerrainNoise
local normalize = functions.normalize
isTileGenerated = {}
isRampGenerated = {}
isChunkGenerated = {}
function worldFunctions.chunkGeneration(centerOfRemovalVector,range,universeObject,planet,generate)
  --centerOfRemoval is player's position 
  generate = generate or true
  local centerOfRemoval = vector(centerOfRemovalVector.x/global.chunkSize,centerOfRemovalVector.y/global.chunkSize,centerOfRemovalVector.z/global.height):floor()
  local height = global.height
  if generate then
    for x=-range,range do
      for y=-range,range do
        for z=-height,height do
          local chunkPositionString = (centerOfRemoval+vector(x,y,z)):__tostring()
          local chunkPosition = centerOfRemoval+vector(x,y,z)
          if isChunkGenerated[universeObject.index] == nil or isChunkGenerated[universeObject.index][planet.type] == nil then
            isChunkGenerated[universeObject.index] = {}
            isChunkGenerated[universeObject.index][planet.type] = {}
          end
          if isChunkGenerated[universeObject.index][planet.type][chunkPositionString] == nil then
            if love.filesystem.read(universeObject.index.."/"..planet.type.."/chunks/"..chunkPosition:__tostring()) == nil then
              local chunk = chunkObject:new(chunkPosition)
              worldFunctions.generateTerrain(chunk,universeObject,planet)
              isChunkGenerated[universeObject.index][planet.type][chunk.chunkPosition:__tostring()] = true
              planet.chunks[chunk.chunkPosition:__tostring()] = chunk
            else
              local chunk = worldFunctions.loadChunk(universeObject,planet,chunkPosition)
              isChunkGenerated[universeObject.index][planet.type][chunk.chunkPosition:__tostring()] = true
              planet.chunks[chunk.chunkPosition:__tostring()] = chunk    
            end
          end
        end
      end 
    end
  end
  local chunksToKeep = {}
  for chunkIndex,chunk in pairs(planet.chunks) do 
    local distanceFromPlayer = floor(chunk.chunkPosition.dist(centerOfRemoval,chunk.chunkPosition))
    if distanceFromPlayer <= global.chunkUnloadDistance then
      chunksToKeep[chunkIndex] = chunk
    else
      isChunkGenerated[universeObject.index][planet.type][chunk.chunkPosition:__tostring()] = nil 
      if chunk.altered then
        worldFunctions.saveChunk(universeObject,planet,chunk)
      end
      for i,object in pairs(chunk.objects) do
          object.removed = true
      end
      
    end
    planet.chunks[chunk.chunkPosition:__tostring()] = nil
  end
  
  planet.chunks = chunksToKeep
end
function worldFunctions.saveChunk(universe,planet,chunk)
  -- POSITION FIELD IS PREVENTING OBJECTS FROM SAVING, SOMETHING ABOUT IT NOT ENCOMPASSING THE OBJECTS
  --could couple multiple objects into one position, if save filesize becomes an issue.
  local savedChunk = {["objects"]={}}
  for i,object in pairs(chunk.objects) do
    local objectData = {}
    for dataType,data in pairs(object) do
      if global.saveableData[dataType] == 0 then
        objectData[dataType] = data
      end
    end
    local compressedObject = {devname=object.devname,data=object.flags,position={object.position:unpack()},data2=objectData}
    table.insert(savedChunk.objects,compressedObject)
  end
  love.filesystem.createDirectory(universe.index.."/"..planet.type.."/chunks/")
  local file = love.filesystem.newFile(chunk.chunkPosition:__tostring())
  love.filesystem.write(universe.index.."/"..planet.type.."/chunks/"..chunk.chunkPosition:__tostring(),lunajson.encode(savedChunk))
  global.chunkFiles[chunk.chunkPosition:__tostring()] = 1
end
function worldFunctions.loadChunk(universe,planet,chunkPosition)
  local chunkData = love.filesystem.read(universe.index.."/"..planet.type.."/chunks/"..chunkPosition:__tostring())
  local chunk = chunkObject:new(chunkPosition)
  if chunkData ~= nil then
    local chunkData = lunajson.decode(chunkData)
    for i,value in pairs(chunkData) do
      for i,object in pairs(value) do
        local newObject = classFactory.getObject(object.devname)
        for dataType,data in pairs(object.data2) do
          newObject[dataType] = data
        end
        if object.position ~= nil then
          newObject.position = vector(object.position[1],object.position[2],object.position[3])
        end
        table.insert(planet.objects,newObject)
        table.insert(chunk.objects,newObject)
      end
    end
  end
  return chunk
end
function worldFunctions.generateTerrain(chunk,universeObject,planet) 
    local position = vector(chunk.chunkPosition.x*global.chunkSize,chunk.chunkPosition.y*global.chunkSize,chunk.chunkPosition.z*global.height)
    local cachedNoise = {}
    for x=0,global.chunkSize do
      for y=0,global.chunkSize do
        local height = generateTerrainNoise(3,x+position.x,y+position.y,universeObject.index+string.byte(global.currentPlanet))*global.heightMultiplier
        local variant = global.planetTypes[planet.type].variants[planet.variant]
        height = ceil(height)
        local biome = global.biomes[planet.variant]
        cachedNoise[vector(x+position.x,y+position.y):__tostring()] = height
          for z=0,global.height do
            local tilePosition = position+vector(x,y,z)
            if tilePosition.z<=height and tilePosition.z>= 0 then
              local tileType = ""
              if tilePosition.z == height then tileType = biome.ground else tileType=biome.dirt end
              local tile = classFactory.getObject(tileType)
              tile.position = tilePosition
              table.insert(chunk.objects,tile)
              -- ^ needed for chunk clearing
              table.insert(planet.objects,tile)  
            end
          end
        
      end
    end
    --for i,block in pairs(blocksWhichNeedRamps) do
    --  --ramp creation
    --  for x=-1,1 do
    --    for y=-1,1 do
    --      if abs(x) + abs(y) ~= 0 then
    --      height = cachedNoise[vector(block.x,block.y):__tostring()]
    --      neighborHeight = cachedNoise[vector(block.x+x,block.y+y):__tostring()]
    --      if neighborHeight == height-1  and neighborHeight ~= nil and isRampGenerated[block:__tostring()] == nil then
    --        local tile = classFactory.getObject("ramp")
    --        tile.position = block+vector(x,y)
    --        table.insert(chunk.objects,tile) 
    --        table.insert(universeObject.objects,tile)  
    --        isRampGenerated[tile.position:__tostring()] = true
    --      end
    --    end
    --  end
    --end
  --end
end

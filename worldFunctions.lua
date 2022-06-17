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
            local chunk = loadChunk(universeObject,chunkPosition)
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
function saveChunk(universe,chunk)
  --could couple multiple objects into one position, if save filesize becomes an issue.
  local savedChunk = {["objects"]={}}
  for x = 0,global.chunkSize do
    for y = 0,global.chunkSize do
      for z = 0,global.chunkSize do
        local position = vector(chunk.chunkPosition.x*global.chunkSize,chunk.chunkPosition.y*global.chunkSize,chunk.chunkPosition.z*global.height)+vector(x,y,z)
        local listPosition =universe.collisionMap[position:__tostring()]
        if listPosition ~= nil then
          for i,object in pairs(listPosition) do
            local objectData = {}
            for dataType,data in pairs(object) do
              if global.saveableData[dataType] ~= nil then
                table.insert(objectData,{[dataType]=data})
              end
            end
            local compressedObject = {devname=object.devname,data=object.flags,position={object.position:unpack()}}
            table.insert(savedChunk.objects,compressedObject)
          end
        end

      end
    end
  end
  love.filesystem.createDirectory(universe.index.."/chunks/")
  local file = love.filesystem.newFile(chunk.chunkPosition:__tostring())
  love.filesystem.write(universe.index.."/chunks/"..chunk.chunkPosition:__tostring(),lunajson.encode(savedChunk))
  global.chunkFiles[chunk.chunkPosition:__tostring()] = 1
end
function loadChunk(universe,chunkPosition)
  local chunkData = love.filesystem.read(universe.index.."/chunks/"..chunkPosition:__tostring())
  local chunk = chunkObject:new(chunkPosition)
  chunkData = lunajson.decode(chunkData)
  if chunkData ~= nil then
    for i,value in pairs(chunkData) do
      for i,object in pairs(value) do
        local newObject = classFactory.getObject(object.devname)
        if object.position ~= nil then
          newObject.position = vector(object.position[1],object.position[2],object.position[3])
        end
        table.insert(universe.objects,newObject)
        isTileGenerated[newObject.position:__tostring()] = true
      end
    end
  end
  return chunk
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
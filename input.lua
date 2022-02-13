input = {}

function input:processInput(key)
  local keys = global.keyBindings
  local actor = global.multiverse[global.currentUniverse].actors[global.currentActor]
  local modes = {
    MOVE = 1,
    INTERACT = 2,
    BUILD = 3
  }
  inputCurrentMode = inputCurrentMode or modes.MOVE
  inputDirection = inputDirection or vector(0,0,0)
  function processInput()
    function moveEntity() 
      actor:move(inputDirection)
    end
    function interactWithObject()
      inputCurrentMode = modes.MOVE
    end
    function placeEntity()
      local universe = global.multiverse[global.currentUniverse]
      local placedObjectPos = actor.position+inputDirection
      local objectName = classFactory.finishedObjectsIndexTable[(global.buildSlot%classFactory.databaseLength)+1]
      local object = classFactory.getObject(objectName)
      object.position = placedObjectPos
      local chunkPos = vector(placedObjectPos.x/global.chunkSize,placedObjectPos.y/global.chunkSize,placedObjectPos.z/global.height):ceil()
      local chunk = universe.chunks[chunkPos:__tostring()]
      local listPosition = universe.collisionMap[placedObjectPos:__tostring()]
      local obstructed = false
      local topObstructed = false
      local constructRoof = false
      if object.flags["blocks"] then
        constructRoof = true
      end
      if chunk ~= nil then
        if listPosition ~= nil then
          for i,v in pairs(listPosition) do
            if v.flags["blocks"] then
              break
            end
          end
          listPosition = universe.collisionMap[(placedObjectPos+vector(0,0,1)):__tostring()]
          if listPosition ~= nil and constructRoof then
            for i,v in pairs(listPosition) do
              if v.flags["floor"] or v.flags["blocks"] then
                  topObstructed = true
                  break
              end
            end
          end
        end
      end
      if not obstructed and universe.chunks[chunk.chunkPosition:__tostring()] then
        table.insert(chunk.objects,object)
        if not topObstructed and constructRoof then
          local object = classFactory.getObject("floor")
          object.position = placedObjectPos+vector(0,0,1)
          table.insert(chunk.objects,object)
        end
      end

      inputCurrentMode = modes.MOVE
    end
    local actions={[modes.MOVE]=moveEntity,[modes.INTERACT]=interactWithObject,[modes.BUILD]=placeEntity}
    actions[inputCurrentMode]()
  end
  function moveleft()
    inputDirection = vector(-1,0,0)
    processInput()
  end
  function moveleftup()
    inputDirection = vector(-1,-1,0)
    processInput()
  end
  function moveleftdown()
    inputDirection = vector(-1,1,0)
    processInput()
  end
  function moveright()
    inputDirection = vector(1,0,0)
    processInput()
  end
  function moverightup()
    inputDirection = vector(1,-1,0)
    processInput()
  end
  function moverightdown()
    inputDirection = vector(1,1,0)
    processInput()
  end
  function moveup()
    inputDirection = vector(0,-1,0)
    processInput()
  end
  function movedown()
    inputDirection = vector(0,1,0)
    processInput()
  end
  function climbup()
    inputDirection = vector(0,0,1)
    processInput()
  end
  function climbdown()
    inputDirection = vector(0,0,-1)
    processInput()
  end
  function stepforward()
  end
  function stepback()
  end
  function placeObject()
    inputCurrentMode = modes.BUILD
  end
  function debug()
    print((actor.position/global.chunkSize):floor())
    print(inspect(global.multiverse[global.currentUniverse].chunks))
  end
  function buildSlotLeft()
    global.buildSlot = global.buildSlot + 1
    global.buildSlotName = classFactory.finishedObjectsIndexTable[(global.buildSlot%classFactory.databaseLength)+1]
  end
  function buildSlotRight()
    global.buildSlot = global.buildSlot - 1
    global.buildSlotName = classFactory.finishedObjectsIndexTable[(global.buildSlot%classFactory.databaseLength)+1]
  end
  local controls = {["moveleft"]=moveleft,["moveright"]=moveright,["moveup"]=moveup,["movedown"]=movedown,
    ["stepforward"]=stepforward,["stepback"]=stepback,climbup=climbup,climbdown=climbdown,debug=debug,
    build=placeObject,moverightup=moverightup,moverightdown=moverightdown,moveleftup=moveleftup,moveleftdown=moveleftdown,buildSlotLeft=buildSlotLeft,buildSlotRight=buildSlotRight}
  if keys[key] ~= nil then
    controls[keys[key]]()
  end
end
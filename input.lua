input = {}

function input:processInput(key)
  local keys = global.keyBindings[global.gameScene]
  local actor = global.multiverse[global.currentUniverse].bodies[global.currentPlanet].actors[global.currentActor]
  
  -- controls for normal game 
  function GAMESCENE()
    local modes = {
      MOVE = 1,
      INTERACT = 2,
      BUILD = 3,
      DESTROY = 4
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
      function destroyEntity()
        local universe = global.multiverse[global.currentUniverse]
        local placedObjectPos = actor.position+inputDirection
        local listPosition = universe.collisionMap[placedObjectPos:__tostring()]
        if listPosition ~= nil then
          for i,v in pairs(listPosition) do 
            table.remove(universe.collisionMap[placedObjectPos:__tostring()],i)
          end
        end

        inputCurrentMode = modes.MOVE
      end
      function placeEntity()

        local planet = global.multiverse[global.currentUniverse].bodies[global.currentPlanet]
        local placedObjectPos = actor.position+inputDirection
        local objectName = classFactory.finishedObjectsIndexTable[(global.buildSlot%classFactory.databaseLength)+1]
        local object = classFactory.getObject(objectName)
        object.position = placedObjectPos
        local listPosition = planet.collisionMap[placedObjectPos:__tostring()]
        local chunkPos = vector(placedObjectPos.x/global.chunkSize,placedObjectPos.y/global.chunkSize,placedObjectPos.z/global.height):floor()
        local chunk = planet.chunks[chunkPos:__tostring()]
        local obstructed = false
        local topObstructed = false
        local constructRoof = false
        if object.flags["blocks"] then
          constructRoof = true
        end
        if listPosition ~= nil then
          for i,v in pairs(listPosition) do
            if v.flags["blocks"] then
              break
            end
          end
          listPosition = planet.collisionMap[(placedObjectPos+vector(0,0,1)):__tostring()]
          if listPosition ~= nil and constructRoof then
            for i,v in pairs(listPosition) do
              if v.flags["floor"] or v.flags["blocks"] then
                  topObstructed = true
                  break
              end
            end
          end
        end
        if not obstructed then
          table.insert(planet.objects,object)
          table.insert(chunk.objects,object)
          if not topObstructed and constructRoof then
            local object = classFactory.getObject("floor")
            object.position = placedObjectPos+vector(0,0,1)
            local aboveChunkPos = vector(object.position.x/global.chunkSize,object.position.y/global.chunkSize,object.position.z/global.height):floor()
            local aboveChunk = planet.chunks[aboveChunkPos:__tostring()]
            table.insert(chunk.objects,object)
            table.insert(planet.objects,object)
            aboveChunk.altered = true
          end
          chunk.altered = true
        end
        inputCurrentMode = modes.MOVE
      end
      local actions={[modes.MOVE]=moveEntity,[modes.INTERACT]=interactWithObject,[modes.BUILD]=placeEntity,[modes.DESTROY]=destroyEntity}
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
    global.switchUniverse(global.currentUniverse,global.currentUniverse+1)
  end
  function stepback()
    global.switchUniverse(global.currentUniverse,global.currentUniverse-1)
  end
  function placeObject()
    inputCurrentMode = modes.BUILD
  end
  function destroyObject()
    inputCurrentMode = modes.DESTROY
  end
  function debug()
    for i,v in pairs(global.multiverse[global.currentUniverse].bodies[global.currentPlanet].objects) do
      print(i)  
    end
  end
  function buildSlotLeft()
    global.buildSlot = global.buildSlot + 1
    global.buildSlotName = classFactory.finishedObjectsIndexTable[(global.buildSlot%classFactory.databaseLength)+1]
  end
  function buildSlotRight()
    global.buildSlot = global.buildSlot - 1
    global.buildSlotName = classFactory.finishedObjectsIndexTable[(global.buildSlot%classFactory.databaseLength)+1]
  end
  function quit()
    
    love.event.quit()
  end
  function openSpaceMenu()
    global.gameScene = "SPACEMENU"
    Scene.Load(global.scenes["SPACEMENU"])
  end
  local controls = {["moveleft"]=moveleft,["moveright"]=moveright,["moveup"]=moveup,["movedown"]=movedown,
    ["stepforward"]=stepforward,["stepback"]=stepback,climbup=climbup,climbdown=climbdown,debug=debug,
    build=placeObject,moverightup=moverightup,moverightdown=moverightdown,moveleftup=moveleftup,moveleftdown=moveleftdown,buildSlotLeft=buildSlotLeft,buildSlotRight=buildSlotRight,destroy = destroyObject,
    ["escape"]=quit,
    ["spacemenu"]=openSpaceMenu}
  if keys[key] ~= nil then
    controls[keys[key]]()
  end
end
function SPACEMENU()
  function quitMenu()
    global.gameScene = "GAMESCENE"
    Scene.Load(global.scenes["GAMESCENE"])
  end
  function up()
    space.viewingUniverse = (space.viewingPlanet - 1)%global.planetAmount
  end
  function down()
    space.viewingUniverse = (space.viewingPlanet + 1)%global.planetAmount 
  end
  function left()
    space.viewingUniverse = space.viewingUniverse - 1
    space.bodies = functions.generatePlanets(global.planetAmount,space.viewingUniverse)
  end
  function right()
    space.viewingUniverse = space.viewingUniverse + 1
    space.bodies = functions.generatePlanets(global.planetAmount,space.viewingUniverse)
  end
  local controls = {exitmenu=quitMenu,left=left,right=right}
if keys[key] ~= nil then
  controls[keys[key]]()
end
end
local scenes = {
  ["GAMESCENE"] = GAMESCENE,
  ["SPACEMENU"] = SPACEMENU
}
  if scenes[global.gameScene] ~= nil then
    scenes[global.gameScene]()
  end
end
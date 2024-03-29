input = {}
function interaction(name,object,actor)
  function warp()
    global.switchPlanet(global.currentPlanet,object.warpTo,actor)
  end
  local interactions = {warp=warp}
  if interactions[name] then
    interactions[name]()
  end
end

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
        local planet = global.multiverse[global.currentUniverse].bodies[global.currentPlanet]
        local placedObjectPos = actor.position+inputDirection
        local listPosition = planet.collisionMap[placedObjectPos:__tostring()]
        if listPosition ~= nil then
          for i,v in pairs(listPosition) do 
            for flag,tu in pairs(v.flags) do
              if interactionList[flag] then
                interaction(flag,v,actor)
              end
            end
          end
        end
        inputCurrentMode = modes.MOVE
      end
      function destroyEntity()
        local planet = global.multiverse[global.currentUniverse].bodies[global.currentPlanet]
        local placedObjectPos = actor.position+inputDirection
        local listPosition = planet.collisionMap[placedObjectPos:__tostring()]
        if listPosition ~= nil then
          if listPosition[#listPosition].breaksInto then
            print(listPosition[#listPosition].breaksInto)
            local tile = classFactory.getObject(listPosition[#listPosition].breaksInto)
            tile.position = placedObjectPos
            tile.chunk = listPosition[#listPosition].chunk
            table.insert(tile.chunk,tile)
            -- ^ needed for chunk clearings
            listPosition[#listPosition].removed = true
            table.insert(planet.objects,tile)  
            tile.chunk.altered = true
          end
        end

        inputCurrentMode = modes.MOVE
      end
      function placeEntity()
        local planet = global.multiverse[global.currentUniverse].bodies[global.currentPlanet]
        local placedObjectPos = actor.position+inputDirection
        local objectName = classFactory.finishedObjectsIndexTable[(global.buildSlot%classFactory.databaseLength)+1]
        placeObjectEntity(objectName,placedObjectPos,planet)
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
    global.switchUniverse(global.currentUniverse,global.currentUniverse+1,global.multiverse[global.currentUniverse].bodies[global.currentPlanet].actors[global.currentActor])
  end
  function stepback()
    global.switchUniverse(global.currentUniverse,global.currentUniverse-1,global.multiverse[global.currentUniverse].bodies[global.currentPlanet].actors[global.currentActor])
  end
  function placeObject()
    inputCurrentMode = modes.BUILD
  end
  function destroyObject()
    inputCurrentMode = modes.DESTROY
  end
  function interact()
    inputCurrentMode = modes.INTERACT
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
  function openWorldMenu()
    global.gameScene = "WORLDMENU"
    Scene.Load(global.scenes["WORLDMENU"])
  end
  local controls = {["moveleft"]=moveleft,["moveright"]=moveright,["moveup"]=moveup,["movedown"]=movedown,
    ["stepforward"]=stepforward,["stepback"]=stepback,climbup=climbup,climbdown=climbdown,debug=debug,
    build=placeObject,moverightup=moverightup,moverightdown=moverightdown,moveleftup=moveleftup,moveleftdown=moveleftdown,buildSlotLeft=buildSlotLeft,buildSlotRight=buildSlotRight,destroy = destroyObject,
    ["escape"]=quit,interact=interact,
    ["spacemenu"]=openSpaceMenu,worldmenu=openWorldMenu}
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
      space.offset = space.offset + vector(0,10)
      --space.viewingPlanet = functions.clamp(1,space.viewingPlanet-1,global.planetAmount)
      --updateSpaceMenu()
    end
    function down()
      space.offset = space.offset + vector(0,-10)
      --space.viewingPlanet = functions.clamp(1,space.viewingPlanet+1,global.planetAmount)
      --updateSpaceMenu()
    end
    function left()
      space.offset = space.offset + vector(10,0)
    end
    function right()
      space.offset = space.offset + vector(-10,0) 
    end
    function minus()
      space.zoom = space.zoom - 0.1
    end
    function plus()
      space.zoom = space.zoom + 0.1
    end
    function stepforward()
      space.viewingUniverse = space.viewingUniverse + 1
      space.bodies = functions.generatePlanets(space.viewingUniverse)
      updateSpaceMenu()
    end
    function stepback()
      space.viewingUniverse = space.viewingUniverse - 1
      space.bodies = functions.generatePlanets(space.viewingUniverse)
      updateSpaceMenu()
    end
    function timeforward()
      space.viewingTime = space.viewingTime + 3600
      updateSpaceMenu()
    end
    function timeback()
      
      space.viewingTime = functions.clamp(0,space.viewingTime - 3600,math.huge)
      updateSpaceMenu()
    end
    local controls = {exitmenu=quitMenu,left=left,right=right,up=up,down=down,minus=minus,plus=plus,stepforward=stepforward,stepback=stepback,
  timeforward=timeforward,timeback=timeback}
    if keys[key] ~= nil then
      controls[keys[key]]()
    end
end
function WORLDMENU()
  function quitMenu()
    global.gameScene = "GAMESCENE"
    Scene.Load(global.scenes["GAMESCENE"])
  end
  function up()
  end
  function down()
  end
  function left()
  end
  function right()
  end
  function minus()
  end
  function plus()
  end
  function stepforward()
    space.viewingUniverse = space.viewingUniverse + 1
    space.bodies = functions.generatePlanets(space.viewingUniverse)
    updateSpaceMenu()
  end
  function stepback()
    space.viewingUniverse = space.viewingUniverse - 1
    space.bodies = functions.generatePlanets(space.viewingUniverse)
    updateSpaceMenu()
  end
  function timeforward()
    space.viewingTime = space.viewingTime + 3600
    updateSpaceMenu()
  end
  function timeback()
    
    space.viewingTime = functions.clamp(0,space.viewingTime - 3600,math.huge)
    updateSpaceMenu()
  end
  local controls = {exitmenu=quitMenu,left=left,right=right,up=up,down=down,minus=minus,plus=plus,stepforward=stepforward,stepback=stepback,
timeforward=timeforward,timeback=timeback}
  if keys[key] ~= nil then
    controls[keys[key]]()
  end
end
local scenes = {
  ["GAMESCENE"] = GAMESCENE,
  ["SPACEMENU"] = SPACEMENU,
  ["WORLDMENU"] = WORLDMENU
}
  if scenes[global.gameScene] ~= nil then
    scenes[global.gameScene]()
  end
end
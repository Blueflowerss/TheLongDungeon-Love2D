liquidObject = {}
 
function liquidObject:new(posVector,sprite)
    local o = {}
    function o:update()
      if o.amount > 0 then
        local chunkPos = vector(placedObjectPos.x/global.chunkSize,placedObjectPos.y/global.chunkSize,placedObjectPos.z/global.height):ceil()
        local chunk = global.multiverse[global.currentUniverse].chunks[chunkPos:__tostring()]
        for i=-1,1 do
        end
        
      end
    end
    o.amount = 7
    o.flags = {water=1}
    o.position = posVector
    o.sprite = sprite or 30
    return o
end

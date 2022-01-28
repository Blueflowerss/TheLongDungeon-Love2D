tileObject = {}
 
function tileObject:new(posVector,sprite)
    local o = {}
    o.flags = {}
    o.position = posVector
    o.sprite = sprite or 400
    return o
end
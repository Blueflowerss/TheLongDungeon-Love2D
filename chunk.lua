chunkObject = {}
 
function chunkObject:new(vectorPos)
    local o = {}
    o.objects = {}
    o.altered = false
    o.chunkPosition = vectorPos
    return o
end
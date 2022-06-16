chunkObject = {}
 
function chunkObject:new(vectorPos)
    local o = {}
    o.altered = false
    o.chunkPosition = vectorPos
    return o
end
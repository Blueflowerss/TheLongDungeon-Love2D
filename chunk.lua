chunkObject = {}
 
function chunkObject:new(vectorPos)
    local o = {}
    o.chunkPosition = vectorPos
    o.objects = {}
    return o
end
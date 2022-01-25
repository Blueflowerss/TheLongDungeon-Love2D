chunkObject = {}
 
function chunkObject:new(vectorPos)
    local o = {}
    o.objects = {}
    o.chunkPosition = vectorPos
    return o
end
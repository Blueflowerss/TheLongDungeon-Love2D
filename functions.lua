functions = {}
function functions.charSplit (inStr)
    local outStr, nextChar = inStr:sub(1, 1)
    for pos = 2, #inStr do
        nextChar = inStr:sub(pos, pos)
        if nextChar ~= outStr:sub(#outStr, #outStr) then
            outStr = outStr .. ", "
        end
        outStr = outStr .. nextChar
        out = {}
    end
    return outStr
end
function functions.createAndInsertTable(parentTable,childTable,value)
  if parentTable[childTable] ~= nil then
    table.insert(parentTable[childTable],value)
  else
    parentTable[childTable] = {}
    table.insert(parentTable[childTable],value)
  end
end
function functions.reverseTable(t)
  local n = #t
  local i = 1
  while i < n do
    t[i],t[n] = t[n],t[i]
    i = i + 1
    n = n - 1
  end
end
function functions.clamp(low, n, high) return math.min(math.max(n, low), high) end
planetGeneration = {}
function planetGeneration.generatePlanetTypes()
    local planetTypesFile= love.filesystem.read("data/planetTypes.json")
    local planetTypes = lunajson.decode(planetTypesFile)
    for planetName,planetTypes in pairs(planetTypes) do
        global.planetTypes[planetName] = {}
        local newPlanet = {}    
        for var,val in pairs(planetTypes) do    
            newPlanet[var] = val
        end
        global.planetTypes[planetName] = newPlanet
        
    end
end
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
function planetGeneration.generateBiomes()
    local biomesFile = love.filesystem.read("data/biomes.json")
    local biomes = lunajson.decode(biomesFile)
    for biomeName,biome in pairs(biomes) do 
        global.biomes[biomeName] = {}
        local newBiome = {}
        for var,val in pairs(biome) do
            newBiome[var] = val
        end
        global.biomeAmount = global.biomeAmount + 1
        global.biomesIndexed[#global.biomesIndexed+1] = biomeName
        global.biomes[biomeName] = newBiome
    end
end
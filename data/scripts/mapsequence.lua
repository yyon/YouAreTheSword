local mapsequence = [[
sequencetest
tutorial/1
tutorial/2
tutorial/special
tutorial/swordtransform
tutorial/3
mageboss/mage1
puzzletest/1
puzzletest/2
mageboss/mage2
mageboss/mageboss
maptest
CatDungeon/1
CatDungeon/2
Ian's Test Dungeon/2
Ian's Test Dungeon/3
puzzletest/3
puzzletest/4
DunsMurDungeon/TempleRuins
CatDungeon/BossMap
abductiontest
spaceship/spaceship_1
Ian's Test Dungeon/4
Ian's Test Dungeon/5
spaceshipmap
DunsMurDungeon/castle
DunsMurDungeon/city1
DunsMurDungeon/city2
puzzletest/5
DunsMurDungeon/river
DunsMurDungeon/cave
dunsmurmap
theend
]]

local function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; local i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

local mapsequencelist = mysplit(mapsequence, "\n")

local maptable = {}

local previousline
for i, line in ipairs(mapsequencelist) do
    if previousline ~= nil then
        if maptable[previousline] ~= nil then
            print("ERROR: double map in mapsequence")
        end
        maptable[previousline] = line
    end

    previousline = line
end

return maptable

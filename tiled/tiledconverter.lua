infile = ...

data = dofile(infile)

local width, height = data.width, data.height

print([[properties{
  x = 0,
  y = 0,
  width = ]] .. width * 32 .. [[,
  height = ]] .. height * 32 .. [[,
  tileset = "tileset2",
}]])

function toi(x, y)
	return (y*width + x + 1)
end

for layeri, layer in ipairs(data.layers) do
	local layerdata = layer.data
	local layername = layer.name
	local covered = {}
	for i, tile in ipairs(layerdata) do
		if not covered[i] then
			if tile ~= 0 then
				local iswall = (layername == "wall" or layername == "walls")
				
				local x, y = (i-1) % width, math.floor((i-1) / width)
				local testx, testy = x, y
				while true do
					testx = testx + 1
					local testi = toi(testx, testy)
					if (layerdata[testi]) == nil or (iswall and layerdata[testi] == 0) or (not iswall and tile ~= layerdata[testi]) then
						break
					end
					if testx >= width then
						break
					end
				end
				testx = testx
				local w = testx - x
				testx, testy = x, y
				local samey = true
				while true do
					testy = testy + 1
					for testx = x, x+w-1 do
						local testi = toi(testx, testy)
						if (layerdata[testi]) == nil or (iswall and layerdata[testi] == 0) or (not iswall and tile ~= layerdata[testi]) then
							samey = false
							break
						end
					end
					if not samey then
						break
					end
				end
				testy = testy
				local h = testy - y
				
				for testx = x, x+w-1 do
					for testy = y, y+h-1 do
						local testi = toi(testx, testy)
						covered[testi] = 1
					end
				end
				
				if layername == "wall" or layername == "walls" then
					print([[wall{
	layer = 0,
	x = ]] .. x*32 .. [[,
	y = ]] .. y*32 .. [[,
	width = ]] .. w * 32 .. [[,
	height = ]] .. h * 32 .. [[,
	stops_hero = true,
	stops_npcs = true,
	stops_enemies = true,
	stops_blocks = true,
	stops_projectiles = true,
}]])
				elseif layername == "object" or layername == "objects" then
				    local posbelow = i + width
				    local hasbelow = (layerdata[posbelow] ~= nil and layerdata[posbelow] ~= 0)
				    local newlayer = (hasbelow and 1 or 0)
				    print([[tile{
	layer = ]] .. tonumber(newlayer) .. [[,
	x = ]] .. x * 32 .. [[,
	y = ]] .. y * 32 .. [[,
	width = ]] .. w * 32 .. [[,
	height = ]] .. h * 32 .. [[,
	pattern = "]] .. tile + 1 .. [[",
}
]])
				    if not hasbelow then
					print([[wall{
	layer = 0,
	x = ]] .. x*32 .. [[,
	y = ]] .. y*32 .. [[,
	width = ]] .. w * 32 .. [[,
	height = ]] .. h * 32 .. [[,
	stops_hero = true,
	stops_npcs = true,
	stops_enemies = true,
	stops_blocks = true,
	stops_projectiles = true,
}]])
				    end
				else
					local newlayer = tonumber(layername:sub(1,1)) - 1
					print([[tile{
	layer = ]] .. newlayer .. [[,
	x = ]] .. x * 32 .. [[,
	y = ]] .. y * 32 .. [[,
	width = ]] .. w * 32 .. [[,
	height = ]] .. h * 32 .. [[,
	pattern = "]] .. tile + 1 .. [[",
}
]])
				end
			end
		end
	end
end

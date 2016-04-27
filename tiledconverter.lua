infile = ...

infile = string.sub(infile, 1, -5)
data = require(infile)

local width, height = data.width, data.height

local layertranslation = {[0]=0, [1]=0, [2]=1, [3]="wall"}

print([[properties{
  x = 0,
  y = 0,
  width = ]] .. width * 32 .. [[,
  height = ]] .. height * 32 .. [[,
  tileset = "tileset2",
}]])

for layeri, layer in ipairs(data.layers) do
	local layerdata = layer.data
	for i, tile in ipairs(layerdata) do
		local x, y = i % width, math.floor(i / width)
		if tile ~= 0 then
			local newlayer = layertranslation[layeri]
			if newlayer == "wall" then
				print([[wall{wall{
  layer = 0,
  x = ]] .. x*32 .. [[,
  y = ]] .. y*32 .. [[,
  width = 32,
  height = 32,
  stops_hero = true,
  stops_npcs = true,
  stops_enemies = true,
  stops_blocks = true,
  stops_projectiles = true,
}]])
			else
				print([[tile{
	layer = ]] .. newlayer .. [[,
	x = ]] .. x * 32 .. [[,
	y = ]] .. y * 32 .. [[,
	width = 32,
	height = 32,
	pattern = "]] .. tile + 1 .. [[",
}
]])
			end
		end
	end
end

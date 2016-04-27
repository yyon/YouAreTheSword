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

for layeri, layer in ipairs(data.layers) do
	local layerdata = layer.data
	local layername = layer.name
	for i, tile in ipairs(layerdata) do
		local x, y = (i-1) % width, math.floor((i-1) / width)
		if tile ~= 0 then
			if layername == "wall" or layername == "walls" then
				print([[wall{
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
				local newlayer = tonumber(layername - 1)
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

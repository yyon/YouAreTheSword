infile = ...

function wall(w)
end

function tile(t)
end

function printstuff(name, table)
	print(name .. "{")
	for k, v in pairs(table) do
		local newv = v
		if type(v) == "string" then
			v = "\"" .. v .. "\""
		end
		print("	" .. k .. " = " .. v .. ",")
	end
	print("}")
end

function enemy(e)
	printstuff("enemy", e)
end

function enemy(e)
	printstuff("enemy", e)
end

function separator(s)
	printstuff("separator", s)
end

function teletransporter(t)
	printstuff("teletransporter", t)
end

function destination(d)
	printstuff("destination", d)
end

function properties(p)
end

data = dofile(infile)

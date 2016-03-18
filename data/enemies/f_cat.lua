local enemy = ...

local entitydatas = require "enemies/entitydata"

sol.main.load_file("enemies/NPC")(enemy)
local data = entitydatas.catboss:new(enemy)
data:applytoentity()

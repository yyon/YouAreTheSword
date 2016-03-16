local enemy = ...

entitydatas = require "enemies/entitydata"

sol.main.load_file("enemies/NPC")(enemy)
data = entitydatas.wolfclass:new(enemy)
data:applytoentity()
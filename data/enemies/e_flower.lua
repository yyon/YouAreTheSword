local enemy = ...

entitydatas = require "enemies/entitydata"

sol.main.load_file("enemies/NPC")(enemy)
data = entitydatas.flowerclass:new(enemy)
data:applytoentity()
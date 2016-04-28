local entity = ...

function entity:on_created()
	self:set_optimization_distance(0)
	
	self.collided = {}
	self:add_collision_test("sprite", self.oncollision)
	if self:get_sprite():get_animation() == "5" then
		self.activeframes = {[4]=true}
	elseif self:get_sprite():get_animation() == "always" then
		self.activeframes = {[0]=true}
	else
		self.activeframes = {[2]=true}
	end
end
function entity:on_update()
	if self:get_sprite():get_frame() == 0 then
		self.collided = {}
	end
end

function entity:oncollision(entity2, sprite1, sprite2)
	if entity2.entitydata ~= nil then
		if not self.collided[entity2] then
			if self.activeframes[self:get_sprite():get_frame()] then
				print "HIT"
				self.collided[entity2] = true
				entity2.entitydata:dodamage(entity2.entitydata, 0.5, {sameteam = true, fromentity = self, directionalknockback=true})
			end
		end
	end
end
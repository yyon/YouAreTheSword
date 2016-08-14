local map = ...
map.dialogprefix = "tutorialspecial."

function map:on_opening_transition_finished()
	mage.entitydata.specialability = LightningAbility:new(mage.entitydata)
	mage.entitydata.swordability = SwordAbility:new(mage.entitydata)
end

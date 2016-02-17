local enemy = ...

-- Red knight soldier.

sol.main.load_file("enemies/NPC")(enemy)
enemy:set_properties({
  main_sprite = "hero/tunic3",	
  sword_sprite = "hero/sword3",
  life = 4,
  damage = 2,
  play_hero_seen_sound = true
})


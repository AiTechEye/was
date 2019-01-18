minetest.register_craft({
	output = "was:chemical_lump 3",
	recipe = {
		{"group:dye","group:dye","group:dye"},
		{"group:dye","default:copper_lump","group:dye"},
		{"group:dye","default:glass","group:dye"},
	}
})

minetest.register_craft({
	output = "was:mdoid_gate",
	recipe = {
		{"was:plastic_piece","was:wire","was:plastic_piece"},
		{"was:plastic_piece","was:wire","was:plastic_piece"},
		{"","",""},
	}
})

minetest.register_craft({
	output = "was:digiline_was_converter",
	recipe = {
		{"digilines:wire_std_00000000","",""},
		{"was:sender","",""},
		{"was:wire","",""},
	}
})

--[[ currently broken
minetest.register_craft({
	output = "was:router",
	recipe = {
		{"was:plastic_piece","was:plastic_piece","was:plastic_piece"},
		{"was:plastic_piece","default:mese_crystal","was:plastic_piece"},
		{"was:plastic_piece","was:wire","was:plastic_piece"},
	}
})
--]]

minetest.register_craft({
	output = "was:sender",
	recipe = {
		{"was:plastic_piece","was:plastic_piece",""},
		{"was:plastic_piece","default:mese_crystal",""},
		{"was:plastic_piece","was:wire",""},
	}
})

minetest.register_craft({
	output = "was:receiver",
	recipe = {
		{"was:plastic_piece","was:wire",""},
		{"was:plastic_piece","default:mese_crystal",""},
		{"was:plastic_piece","was:plastic_piece",""},
	}
})


minetest.register_craft({
	output = "was:computer",
	recipe = {
		{"was:plastic_piece","default:mese","was:plastic_piece"},
		{"default:glass","was:touchscreen","default:steel_ingot"},
		{"default:gold_ingot","default:diamondblock","default:gold_ingot"},
	}
})
minetest.register_craft({
	output = "was:wire 20",
	recipe = {
		{"was:plastic_piece","was:plastic_piece","was:plastic_piece"},
	}
})

minetest.register_craft({
	output = "was:touchscreen",
	recipe = {
		{"was:plastic_piece","default:tin_lump","was:plastic_piece"},
		{"was:plastic_piece","default:mese_crystal","was:plastic_piece"},
		{"was:plastic_piece","default:glass","was:plastic_piece"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "was:plastic_piece",
	recipe = "was:chemical_lump",
})

minetest.register_craft({
	type = "fuel",
	recipe = "was:plastic_piece",
	burntime = 1,
})
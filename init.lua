was={
	functions={},
	function_list={},
	function_packed={},
	info={},
	privs={},
	user={},
	userdata={},
	symbols={},
	symbols_characters="#@=?!&{}%*+-/$<>|~^",
}

dofile(minetest.get_modpath("was") .. "/api.lua")
dofile(minetest.get_modpath("was") .. "/register.lua")
dofile(minetest.get_modpath("was") .. "/gui.lua")

--minetest.register_chatcommand("was", {
--	description = "World action script gui",
--	func = function(name, param)
--		was.gui(name)
--		return true
--	end,
--})

minetest.register_privilege("was", {
	description = "Full access to functions",
	give_to_singleplayer= false,
})


minetest.register_node("was:computer_closed", {
	description = "Computer",
	drop="was:computer",
	tiles = {
		"was_pc_outside.png",
	},
	drawtype="nodebox",
	paramtype = "light",
	paramtype2="facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.3, 0.5, -0.43, 0.5},
		}
	},
	groups = {oddly_breakable_by_hand = 3,was_component=1},
	on_punch = function(pos, node, player, pointed_thing)
		local name=player:get_player_name() or ""
		if minetest.get_meta(pos):get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			minetest.swap_node(pos,{name="was:computer",param2=node.param2})
		end
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.registered_nodes["was:computer"].on_rightclick(pos, node, player, itemstack, pointed_thing)
	end,
	can_dig = function(pos, player)
		return minetest.registered_nodes["was:computer"].can_dig(pos, player)
	end,
})

minetest.register_node("was:computer", {
	description = "Computer",
	tiles = {
		"was_pc_board.png",
		"was_pc_outside.png",
		"was_pc_screen.png",
		"was_pc_outside.png",
		"was_pc_outside.png",
		"was_pc_screen.png",
	},
	drawtype="nodebox",
	paramtype = "light",
	paramtype2="facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.3, 0.5, -0.43, 0.5},
			{-0.5, -0.5, 0.48, 0.5, 0.3, 0.5},
		}
	},
	groups = {oddly_breakable_by_hand = 3,was_component=1},
	on_punch = function(pos, node, player, pointed_thing)
		minetest.swap_node(pos,{name="was:computer_closed",param2=node.param2})
	end,
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name() or "")
		meta:get_inventory():set_size("storage", 50)
		minetest.swap_node(pos,{name="was:computer_closed",param2=minetest.get_node(pos).param2})
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			if meta:get_string("owner")=="" then
				return
			end
			minetest.swap_node(pos,{name="was:computer",param2=node.param2})
			was.new_user(name,{nodepos=pos,show_print=true})
			was.user[name].text=minetest.deserialize(meta:get_string("text"))
			was.gui(name)
		end
	end,
	can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_inventory():is_empty("storage") and (meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true})) then
			return true
		end
	end,
})
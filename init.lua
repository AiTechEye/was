was={
	functions={},
	function_packed={},
	info={
		["!"]="Empty value",
		["=="]="Equal (only used with if)",
		["~="]="Equal (only used with if)",
		[">"]="Greater then (only used with if)",
		["<"]="Less then (only used with if)",
		[">="]="Greater or equal (only used with if)",
		["<="]="Less or equal (only used with if)",
	},
	privs={},
	user={},
	userdata={},
	symbols={
		["!"]=function()
			if was.userdata.function_name=="if" then
				return "!"
			end
		end,
		[">"]=function() return ">" end,
		["<"]=function() return "<" end,
		["=="]=function() return "==" end,
		["~="]=function() return "~=" end,
		[">="]=function() return ">=" end,
		["<="]=function() return "<=" end,
	},
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


minetest.register_node("was:computer", {
	description = "Computer",
	tiles = {"default_steel_block.png"},
	groups = {oddly_breakable_by_hand = 3,was_component=1},
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name() or "")
		meta:get_inventory():set_size("storage", 50)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			if meta:get_string("owner")=="" then
				return
			end
			local text=minetest.deserialize(meta:get_string("text"))
			was.gui(name,"",{text=text})
			if was.user[name] and not was.user[name].nodepos then
				was.user[name].nodepos=pos
			end
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
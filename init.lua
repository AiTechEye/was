was={
	functions={},
	function_list={},
	function_packed={},
	info={},
	privs={},
	user={},
	userdata={},
	symbols={},
	wire_signals={},
	symbols_characters=".#@=?!&{}%*+-/$<>|~^",
}

dofile(minetest.get_modpath("was") .. "/api.lua")
dofile(minetest.get_modpath("was") .. "/functions.lua")
dofile(minetest.get_modpath("was") .. "/items.lua")
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
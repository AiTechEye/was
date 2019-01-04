was={
	functions={},
	function_packed={},
	info={},
	privs={},
	user={},
	symbols={
		["!"]=function() end,
		["=="]=function() end,
		["~="]=function() end,
		[">="]=function() end,
		["<="]=function() end,
	},
	symbols_characters="#@=?!&()[]{}%*+-/$<>|~^",
}

dofile(minetest.get_modpath("was") .. "/api.lua")
dofile(minetest.get_modpath("was") .. "/register.lua")

minetest.register_chatcommand("was", {
	description = "World action script gui",
	privs = {kick = true},
	func = function(name, param)
		was.gui(name)
		return true
	end,
})

was.gui=function(name,msg)
	was.user[name]=was.user[name] or {text="",funcs={}}

	local text=was.user[name].text or ""
	local funcs=""

	for f,v in pairs(was.functions) do
		if minetest.check_player_privs(name,was.privs[f]) then 
			funcs=funcs .. f ..","
			table.insert(was.user[name].funcs,f)
		end
	end
	funcs=funcs:sub(0,funcs:len()-1)

	local gui="size[20,12]"
	.."textarea[0,1.3;17,13;text;;" .. text .. "]"
	.."textlist[16.6,1;3,12;list;" .. funcs .."]"
	.."label[0,0.6;".. minetest.colorize("#00FF00",(msg or "")) .."]"
	.."button[0,-0.2;1.3,1;run;Run]"
	.."button[1,-0.2;1.3,1;save;Save]"


	minetest.after(0.1, function(gui,name)
		return minetest.show_formspec(name, "was.gui",gui)
	end, gui,name)
end


minetest.register_on_player_receive_fields(function(user, form, pressed)
	if form=="was.gui" then
		local name=user:get_player_name()
		if (pressed.quit and not pressed.key_enter) or not was.user[name] then
			return
		end
		local funcs=was.user[name].funcs
		was.user[name].funcs={}
		was.user[name].text=pressed.text

		if pressed.list and pressed.list~="IMV" then
			local n=pressed.list:gsub("CHG:","")
			local f=funcs[tonumber(n)]
			local info=was.info[f] or ""

			if was.privs[f] then
				info=info .. "| Privs: " ..minetest.privs_to_string(was.privs[f])
			end
			minetest.close_formspec(name,form)
			was.gui(name,info)

		elseif pressed.save then
		elseif pressed.run then
			local msg=was.compiler(pressed.text,name)
			was.gui(name,msg)
		end
	end
end)

--was.compiler("if(a==!) test(111)")
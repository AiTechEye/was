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
	username="",
	symbols={
		["!"]=function() return end,
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

minetest.register_chatcommand("was", {
	description = "World action script gui",
	func = function(name, param)
		was.gui(name)
		return true
	end,
})

minetest.register_node("was:computer", {
	description = "Computer",
	tiles = {"default_steel_block.png"},
	groups = {oddly_breakable_by_hand = 3,was_component=1},
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name() or "")
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
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
		if meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			return true
		end
	end,
})

was.gui_addnumbers=function(text)
	text=text.."\n"
	local t=""
	for i,v in ipairs(text.split(text,"\n")) do
		t=t ..i.." " ..v .."\n"
	end
	return t
end

was.gui_delnumbers=function(text)
	local t=""
	for i,v in ipairs(text.split(text,"\n")) do
		local n,nn
		for ii=1,v:len(),1 do
			local s=string.sub(v,ii,ii)
			if not n and was.num(s)==false then
				n=true
			end
			if n and (nn or s~=" ") then
				t=t..s
				nn=true
			elseif n and not nn then
				nn=true
			end
		end
		t=t.."\n"
	end
	return t
end

was.gui=function(name,msg,other)

	local text=(other and other.text or "")

	was.user[name]=was.user[name] or {text=text,funcs={},inserttext="true",lines="off"}

	text=was.user[name].text
	local funcs=""

	for f,v in pairs(was.symbols) do
		funcs=funcs .. f ..","
		table.insert(was.user[name].funcs,f)
	end

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
	.."button[2,-0.2;1.5,1;lines;Lines " ..was.user[name].lines.."]"
	.."checkbox[16.6,-0.2;inserttext;Insert text;".. was.user[name].inserttext.."]"

	minetest.after(0.1, function(gui,name)
		return minetest.show_formspec(name, "was.gui",gui)
	end, gui,name)
end


minetest.register_on_player_receive_fields(function(user, form, pressed)
	if form=="was.gui" then
		local name=user:get_player_name()
		if (pressed.quit and not pressed.key_enter) or not was.user[name] then
			if was.user[name] then
				was.user[name].nodepos=nil
			end
			return
		end

		local funcs=was.user[name].funcs
		was.user[name].funcs={}
		was.user[name].text=pressed.text

		if was.user[name].text:find("%[") or was.user[name].text:find("%]") then
			was.user[name].text=was.user[name].text:gsub("%[","")
			was.user[name].text=was.user[name].text:gsub("%]","")
			minetest.close_formspec(name,form)
			was.gui(name,"Unallowed characters removed")
			return
		end

		if pressed.lines then
			if was.user[name].lines=="on" then
				was.user[name].text=was.gui_delnumbers(was.user[name].text)
				was.user[name].lines="off"
			else
				was.user[name].text=was.gui_addnumbers(was.user[name].text)
				was.user[name].lines="on"
			end
			was.gui(name)
		elseif was.user[name].lines=="on" then
			was.user[name].text=was.gui_delnumbers(was.user[name].text)
			was.user[name].lines="off"
		end


		if pressed.inserttext then
			was.user[name].inserttext=pressed.inserttext
		end

		if pressed.list and pressed.list~="IMV" then
			local n=pressed.list:gsub("CHG:","")
			local f=funcs[tonumber(n)]
			local info=was.info[f] or ""
			if was.privs[f] then
				info=info .. "| Privs: " ..minetest.privs_to_string(was.privs[f])
			end

			if was.user[name].inserttext=="true" and f then
				was.user[name].text=was.user[name].text .. f ..(was.functions[f] and "()" or "") 
			end

			minetest.close_formspec(name,form)
			was.gui(name,info)
		elseif pressed.save then
			if was.user[name].nodepos and minetest.get_item_group(minetest.get_node(was.user[name].nodepos).name,"was_component")==1 then
				local meta=minetest.get_meta(was.user[name].nodepos)
				meta:set_string("text",minetest.serialize(was.user[name].text))
				was.gui(name,"Text saved successful")
			end
		elseif pressed.run then
			local msg=was.compiler(pressed.text,name)

			if msg then
				was.user[name].text=was.gui_addnumbers(was.user[name].text)
				was.user[name].lines="on"
			end

			was.gui(name,msg)
		end
	end
end)

--was.compiler("if(a==!) test(111)")
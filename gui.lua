minetest.after(0.2, function()
	for f,v in pairs(was.functions) do
		table.insert(was.function_list,f)
	end
	table.sort(was.function_list,function(a,b) return a < b end)
end)

was.gui_addnumbers=function(text)
	text=text.."\n"
	for i=1,text:len(),1 do
		if text:sub(i,i)~="\n" then
			text=text:sub(i,text:len())
			break
		end
	end
	local t=""
	for i,v in ipairs(text.split(text,"\n")) do
		t=t ..i.." " ..v .."\n"
	end
	return t
end


was.gui_delnumbers=function(text)
	for i=1,text:len(),1 do
		if text:sub(i,i)~="\n" then
			text=text:sub(i,text:len())
			break
		end
	end
	local t=""
	for i,v in ipairs(text.split(text,"\n")) do
		for ii=1,v:len(),1 do
			local s=string.sub(v,ii,ii)
			if not was.num(s) then
				ii= (s==" " and ii+1) or ii
				t=t .. string.sub(v,ii,v:len()).."\n"
				break
			end
		end
	end
	return t
end

was.gui=function(name,msg)

	was.user[name].inserttext=	was.user[name].inserttext or "true"
	was.user[name].lines=	was.user[name].lines or "off"
	was.user[name].bg=	was.user[name].bg or "true"
	was.user[name].console=	was.user[name].console or "false"

	local funcs=""
	local symbs="SYMBOLS,"
	local tx=17
	local console=""

	if was.user[name].console=="true" then
		tx=11
		console="label[10.6,1.3;".. minetest.colorize("#00FF00", was.user[name].console_text or "") .."]"
	end


	for f,v in pairs(was.symbols) do
		symbs=symbs .. f ..","
	end

	for _,v in pairs(was.function_list) do
		if minetest.check_player_privs(name,was.privs[v]) then 
			funcs=funcs .. v ..","
		end
	end

	--funcs=funcs:sub(0,funcs:len()-1)
	symbs=symbs:sub(0,symbs:len()-1)

	local gui="size[20,12.1]"
	.. (was.user[name].bg=="true" and "background[-0.5,-0.2;22,13;was_guibg.png]" or "")

	.. console

	.."textarea[0,1.3;" ..tx ..",13;text;;" .. (was.user[name].text or "") .. "]"
	.."label[0,0.6;".. minetest.colorize("#00FF00",(msg or "")) .."]"
	.."button[-0.2,-0.2;1.3,1;run;Run]"
	.."button[0.8,-0.2;1.3,1;save;Save]"
	.."button[1.8,-0.2;1.5,1;lines;Lines " ..was.user[name].lines.."]"
	.."button[3.1,-0.2;1.5,1;storage;Storage]"
	.."field[4.6,0.1;3,1;pupos;;" .. (was.user[name].punchpos or "") .."]"
	.."dropdown[16.5,0.4;4,12;slist;" .. symbs ..";]"
	.."textlist[16.5,1;4,12;list;" .. funcs .."]"
	.."button[8.2,-0.2;1.9,1;stopt;Stop timer]"

	.."field[10.1,0.1;3,1;channel;;" .. (was.user[name].channel or "") .."]"

	.."checkbox[16.6,-0.4;inserttext;Insert text;".. was.user[name].inserttext.."]"
	.."checkbox[7.2,-0.2;bg;;".. was.user[name].bg .."]"
	.."checkbox[7.7,-0.2;console;;".. was.user[name].console .."]"

	.."tooltip[pupos;Press Enter and punch on a node to return the position, or punch it again to get its name, Press Enter to move the text to the textarea]"
	.."tooltip[bg;Background]"
	.."tooltip[console;Console]"
	.."tooltip[channel;Channel]"
	was.user[name].punchpos=nil

	minetest.after(0.1, function(gui,name)
		return minetest.show_formspec(name, "was.gui",gui)
	end, gui,name)
end


minetest.register_on_player_receive_fields(function(user, form, pressed)

	if form=="was.gui" then
		local name=user:get_player_name()
		if (pressed.quit and not pressed.key_enter) or not was.user[name] then
			if was.user[name] then
				was.user[name].text=nil
				was.user[name].show_print=nil
				was.user[name].channel=nil
			end
			return
		end

		if pressed.storage and was.user[name].nodepos then
			local gui="size[10,9]"
			.."list[nodemeta:" .. was.user[name].nodepos.x .."," .. was.user[name].nodepos.y .."," .. was.user[name].nodepos.z ..";storage;0,0;10,5;]"
			.."list[current_player;main;1,5.2;8,4;]"
			.."listring[current_player;main]"
			.."listring[nodemeta:" .. was.user[name].nodepos.x .."," .. was.user[name].nodepos.y .."," .. was.user[name].nodepos.z ..";storage]"

			minetest.after(0.1, function(gui,name)
				return minetest.show_formspec(name, "was.guistorage",gui)
			end, gui,name)
			return
		end

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
		elseif pressed.inserttext then
			was.user[name].inserttext=pressed.inserttext
		elseif pressed.bg then
			was.user[name].bg=pressed.bg
			was.gui(name)
			return
		elseif pressed.console then
			was.user[name].console=pressed.console
			was.gui(name)
			return
		elseif pressed.stopt and was.user[name].nodepos then
			minetest.get_node_timer(was.user[name].nodepos):stop()
		end

		if pressed.list and pressed.list~="IMV" then
			local n=pressed.list:gsub("CHG:","")
			local f=was.function_list[tonumber(n)]
			local info=was.info[f] or ""
			if was.privs[f] then
				info=info .. "| Privs: " ..minetest.privs_to_string(was.privs[f])
			end
			if was.user[name].inserttext=="true" and f then
				was.user[name].text=was.user[name].text .. f ..(was.functions[f] and "()" or "") 
			end
			minetest.close_formspec(name,form)
			was.gui(name,info)
		elseif pressed.slist and pressed.slist~="SYMBOLS" then
			if was.user[name].inserttext=="true" then
				was.user[name].text=was.user[name].text .. pressed.slist
			end
			was.gui(name,was.info[pressed.slist] or "")
		elseif pressed.save then
			if was.user[name].nodepos and minetest.get_item_group(minetest.get_node(was.user[name].nodepos).name,"was_unit")==1 then
				local meta=minetest.get_meta(was.user[name].nodepos)
				meta:set_string("text",minetest.serialize(was.user[name].text))
				meta:set_string("channel",pressed.channel)
				was.user[name].channel=pressed.channel
				was.gui(name,"Text saved successful")
			end
		elseif pressed.pupos and pressed.key_enter then
			if pressed.pupos=="" then
				was.user[name].punchpos=""
				minetest.close_formspec(name,form)
				minetest.chat_send_player(name, "Punch a node, then come back here")
			elseif pressed.pupos~="" then
				was.user[name].text=was.user[name].text ..  pressed.pupos
				was.gui(name)
			end
		elseif pressed.run then
			local msg=was.compiler(was.user[name].text,{
				user=name,
				pos=was.user[name].nodepos,
				print=true,
				event={event="gui_run"}
			})
			if msg then
				was.user[name].text=was.gui_addnumbers(was.user[name].text)
				was.user[name].lines="on"
				was.userdata.name=name
				was.functions["print"]({msg})
			end

			was.gui(name,msg)
		end
	end
end)

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	local name=puncher:get_player_name()
	if was.user[name] and was.user[name].punchpos then
		if was.user[name].punchpos=="" or was.user[name].punchpos:find(":") then
			was.user[name].punchpos=pos.x .." " ..pos.y .." " .. pos.z
			minetest.chat_send_player(name, "Position " .. was.user[name].punchpos)
		else
			was.user[name].punchpos=minetest.get_node(pos).name
			minetest.chat_send_player(name, "Name " .. was.user[name].punchpos)
		end	
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name=player:get_player_name()
	if was.user[name] then
		was.user[name]=nil
	end
end)
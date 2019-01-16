
--[[
================= SYMBOLS =================
--]]

was.register_symbol("?",function() return was.userdata.name end,"return username")
was.register_symbol("!", function() if was.userdata.function_name~="if" and was.userdata.function_name~="elseif" then was.userdata.error=" ! only able in if state" end end,"Empty value")
was.register_symbol(">", function() if was.userdata.function_name~="if" and was.userdata.function_name~="elseif" then was.userdata.error=" > only able in if state" end end,"Greater then (only used with if)" )
was.register_symbol("<", function() if was.userdata.function_name~="if" and was.userdata.function_name~="elseif" then was.userdata.error=" < only able in if state" end end,"Less then (only used with if)" )
was.register_symbol("<=", function() if was.userdata.function_name~="if" and was.userdata.function_name~="elseif" then was.userdata.error=" <= only able in if state" end end,"Less or equal (only used with if)" )
was.register_symbol(">=", function() if was.userdata.function_name~="if" and was.userdata.function_name~="elseif" then was.userdata.error=" >= only able in if state" end end,"Greater or equal (only used with if)" )
was.register_symbol("==", function() if was.userdata.function_name~="if" and was.userdata.function_name~="elseif" then was.userdata.error=" == only able in if state" end end,"Equal (only used with if)" )
was.register_symbol("~=", function() if was.userdata.function_name~="if" and was.userdata.function_name~="elseif" then was.userdata.error=" > only able in if state" end end,"Equal (only used with if)" )
was.register_symbol("!=",function() end, "var = nothing")
was.register_symbol("--",function() end, "Comment")
was.register_symbol("-",function() end, "Minus")

was.register_symbol("+=",function()
		local i=was.userdata.index
		if was.is_number(was.iuserdata(i-1)) and was.is_number(was.iuserdata(i+1)) then
			return was.iuserdata(i-1) + was.iuserdata(i+1)
		end
	end,
	"var + n"
)

was.register_symbol("-=",function()
		local i=was.userdata.index
		if was.is_number(was.iuserdata(i-1)) and was.is_number(was.iuserdata(i+1)) then
			return was.iuserdata(i-1) - was.iuserdata(i+1)
		end
	end,
	"var - n"
)

was.register_symbol("*=",function()
		local i=was.userdata.index
		if was.is_number(was.iuserdata(i-1)) and was.is_number(was.iuserdata(i+1)) then
			return was.iuserdata(i-1) * was.iuserdata(i+1)
		end
	end,
	"var * n"
)

was.register_symbol("/=",function()
		local i=was.userdata.index
		if was.is_number(was.iuserdata(i-1)) and was.is_number(was.iuserdata(i+1)) then
			return was.iuserdata(i-1) / was.iuserdata(i+1)
		end
	end,
	"var / n"
)

--[[
================= SERVER =================
--]]


was.register_function("get.objects",{
	info='return table of objects (pos distance <"player" or "entity" or none for both>)',
	action=function(pos,d,typ)
		if was.is_pos(pos) and was.is_number(d) then
			if not minetest.check_player_privs(was.userdata.name,{was=true}) and d>10 then
				was.userdata.error="for safety reasons is the max distance 10 without the was privilege"
				return
			end
			if not typ then
				return minetest.get_objects_inside_radius(pos, d)
			else
				local obs={}
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos, d)) do
					local en=ob:get_luaentity() 
					if (en and typ=="entity") or (not en and typ=="player") then
						table.insert(obs,ob)
					end
				end
				return obs
			end
		end
	end
})

was.register_function("cmd",{
	info='Command eg /me says... (<"commandname"> <"text" or none>)',
	action=function(cmd,param)
	param=param or ""
	if not ((was.is_string(cmd) or was.is_number(cmd)) and (was.is_string(param) or was.is_number(param))) then
		return
	end

	local c=minetest.registered_chatcommands[cmd]
	if not c then
		return 
	end
	local p1=minetest.check_player_privs(was.userdata.name, c.privs)
	local msg=""
	local a
	if not p1 then
		msg="You aren't' allowed to do that"
	elseif c then
		a,msg=c.func(was.userdata.name,param)
		msg=msg or ""
		minetest.chat_send_player(was.userdata.name,msg)

	end
	return msg
	end
})


--[[
================= DATATYPES = VARIABLES =================
--]]

was.register_function("math.percent",{
	info="return percent of number (n1 n2)",
	action=function(a,b)
		if was.is_number(a) and was.is_number(b) then
			return (a / b) *100
		end
	end
})


was.register_function("math.pi",{
	info="return Pi",
	action=function()
		return math.pi
	end
})


was.register_function("math",{
	info="Math + - * ^ /  ('-' 1 2 67...)",
	packed=true,
	action=function(a)
		local c=a[1]
		local n=a[2]
		if not (was.is_string(c) and c:len()==1 and string.find("^+-*/",c)) then
			return
		end

		for i=3,#a,1 do
			if was.is_number(a[i]) then
				if c=="+" then
					n=n+a[i]
				elseif c=="-" then
					n=n-a[i]
				elseif c=="*" then
					n=n*a[i]
				elseif c=="/" then
					n=n/a[i]
				elseif c=="^" then
					n=n^a[i]
				end
			end
		end
		return n
	end
})

was.register_function("table.getvalue",{
	info="get table value (table key-string/number)",
	action=function(t,i)
		if was.is_table(t) and (was.is_number(i) or was.is_string(i)) then
			return t[i]
		end
	end
})

was.register_function("table.setvalue",{
	info="set table key value (table string/number value )",
	action=function(t,i,value)
		if was.is_table(t) and was.is_number(i) and not value then
			table.remove(t,i)
			return t
		elseif was.is_table(t) and (was.is_number(i) or was.is_string(i)) then
			t[i]=value
			return t
		end
	end
})

was.register_function("table.remove",{
	info="remove from table by index (table n) last value (table) key (table string)",
	action=function(t,i)
		if was.is_table(t) then
			if was.is_number(i) then
				table.remove(t,i)
				return t
			elseif was.is_string(i) then
				t[i]=nil
				return t
			else
				table.remove(t,#t)
				return t
			end
		else
			return t
		end
	end
})

was.register_function("table.insert",{
	info="Insert variables and datatypes to an table (table n1 s1 table1 ...)",
	packed=true,
	action=function(a)
		local n={}
		local s=1
		if was.is_table(a[1]) then
			n=table.copy(a[1])
			s=2
		end
		for i=s,#a,1 do
			if a[i] then
				table.insert(n,a[i])
			end
		end
		return n
	end
})

was.register_function("table.length",{
	info="Returns table length (table)",
	action=function(a)
		if was.is_table(a) then
			local l=0
			for _,i in pairs(a) do
				l=l+1
			end
			return l
		end
	end
})

was.register_function("merge",{
	info="Merge variables and datatypes (s1 n1 s...) or (table table2 s n)",
	packed=true,
	action=function(a)
		local n=""
		if was.is_table(a[1]) then
			n={}
			for i,v in ipairs(a) do
				if was.is_string(v) or was.is_number(v) then
					table.insert(n,v)
				elseif was.is_table(v) then
					for ii,vv in pairs(v) do
						table.insert(n,vv)
					end
				end
			end
		elseif was.is_string(a[1]) or was.is_number(a[1]) then
			for i,v in ipairs(a) do
				if was.is_string(v) or was.is_number(v) then
					n=n .. v
				else
					break
				end
			end
		end
		return n
	end
})


was.register_function("pos",{
	info="numbers to pos (n1 n2 n3)",
	action=function(n1,n2,n3)
		if was.is_number(n1) and was.is_number(n2) and was.is_number(n3) then
			return {x=n1,y=n2,z=n3}
		end
	end
})


--[[
================= NODES =================
--]]

was.register_function("node.set",{
	info="set node (pos,nodename)",
	privs={give=true,was=true},
	action=function(pos,name)
		if was.is_string(name) and was.is_pos(pos) and minetest.registered_nodes[name] and not was.protected(pos) then
			minetest.set_node(pos,{name=name})
		end
	end
})

was.register_function("node.add",{
	info="add node (not replacing buildable_to) (pos,nodename)",
	action=function(pos,name)
		if was.is_string(name) and was.is_pos(pos) and minetest.registered_nodes[name] and not was.protected(pos) then
			if not minetest.check_player_privs(was.userdata.name,{was=true}) and vector.distance(was.userdata.pos,pos)>50 then
				was.userdata.error="for safety reasons is the max distance 50 without the was privilege"
				return
			end
			local n=minetest.registered_nodes[minetest.get_node(pos).name]
			if n and n.buildable_to==false then
				return
			end
			local inv=minetest.get_meta(was.userdata.pos):get_inventory()
			if not inv:contains_item("storage",name) then
				return
			end
			inv:remove_item("storage",name)

			minetest.set_node(pos,{name=name})
		end
	end
})

was.register_function("node.remove",{
	info="remove node (pos)",
	action=function(pos)
		if was.is_pos(pos) and not minetest.is_protected(pos,was.userdata.name) then
			if not minetest.check_player_privs(was.userdata.name,{was=true}) and vector.distance(was.userdata.pos,pos)>30 then
				was.userdata.error="for safety reasons is the max distance 30 without the was privilege"
				return
			end
			local n=minetest.registered_nodes[minetest.get_node(pos).name]
			local player=minetest.get_player_by_name(was.userdata.name)
			if n and ((n.can_dig and player and n.can_dig(pos, player)==false) or (n.pointable==false) or n.drop=="") then
				return
			end
			minetest.get_meta(was.userdata.pos):get_inventory():add_item("storage",minetest.get_node(pos).name)
			minetest.remove_node(pos)	
		end
	end
})

was.register_function("node.set_param",{
	info="Set node param (pos,number)",
	action=function(pos,p)
		if was.is_pos(pos) and was.is_number(p) and not was.protected(pos) then
			minetest.swap_node(pos,{name=minetest.get_node(pos).name,param2=p})	
		end
	end
})

was.register_function("node.get_param",{
	info="Get node param (pos)",
	action=function(pos)
		if was.is_pos(pos) then
			return minetest.get_node(pos).param2
		end
	end
})


was.register_function("node.get_name",{
	info="get node name (pos)",
	action=function(pos)
		if was.is_pos(pos) then
			return minetest.get_node(pos).name
		end
	end
})

was.register_function("node.exist",{
	info="node exist (name)",
	action=function(name)
		return ((was.is_string(name) or nil) and minetest.registered_nodes[name]~=nil)
	end
})

--[[
================= NODEE=META =================
--]]

was.register_function("nodemeta.set_int",{
	privs={was=true},
	info="Set node meta (pos name number)",
	action=function(pos,na,n)
		if was.is_pos(pos) and was.is_string(na) and was.is_number(n) then
			minetest.get_meta(pos):set_int(na,n)
		end
	end
})

was.register_function("nodemeta.get_int",{
	privs={was=true},
	info="Get node meta (pos name)",
	action=function(pos,na)
		if was.is_pos(pos) and was.is_string(na) then
			return minetest.get_meta(pos):get_int(na)
		end
	end
})

was.register_function("nodemeta.set_string",{
	privs={was=true},
	info="Set node meta (pos name string)",
	action=function(pos,na,n)
		if was.is_pos(pos) and was.is_string(na) and was.is_string(n) then
			minetest.get_meta(pos):set_string(na,n)
		end
	end
})

was.register_function("nodemeta.get_string",{
	privs={was=true},
	info="Get node meta (pos name)",
	action=function(pos,na)
		if was.is_pos(pos) and was.is_string(na) then
			return minetest.get_meta(pos):get_string(na)
		end
	end
})

was.register_function("nodetimer.start",{
	privs={was=true},
	info="Start node timer (<time> <nothing or pos>) to start on another node requires was privilege ",
	action=function(n,pos)
		if was.protected(pos) then
			return
		elseif not pos and was.is_number(n) then
			minetest.get_node_timer(was.userdata.pos):start(n)
		elseif pos and minetest.check_player_privs(was.userdata.name,{was=true}) and was.is_number(n) and was.is_pos(pos) then
			minetest.get_node_timer(pos):start(n)
		end
	end
})


was.register_function("nodetimer.stop",{
	privs={was=true},
	info="Stop node timer (nothing or pos) to stop on another node requires was privilege ",
	action=function(pos)
		if was.protected(pos) then
			return
		elseif not pos then
			minetest.get_node_timer(was.userdata.pos):stop()
		elseif pos and minetest.check_player_privs(was.userdata.name,{was=true}) and was.is_pos(pos) then
			minetest.get_node_timer(pos):stop()
		end
	end
})
--[[
================= MESECONS =================
--]]

was.register_function("mesecon.on",{
	depends="mesecons",
	info="Set mesecon on (nothing or pos) to effect another node requires was privilege ",
	action=function(pos)
		if was.protected(pos) then
			return
		elseif not pos then
			mesecon.receptor_on(was.userdata.pos)
		elseif pos and minetest.check_player_privs(was.userdata.name,{was=true}) and was.is_pos(pos) then
			mesecon.receptor_on(pos)
		end
	end
})

was.register_function("mesecon.off",{
	depends="mesecons",
	info="Set mesecon off (nothing or pos) to effect another node requires was privilege ",
	action=function(pos)
		if was.protected(pos) then
			return
		elseif not pos then
			mesecon.receptor_off(was.userdata.pos)
		elseif pos and minetest.check_player_privs(was.userdata.name,{was=true}) and was.is_pos(pos) then
			mesecon.receptor_off(pos)
		end
	end
})

was.register_function("mesecon.send",{
	depends="mesecons",
	info="Send a mesecon signal (nothing or pos) to effect another node requires was privilege ",
	action=function(pos)
		if was.protected(pos) then
			return
		elseif not pos then
			local p=was.userdata.pos
			mesecon.receptor_on(p)
			minetest.after(1, function(p)
				mesecon.receptor_off(p)
			end, p)
		elseif pos and minetest.check_player_privs(was.userdata.name,{was=true}) and was.is_pos(pos) then
			mesecon.receptor_on(pos)
			minetest.after(1, function(pos)
				mesecon.receptor_off(pos)
			end, pos)
		end
	end
})

--[[
================= digilines =================
--]]

was.register_function("digiline.send",{
	info="Send digiline data through wires (string_channel data)",
	depends="digilines",
	action=function(channel,data)
		local p=was.userdata.pos
		if p and was.is_string(channel) then
			local meta = minetest.get_meta(p)
			local nchannel=meta:get_string("channel")
			if nchannel==channel then
				was.userdata.error="can't send to same channel"
			else
				digilines.receptor_send(p,digilines.rules.default,channel,data)
			end
		end	
	end
})




--[[
================= PLAYER =================
--]]

was.register_function("player.msg",{
	privs={shout=true},
	info="Message to player (playername text)",
	action=function(name,msg)
		if was.is_string(name) and (was.is_string(msg) or was.is_number(msg)) then
			minetest.chat_send_player(name, "<" .. was.userdata.name .."> " .. msg)
		end
	end
})

was.register_function("player.say",{
	privs={shout=true},
	info="Chatt (text)",
	action=function(msg)
		if was.is_string(msg) or was.is_number(msg) then
			minetest.chat_send_all("<" .. was.userdata.name .."> " .. msg)
		end
	end
})

was.register_function("player.server",{
	privs={ban=true,was=true},
	info="Server message (text)",
	action=function(msg)
		if was.is_string(msg) or was.is_number(msg) then
			minetest.chat_send_all(msg)
		end
	end
})

was.register_function("player.get_pos",{
	info="get player pos (playername)",
	action=function(name)
		if not was.is_string(name) then
			return
		end
		local p=minetest.get_player_by_name(name)
		if p then
			return p:get_pos()
		end
	end
})

was.register_function("player.set_pos",{
	privs={teleport=true,bring=true},
	info="set player pos (playername)",
	action=function(name,pos)
		if not (was.is_string(name) and was.is_pos(pos)) then
			return
		end
		local p=minetest.get_player_by_name(name)
		if p then
			return p:set_pos(pos)
		end
	end
})

--[[
================= ENTIY =================
--]]

was.register_function("entity.spawn_item",{
	info="Spawn item (pos name)",
	action=function(pos,name)
		if was.is_pos(pos) and was.is_string(name) and minetest.registered_items[name] then
			local inv=minetest.get_meta(was.userdata.pos):get_inventory()
			if not inv:contains_item("storage",name) then
				return
			end
			inv:remove_item("storage",name)
			minetest.add_item(pos,name)
		end
		local p=minetest.get_player_by_name(name)
	end
})

was.register_function("entity.remove_item",{
	info="Remove item (pos)",
	action=function(pos)
		if was.is_pos(pos) and not was.protected(pos) then
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
				local en=ob:get_luaentity()
				if en and en.name=="__builtin:item" then
					minetest.get_meta(was.userdata.pos):get_inventory():add_item("storage",en.itemstring)
					en.object:remove()
				end
			end
		end
	end
})


--[[
================= MISC =================
--]]

was.register_function("for",{
	info="for loop (startn endn) max loops is 1000, no negative values",
	action=function(s,e)
		if was.is_number(s) and was.is_number(e) then
			if s<0 or e<0 then
				return {msg='No negative value to "for"'}
			elseif math.abs(math.abs(s)-math.abs(e))>1000 then
				return {msg='Too high number to "for" (max 1000)'}
			end
			return {s=s,e=e}
		end
		return {msg='void arguments to "for", ' .. type(s) .." "  .. type(e)}
	end
})

was.register_function("elseif",{
	packed=true,
	info="Used with if",
	action=function(arg)
		return was.functions["if"](arg)
	end
})

was.register_function("if",{
	packed=true,
	info="able oparators: and or not nor == ~= < > => =<",
	action=function(arg)
		local logic={}
		local AND
		local OR
		local NOT
		local NOR
		local li=0
		local i=2

		while i<#arg do
		local a=arg[i]

		if arg[i-1]=="!" then
			arg[i-1]=nil
		end
		if arg[i+1]=="!" then
			arg[i+1]=nil
		end


		if a=="==" then
			table.insert(logic,(arg[i-1] == arg[i+1]))
			li=li+1
		elseif a=="~=" then
			table.insert(logic,(arg[i-1] ~= arg[i+1]))
			li=li+1
		elseif a=="<" and type(arg[i-1])=="number" and type(arg[i+1])=="number" then
			table.insert(logic,(arg[i-1] < arg[i+1]))
			li=li+1
		elseif a==">" and type(arg[i-1])=="number" and type(arg[i+1])=="number" then
			table.insert(logic,(arg[i-1] > arg[i+1]))
			li=li+1
		elseif a=="<=" and type(arg[i-1])=="number" and type(arg[i+1])=="number" then
			table.insert(logic,(arg[i-1] <= arg[i+1]))
			li=li+1
		elseif a==">=" and type(arg[i-1])=="number" and type(arg[i+1])=="number" then
			table.insert(logic,(arg[i-1] >= arg[i+1]))
			li=li+1
		end

		if li>1 and AND and not (logic[li]==true and logic[li-1]==true) then
			AND=nil
			return false
		elseif li>1 and a  and OR and not (logic[li]==true or logic[li-1]==true) then
			OR=nil
			return false
		elseif li>1 and a and NOT and (logic[li]==true and logic[li-1]==true) then
			NOT=nil
			return false
		elseif li>1 and a and NOR and (logic[li]==true or logic[li-1]==true) then
			NOR=nil
			return false
		end

		if arg[i]=="and" or arg[i]=="or" or arg[i]=="not" or arg[i]=="nor" then
			AND=arg[i]=="and"
			OR=arg[i]=="or"
			NOT=arg[i]=="not"
			NOR=arg[i]=="nor"
		end

		i=i+2
		end



		if li<2 then
			return logic[li]==true
		else
			return true
		end
	end
})

was.register_function("print",{
	packed=true,
	action=function(a)
		if was.userdata.print then
			local ud=was.user[was.userdata.name]
			if ud and was.userdata.id==ud.id then
				local s=""
				for i,v in pairs(a) do
					if was.is_string(v) or was.is_number(v) then
						s=s .. v .. " "
					elseif was.is_table(v) then
						local t=""
						for ind,val in pairs(v) do
							t=t .. ind .."="
							if was.is_number(val) then
								t=t .. val .." "
							elseif was.is_string(val) then
								t=t .. '"' .. val ..'" '
							else
								t=t .. "table "
							end
						end

						s=s .. t
					elseif type(v)=="boolean" then
						if v==true then
							s=s .."true "
						else
							s=s .."false "
						end
					else
						s=s .."!"
					end
				end
				if s:len()>60 then
					s=s:sub(0,60)
				end
				if s:len()>30 then
					s=s:sub(0,30) .."\n" .. s:sub(31,s:len())
				end
				ud.console_text=ud.console_text or ""
				ud.console_lines=(ud.console_lines and (ud.console_lines+1)) or 1
				ud.console_text=ud.console_text .. s .. "\n"
				ud.console="true"
				if ud.console_lines>27 then
					ud.console_text=ud.console_text:sub(ud.console_text:find("\n")+1,ud.console_text:len())
					ud.console_lines=27
				end
				was.gui(was.userdata.name)
			elseif minetest.check_player_privs(was.userdata.name,{server=true}) then
				print(unpack(a))
			end
		end
	end
})

was.register_function("dump",{
	privs={server=true},
	packed=true,
	action=function(a)
		print(dump(a))
	end
})

was.register_function("get.pos",{
	info="Get position",
	action=function()
		return was.userdata.pos
	end
})

was.register_function("time",{
	info='Get/compare time ("type" time_number) type "gettime" to return currently time, or  "sec","min","hour","day" to compare the time ',
	action=function(a,c)
		if was.is_string(a) and was.is_number(c) then
			return was.time(a,c)
		end
	end
})

was.register_function("was.send",{
	info="Send data through wires (string_channel data)",
	action=function(channel,msg)
		local p=was.userdata.pos
		if p and was.is_string(channel) then
			local meta = minetest.get_meta(p)
			local nchannel=meta:get_string("channel")
			if nchannel==channel then
				was.userdata.error="can't send to same channel"
			else
				was.send(p,channel,msg,nchannel)
			end
		end	
	end
})
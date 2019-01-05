
--[[
================= SYMBOLS =================
--]]

was.register_symbol("?",
	function(data,variables,user)
		return user
	end,
	"return username"
)

--[[
================= SERVER =================
--]]

was.register_function("print",{
	privs={server=true},
	packed=true,
	action=function(a)
		print(unpack(a))
	end
})

was.register_function("dump",{
	privs={server=true},
	packed=true,
	action=function(a)
		print(dump(a))
	end
})

--[[
================= DATATYPES = VARIABLES =================
--]]

was.register_function("pos",{
	info="numbers to pos (n1 n2 n3)",
	action=function(n1,n2,n3)
		if type(n1)=="number" and type(n2)=="number" and type(n3)=="number" then
			return {x=n1,y=n2,z=n3}
		end
	end
})


--[[
================= NODES =================
--]]

was.register_function("node.set",{
	info="set node (pos,nodename)",
	privs={give=true,ban=true},
	action=function(pos,name)
		if was.is_string(name) and was.is_pos(pos) and minetest.registered_nodes[name] and not minetest.is_protected(pos,was.username) then
			minetest.set_node(pos,{name=name})
		end
	end
})

was.register_function("node.add",{
	info="add node (pos,nodename)",
	privs={give=true,kick=true},
	action=function(pos,name)
		if was.is_string(name) and was.is_pos(pos) and minetest.registered_nodes[name] and not minetest.is_protected(pos,was.username) then
			minetest.add_node(pos,{name=name})
		end
	end
})

was.register_function("node.get_name",{
	info="get node name (pos)",
	action=function(pos)
		return (was.is_pos(pos) and minetest.get_node(pos).name or nil)
	end
})

was.register_function("node.exist",{
	info="node exist (name)",
	action=function(name)
		return ((was.is_string(name) or nil) and minetest.registered_nodes[name]~=nil)
	end
})

--[[
================= PLAYER =================
--]]

was.register_function("player.get_pos",{
	info="get player name (playername)",
	action=function(name)
		if type(name)~="string" then
			return
		end
		local p=minetest.get_player_by_name(name)
		if p then
			return p:get_pos()
		end
	end
})

--[[
================= MISC =================
--]]

was.register_function("elseif",{
	packed=true,
	info="Used with if",
	action=function(arg)
		return was.functions["if"](arg)
	end
})
was.register_function("else",{
	packed=true,
	info="Used with if",
	action=function(arg)
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
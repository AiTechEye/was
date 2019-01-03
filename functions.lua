was.register_function("test",{
	action=function(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9)
		print(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9)
	end
})

was.register_function("pos",{
	info="to pos (n1 n2 n3)",
	action=function(n1,n2,n3)
		if type(n1)=="number" and type(n2)=="number" and type(n3)=="number" then
			return {x=n1,y=n2,z=n3}
		end
	end
})

was.register_function("node.set",{
	info="(pos,nodename)",
	privs={give=true,ban=true},
	action=function(pos,name)
		if was.is_string(name) and was.is_pos(pos) and minetest.registered_nodes[name] then
			minetest.set_node(pos,{name=name})
		end
	end
})

was.register_function("player.get_pos",{
	info="(playername)",
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

was.register_function("if",{
	info="able oparators: and or not nor == ~= < > => =<",
	action=function(arg)
		local logic={}
		local AND
		local OR
		local NOT
		local NOR
		local li=0
		local i=2

		if #arg<3 then
			return false
		end

		while i<#arg do
		local a=arg[i]

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
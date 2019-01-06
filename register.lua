
--[[
================= SYMBOLS =================
--]]

was.register_symbol("?",
	function()
		return was.userdata.name
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

was.register_function("percent",{
	info="return percent of number (n1 n2)",
	action=function(a,b)
		if was.is_number(a) and was.is_number(b) then
			return (a / b) *100
		end
	end
})


was.register_function("pi",{
	info="return Pi",
	action=function()
		return math.pi
	end
})

was.register_function("math",{
	info="Math + - * % ^ /  ('-' 1 2 67...)",
	packed=true,
	action=function(a)
		local c=a[1]
		local n=a[2]
		if not (was.is_string(c) and c:len()==1 and string.find("%^+-*/",c)) then
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
				elseif c=="%" then
					n=n%a[i]
				end
			end
		end
		return n
	end
})

was.register_function("table",{
	info="return empty table",
	action=function()
		return {}
	end
})

was.register_function("getvalue",{
	info="get table value (table key-string/number)",
	action=function(t,i)
		if was.is_table(t) and (was.is_number(i) or was.is_string(i)) then
			return t[i]
		end
	end
})

was.register_function("setvalue",{
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

was.register_function("remove",{
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

was.register_function("insert",{
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
	privs={give=true,ban=true},
	action=function(pos,name)
		if was.is_string(name) and was.is_pos(pos) and minetest.registered_nodes[name] and not minetest.is_protected(pos,was.userdata.name) then
			minetest.set_node(pos,{name=name})
		end
	end
})

was.register_function("node.add",{
	info="add node (pos,nodename)",
	privs={give=true,kick=true},
	action=function(pos,name)
		if was.is_string(name) and was.is_pos(pos) and minetest.registered_nodes[name] and not minetest.is_protected(pos,was.userdata.name) then
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
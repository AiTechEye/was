was.register_function=function(name,t)
	was.functions[name]=t.action
	was.function_packed[name]=t.packed
	was.info[name]=t.info
	was.privs[name]=t.privs
end

was.register_symbol=function(symbol,f,info)
	was.symbols[symbol]=f
	was.info[symbol]=info
end

was.chr=function(t)
	local a=string.byte(t)
	return (a>=65 and a<=90) or (a>=97 and a<=122) or t=="." or t=="_" or t=="-"
end

was.num=function(t)
	local a=string.byte(t)
	return a>=48 and a<=57
end

was.symbol=function(t)
	return was.symbols_characters:find(t)
end

was.is_number=function(n)
	return type(n)=="number"
end
was.is_string=function(s)
	return type(s)=="string"
end
was.is_pos=function(pos)
	return type(pos)=="table" and type(pos.x)=="number" and type(pos.y)=="number" and type(pos.z)=="number"
end

was.compiler=function(input_text,user)
	if type(input_text)~="string" or input_text:len()<2 then
		return
	end
	input_text=input_text .."\n"
	input_text=input_text:gsub("%(","{")
	input_text=input_text:gsub("%)","}")
	input_text=input_text:gsub("%[","")
	input_text=input_text:gsub("%]","")

	for i=1,was.symbols_characters:len(),1 do
		local c=was.symbols_characters:sub(i,i)
		input_text=input_text:gsub("%" ..c," " .. c .." ")
	end

	local c
	local data={}
	local output_data={}
	local n
	local chr
	local s
	local ob={type="",content=""}
	for i=1,input_text:len(),1 do
		c=input_text:sub(i,i)

		n=was.num(c)
		chr=was.chr(c)
		s=was.symbol(c)
--string
		if c=='"' and ob.type~="string" then
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
			ob.type="string"
		elseif c=='"' and ob.type=="string" then
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
		end
		if ob.type=="string" and c~='"' then
			ob.content=ob.content .. c
		end	
--number
		if n and ob.type=="" then
			ob.type="number"
		elseif not n and ob.type=="number" and c~="." then
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
		end
		if ob.type=="number" then
			ob.content=ob.content .. c
		end
--var
		if ob.type=="" and chr then
			ob.type="var"
		elseif ob.type=="var" and not chr and c~="." then
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
		end
		if ob.type=="var" then
			ob.content=ob.content .. c
		end
--symbols
		if ob.type=="" and s then
			ob.type="symbol"
		elseif ob.type=="symbol" and not s then
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
		end
		if ob.type=="symbol" then
			ob.content=ob.content .. c
		end

--end of line
		if c=="\n" then
			if ob.content~="" then table.insert(data,ob) end
			table.insert(output_data,data)
			ob={type="",content=""}
			data={}
		end
	end
	local output_data2={}
	local func
--print(dump(output_data))
	local ifends=0
	for i,v in ipairs(output_data) do
		local ii=1
		data=v
		while ii<=#v do
			if data[ii].type=="number" then
--number
				data[ii].content=tonumber(data[ii].content)

			elseif data[ii].type=="var" and (data[ii].content=="and" or data[ii].content=="or" or data[ii].content=="not" or data[ii].content=="nor") then
--oparator
				data[ii].type="symbol"
			elseif data[ii].type=="var" and (data[ii].content=="false" or data[ii].content=="true") then
--bool
				data[ii].type="bool"
				data[ii].content=data[ii].content=="true"

			elseif data[ii].content=="elseif" or data[ii].content=="else" or (ifends>0 and data[ii].content=="end") then
--elseif, else end
				data[ii].type="ifstate"
				data[ii].ifstate=true
				if data[ii].content=="end" then
					ifends=ifends-1
				end
			elseif data[ii+1] and data[ii].type=="var" and data[ii].content=="global" and data[ii+1].type=="var" then
--global var
				data[ii+1].global=true
			elseif data[ii+1] and data[ii].type=="symbol" and data[ii+1].type=="symbol" and was.symbols[data[ii].content ..  data[ii+1].content] and data[ii].content~="}" and data[ii+1].content~="}" then
--2 symbols to oparator
				data[ii].content=data[ii].content .. data[ii+1].content
				table.remove(data,ii+1)
			elseif data[ii+1] and data[ii+2] and data[ii].type=="var" and data[ii+1].content=="=" and not was.symbols[data[ii+1].content ..  data[ii+2].content] then
--var =
				if func then
					return 'ERROR line '.. i ..': set variable "' ..data[ii].content .. '" inside function'
				end
				data[ii].type="set var"
				table.remove(data,ii+1)
			elseif data[ii+1] and data[ii].type=="var" and data[ii+1].content=="{" then
--function(
				if not was.functions[data[ii].content] then
					return 'ERROR line '.. i ..': void function "' .. data[ii].content ..'"'
				end
				func=true
				data[ii].type="function"
				if data[ii].content=="if" then
					data[ii].ifstate=true
					ifends=ifends+1
				end
				table.remove(data,ii+1)
			elseif data[ii].content=="}" then
--)				
				func=nil
				data[ii].type="bracket end"
			end
			ii=ii+1
		end

		if func then
			return 'ERROR line '.. i ..': missing ")"'
		end

		table.insert(output_data2,data)
	end

	if user then
		for i,c in pairs(output_data2) do
		for name,v in pairs(c) do
			if v.type=="function" and was.privs[v.content] and not minetest.check_player_privs(user,was.privs[v.content]) then
				return 'ERROR: the function "' .. v.content ..'" requires privileges: ' .. minetest.privs_to_string(was.privs[v.content])
			end
		end
		end
	end

	if ifends>0 then
		return 'ERROR: Missing ' .. ifends .. ' if "end"'
	end

	user=user or ":server:"
	was.user[user]=was.user[user] or {}
	was.user[user].global=was.user[user].global or {}

	was.run(output_data2,user)
end

was.run_function=function(func_name,data,VAR,i,ii,userdata)
	local d={}
	local open=0
	while i<=ii do
		if data[i].type=="bracket end" then
			if open<=0 then
				break
			else
				open=open-1
			end
		elseif data[i].type=="function" then
			open=open+1
		end

		if data[i].type=="number" or data[i].type=="string" or data[i].type=="bool" then
			table.insert(d,data[i].content)

		elseif data[i].type=="symbol" and was.symbols[data[i].content] then
			local a=was.symbols[data[i].content](userdata.var,userdata.variables,userdata.user,func_name)
			if a then
				table.insert(d, a)
			end
		elseif data[i].type=="var" then
			table.insert(d,VAR[data[i].content] or func_name=="if" and "!") 
		elseif data[i].type=="function" and was.functions[data[i].content] then
			local re,newi=was.run_function(data[i].content,data,VAR,i+1,#data) 
			i=newi
			if re then
				table.insert(d,re or func_name=="if" and "!")
			end
		end
		i=i+1
	end

	if was.function_packed[func_name] then
		return was.functions[func_name](d,userdata),i
	else
		return was.functions[func_name](unpack(d)),i	
	end
end

was.run=function(input,user)
	local VAR=was.user[user].global
	local state=0
	local elsestate=0
	was.username=user
--print(dump(input))
	for index,v in ipairs(input) do
		local i=1
		while i<=#v do
			if v[i].ifstate then
				if v[i].content=="if" then
					if state==0 and was.run_function(v[i].content,v,VAR,i+1,#v,{var=VAR[v[i].content],variables=VAR,user=user})==true then
						state=0
					else
						state=state+1
					end
				end
				if v[i].content=="elseif" then
					if state==0 then
						state=1
						elsestate=1
					elseif state==1 and elsestate==0 and was.run_function(v[i].content,v,VAR,i+1,#v,{var=VAR[v[i].content],variables=VAR,user=user})==true then
						state=0
					end
				elseif v[i].content=="else" then
					if state==0 then
						state=1
					elseif state==1 and elsestate==0 then
						state=0
					end
				elseif v[i].content=="end" then
					state=state-1
					if state<=0 then
						state=0
						elsestate=0
					end
				end
			elseif state>0 then

			elseif v[i].type=="set var" and v[i+1] then
				local ndat=v[i+1]
				if (ndat.type=="string" or ndat.type=="number" or ndat.type=="bool") and ndat.content then
					VAR[v[i].content]=ndat.content
				elseif ndat.type=="symbol" and was.symbols[ndat.content] then
					VAR[v[i].content]=was.symbols[ndat.content](VAR[v[i].content],VAR,user)
				elseif ndat.type=="var" and VAR[ndat.content] then
					VAR[v[i].content]=VAR[ndat.content]
				elseif ndat.type=="function" and was.functions[ndat.content] then
					VAR[v[i].content]=was.run_function(ndat.content,v,VAR,i+2,#v,{var=VAR[v[i].content],variables=VAR,user=user})
				else
					VAR[v[i].content]=nil
				end

				if v[i].global then
					was.user[user].global[v[i].content]=VAR[v[i].content]
				end

				i=i+1
			elseif v[i].type=="function" then
				was.run_function(v[i].content,v,VAR,i+1,#v,{var=VAR[v[i].content],variables=VAR,user=user})
				i=i+1
			elseif v[i].type=="symbol" and was.symbols[v[i].content] then
				was.symbols[v[i].content](VAR[v[i].content],VAR,user)
			end
			i=i+1
		end
	end
	was.username=""
	--print(dump(VAR))
end
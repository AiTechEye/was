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
was.is_table=function(t)
	return type(t)=="table"
end

was.ilastuserdata=function()
	for i=was.userdata.index,#was.userdata.data,1 do
		if not was.userdata.data[i+1] or was.userdata.data[i].type=="bracket end" then
			return i
		end
	end
	return 1
end

was.iuserdata=function(i)
	local v=was.userdata.data[i]
	if v and v.type~="set var" and v.type~="function" and v.type~="bracket end" then
		if v.type=="var" then
			v=was.userdata.var[v.content]
		else
			v=v.content
		end
	else
		return 
	end
	return v
end

was.compiler=function(input_text,user)
	if type(input_text)~="string" or input_text:len()<2 then
		return
	end
	input_text=input_text .."\n"
	input_text=input_text:gsub("%("," { ")
	input_text=input_text:gsub("%)"," } ")
	input_text=input_text:gsub("%[","")
	input_text=input_text:gsub("%]","")

	for i=1,was.symbols_characters:len(),1 do
		local c=was.symbols_characters:sub(i,i)
	end

	local c
	local data={}
	local output_data={}
	local n
	local chr
	local s
	local ob={type="",content=""}
	local i=1
	while i<=input_text:len() do
		c=input_text:sub(i,i)

		n=was.num(c)
		chr=was.chr(c)
		s=was.symbol(c)

		if c=='"' and ob.type~="string" then
--string
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
			ob.type="string"
			c=""
		elseif c=='"' and ob.type=="string" then
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
		elseif n and ob.type=="" then
--number
			ob.type="number"
		elseif not n and ob.type=="number" and c~="." then
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
			i=i-1
		elseif ob.type=="" and chr then
--var
			ob.type="var"
		elseif ob.type=="var" and not chr and c~="." then
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
			i=i-1
		elseif ob.type=="" and s then
--symbols
			ob.type="symbol"
		elseif ob.type=="symbol" and not s then
			if ob.content~="" then table.insert(data,ob) end
			ob={type="",content=""}
			i=i-1
		elseif c=="\n" then
--end of line
			if ob.content~="" then table.insert(data,ob) end
			table.insert(output_data,data)
			ob={type="",content=""}
			data={}
		end
		if ob.type~="" then
			ob.content=ob.content .. c
		end	
		i=i+1
	end
	local output_data2={}
	local func
--print(dump(output_data))
	local ifends=0
	local nexts=0
	for i,v in ipairs(output_data) do
		local ii=1
		data=v
		while ii<=#v do
			if data[ii].type=="number" then
--number
				data[ii].content=tonumber(data[ii].content)

				if data[ii-1] and data[ii-1].content=="-" then
					data[ii].content=-data[ii].content
					table.remove(data,ii-1)
					ii=ii-1
				end
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
				elseif data[ii].content=="for" then
					if nexts==1 then
						return 'ERROR line '.. i ..': only 1 "for" at time'
					end
					nexts=1
					data[ii].forstate=true
				end
				table.remove(data,ii+1)
			elseif data[ii].content=="}" then
--)				
				func=nil
				data[ii].type="bracket end"
			elseif data[ii].type=="var" and data[ii].content=="next" then
				if nexts==0 then
					return 'ERROR line '.. i ..': no "for" to return to'
				end
				nexts=0
				data[ii].forstate=true

			end
			ii=ii+1
		end

		if func then
			return 'ERROR line '.. i ..': missing ")"'
		end

		table.insert(output_data2,data)
	end
--print(dump(output_data2))
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

	if nexts>0 then
		return 'ERROR: Missing ' .. nexts .. ' for "next"'
	end


	user=user or ":server:"
	was.user[user]=was.user[user] or {}
	was.user[user].global=was.user[user].global or {}

	return was.run(output_data2,user)
end

was.run_function=function(func_name,data,VAR,i,ii)
	local d={}
	local open=0
	was.userdata.function_name=func_name
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
			was.userdata.index=i
			local a=was.symbols[data[i].content]()
			if a then
				table.insert(d, a)
			end
		elseif data[i].type=="var" then
			table.insert(d,VAR[data[i].content] or func_name=="if" and "!") 
		elseif data[i].type=="function" then
			was.userdata.index=i
			local re,newi=was.run_function(data[i].content,data,VAR,i+1,#data) 
			i=newi
			if re then
				table.insert(d,re or func_name=="if" and "!")
			end
		end

		i=i+1
	end

	if was.function_packed[func_name] then
		return was.functions[func_name](d),i
	else
		return was.functions[func_name](unpack(d)),i	
	end
end

was.run=function(input,user)
	local VAR=table.copy(was.user[user].global)
	local state=0
	local elsestate=0
	local forstate
	was.userdata={
		name=user,
		function_name="",
		index=0,
		data={},
	}

--print(dump(input))

	local index=0
	while index<#input do
	index=index+1
	local v=input[index]

		local i=1
		while i<=#v do

			was.userdata.data=v
			was.userdata.index=i
			was.userdata.var=VAR

			if v[i].forstate then
				if v[i].content=="next" then

					if forstate.i<forstate.e then
						index=forstate.re
						forstate.i=forstate.i+1
					else
						forstate=nil
					end
				elseif v[i].content=="for" then
					local fo=was.run_function(v[i].content,v,VAR,i+1,#v)
					forstate={
						re=index,
						i=fo.s,
						e=fo.e,
					}
					if fo.msg then
						return fo.msg
					end
				end
			elseif v[i].ifstate then
				if v[i].content=="if" then
					if state==0 and was.run_function(v[i].content,v,VAR,i+1,#v)==true then
						state=0
					else
						state=state+1
					end
				end
				if v[i].content=="elseif" then
					if state==0 then
						state=1
						elsestate=1
					elseif state==1 and elsestate==0 and was.run_function(v[i].content,v,VAR,i+1,#v)==true then
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
				if (ndat.type=="string" or ndat.type=="number" or ndat.type=="bool") then
					VAR[v[i].content]=ndat.content
				elseif ndat.type=="symbol" and was.symbols[ndat.content] then
					VAR[v[i].content]=was.symbols[ndat.content]()
				elseif ndat.type=="var" and VAR[ndat.content] then
					VAR[v[i].content]=VAR[ndat.content]
				elseif ndat.type=="function" and was.functions[ndat.content] then
					VAR[v[i].content]=was.run_function(ndat.content,v,VAR,i+2,#v)
				else
					VAR[v[i].content]=nil
				end

				if v[i].global then
					was.user[user].global[v[i].content]=VAR[v[i].content]
				end

				i=i+1
			elseif v[i].type=="function" then
				was.run_function(v[i].content,v,VAR,i+1,#v)
				i=i+1
			elseif v[i].type=="symbol" and was.symbols[v[i].content] then
				was.symbols[v[i].content]()
			end

			i=i+1
		end
	end
	was.userdata={}
	--print(dump(VAR))
end
was.time=function(a,c)
	if a=="gettime" then
		return os.time()
	else
		if a=="sec" then
			return os.difftime(os.time(), c)
		elseif a=="min" then
			return os.difftime(os.time(), c) / 60
		elseif a=="hour" then
			return os.difftime(os.time(), c) / (60 * 60)
		elseif a=="day" then
			return os.difftime(os.time(), c) / (24 * 60 * 60)
		end
	end
end


was.runcmd=function(cmd,name,param)
	local c=minetest.registered_chatcommands[cmd]
	if not c then
		return 
	end
	local p1=minetest.check_player_privs(name, c.privs)
	local msg=""
	local a
	if not p1 then
		msg="You aren't' allowed to do that"
	elseif c then
		a,msg=c.func(name,param)
		msg=msg or ""
		minetest.chat_send_player(name,msg)

	end
	return msg
end

was.send=function(pos,channel,msg,from_channel)
	local na=pos.x .."." .. pos.y .."." ..pos.z
	if not was.wire_signals[na] then
		local t=os.time()
		if os.difftime(t, was.wire_sends.last)>1 then
			was.wire_sends.last=t
			was.wire_sends.times=0
		else
			was.wire_sends.times=was.wire_sends.times+1
			if was.wire_sends.times>50 then
				return
			end

		end
		was.wire_signals[na]={jobs={[na]=pos},msg=msg,channel=channel,from_channel=from_channel}
		minetest.after(0, function()
			was.wire_leading()
		end)
	end
end

was.get_node=function(pos,wire)
	local n=minetest.get_node(pos).name
	if n=="ignore" then
		local vox=minetest.get_voxel_manip()
		local min, max=vox:read_from_map(pos, pos)
		local area=VoxelArea:new({MinEdge = min, MaxEdge = max})
		local data=vox:get_data()
		local i=area:indexp(pos)
		n=minetest.get_name_from_content_id(data[i])
	end
	return n
end

was.wire_leading=function()
	local counts=0
	for i, a in pairs(was.wire_signals) do
		local c=0
		for xyz, pos in pairs(a.jobs) do
			if not pos.ignore then
				for ii, p in pairs(was.wire_rules) do
					local n={x=pos.x+p[1],y=pos.y+p[2],z=pos.z+p[3]}
					local s=n.x .. "." .. n.y .."." ..n.z
					local na=was.get_node(n)
					if not a.jobs[s] then
						if minetest.get_item_group(na,"was_wire")>0 then
							a.jobs[s]=n
							c=c+1
							minetest.swap_node(n,{name=na,param2=3})
							minetest.get_node_timer(n):start(0.1)
							if minetest.registered_nodes[na].on_waswire then
								minetest.registered_nodes[na].on_waswire(n,a.channel,a.from_channel,a.msg)
							end
						elseif minetest.get_item_group(na,"was_unit")>0 and minetest.registered_nodes[na].on_waswire then
							minetest.registered_nodes[na].on_waswire(n,a.channel,a.from_channel,a.msg)
							a.jobs[s]={ignore=true}
							c=c+1
						end
					end
				end
			end

		end
		if c==0 then
			was.wire_signals[i]=nil
		else
			counts=counts+c
		end
	end
	if counts>0 then
		minetest.after(0, function()
			was.wire_leading()
		end)
	else
		was.wire_signals={}
	end
end
was={
	functions={},
	function_list={},
	function_packed={},
	info={},
	privs={},
	user={},
	userdata={},
	symbols={},
	wire_signals={},
	symbols_characters=".#@=?!&{}%*+-/$<>|~^",
}

dofile(minetest.get_modpath("was") .. "/api.lua")
dofile(minetest.get_modpath("was") .. "/register.lua")
dofile(minetest.get_modpath("was") .. "/gui.lua")

--minetest.register_chatcommand("was", {
--	description = "World action script gui",
--	func = function(name, param)
--		was.gui(name)
--		return true
--	end,
--})

minetest.register_privilege("was", {
	description = "Full access to functions",
	give_to_singleplayer= false,
})


was.get_node=function(pos)
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
	local po={{0,0,0},{-1,0,0},{1,0,0},{0,0,-1},{0,0,1},{0,-1,0},{0,1,0}}
	for i, a in pairs(was.wire_signals) do
		local c=0
		for xyz, pos in pairs(a.jobs) do
			for ii, p in pairs(po) do
				local n={x=pos.x+p[1],y=pos.y+p[2],z=pos.z+p[3]}
				local s=n.x .. "." .. n.y .."." ..n.z
				local na=was.get_node(n)
				if not a.jobs[s] and minetest.get_item_group(na,"was_wire")>0 then
					a.jobs[s]=n
					c=c+1
				elseif not a.jobs[s] and minetest.get_item_group(na,"was_unit")>0 and minetest.registered_nodes[na].on_waswire then
					minetest.registered_nodes[na].on_waswire(n,a.channel,a.from_channel,a.msg)
					a.jobs[s]=n
					c=c+1
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

minetest.register_node("was:wire", {
	description = "was wire",
	tiles = {
		"was_guibg.png^[colorize:#FFFFFF",
	},
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	walkable=false,
	node_box = {
		type = "connected",
		connect_back={-0.05,-0.5,0, 0.05,-0.45,0.5},
		connect_front={-0.05,-0.5,-0.5, 0.05,-0.45,0},
		connect_left={-0.5,-0.5,-0.05, 0.05,-0.45,0.05},
		connect_right={0,-0.5,-0.05, 0.5,-0.45,0.05},
		connect_top = {-0.05, -0.5, -0.05, 0.05, 0.5, 0.05},
		fixed = {-0.05, -0.5, -0.05, 0.05, -0.45, 0.05},
	},
	connects_to={"group:was_wire","group:was_unit"},
	groups = {dig_immediate = 3,was_wire=1},
	on_construct = function(pos)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name,"was_wire")>0 then
		--	minetest.swap_node(pos,{name="was:wire_up"})
		elseif minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"was_wire")>0 then
		--	minetest.swap_node(pos,{name="was:wire_down"})
		end
	end,
	on_destruct = function(pos)
		--minetest.check_for_falling(pos)
	end
})

minetest.register_node("was:computer", {
	description = "Computer",
	tiles = {
		"was_pc_board.png",
		"was_pc_outside.png",
		"was_pc_screen.png",
		"was_pc_outside.png",
		"was_pc_outside.png",
		"was_pc_screen.png",
	},
	drawtype="nodebox",
	paramtype = "light",
	paramtype2="facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.3, 0.5, -0.43, 0.5},
			{-0.5, -0.5, 0.48, 0.5, 0.3, 0.5},
		}
	},
	groups = {oddly_breakable_by_hand = 3,was_unit=1,tubedevice = 1, tubedevice_receiver = 1},
	on_punch = function(pos, node, player, pointed_thing)
		minetest.swap_node(pos,{name="was:computer_closed",param2=node.param2})
	end,
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name() or "")
		meta:get_inventory():set_size("storage", 50)
		meta:set_string("channel", pos.x .." " ..pos.y .." " ..pos.z)
		minetest.swap_node(pos,{name="was:computer_closed",param2=minetest.get_node(pos).param2})
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			if meta:get_string("owner")=="" then
				return
			end
			minetest.swap_node(pos,{name="was:computer",param2=node.param2})
			was.user[name]={
				nodepos=pos,
				channel=meta:get_string("channel"),
				text=minetest.deserialize(meta:get_string("text")),
				id=pos.x .." " .. pos.y .." " ..pos.z,
			}
			was.gui(name)
		end
	end,
	can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_inventory():is_empty("storage") and (meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true})) then
			return true
		end
	end,
	on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		was.compiler(minetest.deserialize(meta:get_string("text")),{
			user=meta:get_string("owner"),
			pos=pos,
			event={type="timer"}
		})
		return true
	end,
	on_waswire=function(pos,channel,from_channel,msg)
		local meta=minetest.get_meta(pos)
		local user=meta:get_string("owner")
		if user~="" and channel==meta:get_string("channel") then
			was.compiler(minetest.deserialize(meta:get_string("text")),{
				user=user,
				pos=pos,
				event={type="wire",channel=channel,from_channel=from_channel,msg=msg}
			})
		end
	end,
	mesecons = {
		receptor = {state = "off"},
		effector = {
			action_on = function (pos, node)
				local meta=minetest.get_meta(pos)
				local user=meta:get_string("owner")
				was.compiler(minetest.deserialize(meta:get_string("text")),{
					user=meta:get_string("owner"),
					pos=pos,
					event={type="mesecon on"}
				})
			end,
			action_off = function (pos, node)
				local meta=minetest.get_meta(pos)
				local user=meta:get_string("owner")
				was.compiler(minetest.deserialize(meta:get_string("text")),{
					user=user,
					pos=pos,
					event={type="mesecon off"}
				})
			end
		}
	},
	digiline = {
		receptor={},
		effector = {
			action = function (pos,node,channel,msg)
				local meta=minetest.get_meta(pos)
				if meta:get_string("channel")==channel then
					local user=meta:get_string("owner")
					was.compiler(minetest.deserialize(meta:get_string("text")),{
						user=meta:get_string("owner"),
						pos=pos,
						event={type="digiline",channel=channel,msg=msg}
					})
				end
			end,
		}
	},
	tube = {insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local user=meta:get_string("owner")
			local text=minetest.deserialize(meta:get_string("text"))
			local n=stack:get_name()
			local c=stack:get_count()
			minetest.after(0, function(text,user,pos,n,c)
				was.compiler(text,{
					user=user,
					pos=pos,
					event={type="pipeworks",msg={item=n,count=c}}
				})
			end, text,user,pos,n,c)
			return meta:get_inventory():add_item("storage", stack)
		end,
		can_insert = function(pos, node, stack, direction)
			return minetest.get_meta(pos):get_inventory():room_for_item("storage", stack)
		end,
		input_inventory = "storage",
		connect_sides = {left=0,right=0,front=0,top=0,back=1,bottom=1}
	},
})

minetest.register_node("was:computer_closed", {
	description = "Computer",
	drop="was:computer",
	tiles = {
		"was_pc_outside.png",
	},
	drawtype="nodebox",
	paramtype = "light",
	paramtype2="facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.3, 0.5, -0.43, 0.5},
		}
	},
	groups = {oddly_breakable_by_hand = 3,was_unit=1,not_in_creative_inventory=1},
	on_punch = function(pos, node, player, pointed_thing)
		local name=player:get_player_name() or ""
		if minetest.get_meta(pos):get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			minetest.swap_node(pos,{name="was:computer",param2=node.param2})
		end
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.registered_nodes["was:computer"].on_rightclick(pos, node, player, itemstack, pointed_thing)
	end,
	can_dig = function(pos, player)
		return minetest.registered_nodes["was:computer"].can_dig(pos, player)
	end,
})
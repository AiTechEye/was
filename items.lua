minetest.register_craftitem("was:chemical_lump", {
	description = "Chemical lump",
	inventory_image = "was_chemical_lump.png",
})
minetest.register_craftitem("was:plastic_piece", {
	description = "Plastic piece",
	inventory_image = "was_plastic_piece.png",
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
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			minetest.swap_node(pos,{name="was:computer_closed",param2=node.param2})
		end
	end,
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name() or "")
		meta:get_inventory():set_size("storage", 50)
		meta:set_string("channel", pos.x .." " ..pos.y .." " ..pos.z)
		meta:set_string("last_intensity_check",os.time())
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
			local punchpos=was.user[name] and was.user[name].punchpos
			was.user[name]={
				nodepos=pos,
				channel=meta:get_string("channel"),
				text=minetest.deserialize(meta:get_string("text")),
				id=pos.x .." " .. pos.y .." " ..pos.z,
				punchpos=punchpos,
				gui=true,
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
			type="node",
			user=meta:get_string("owner"),
			pos=pos,
			event={type="timer"},
			print=true,
		})
		return true
	end,
	on_waswire=function(pos,channel,from_channel,msg)
		local meta=minetest.get_meta(pos)
		local user=meta:get_string("owner")
		if user~="" and channel==meta:get_string("channel") then
			was.compiler(minetest.deserialize(meta:get_string("text")),{
				type="node",
				user=user,
				pos=pos,
				event={type="wire",channel=channel,from_channel=from_channel,msg=msg},
				print=true,
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
					type="node",
					user=meta:get_string("owner"),
					pos=pos,
					event={type="mesecon on"},
					print=true,
				})
			end,
			action_off = function (pos, node)
				local meta=minetest.get_meta(pos)
				local user=meta:get_string("owner")
				was.compiler(minetest.deserialize(meta:get_string("text")),{
					type="node",
					user=user,
					pos=pos,
					event={type="mesecon off"},
					print=true,
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
						type="node",
						user=meta:get_string("owner"),
						pos=pos,
						event={type="digiline",channel=channel,msg=msg},
						print=true,
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
					type="node",
					user=user,
					pos=pos,
					event={type="pipeworks",msg={item=n,count=c}},
					print=true,
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

minetest.register_node("was:wire", {
	description = "was wire",
	tiles = {{name="was_wire.png"}},
	drop="was:wire",
	drawtype="nodebox",
	paramtype = "light",
	paramtype2="colorwallmounted",
	palette="was_palette.png",
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
	--on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	--	node.param2=node.param2+1
	--	print(node.param2)
	--	minetest.swap_node(pos,node)
	--end,
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="was:wire",param2=135})
	end,
	on_timer = function (pos, elapsed)
		minetest.swap_node(pos,{name="was:wire",param2=135})
	end,
})

minetest.register_node("was:touchscreen", {
	description = "Touchscreen",
	tiles = {"was_touchscreen.png"},
	drawtype="nodebox",
	paramtype = "light",
	paramtype2="facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.15, -0.25, 0.45, 0.15, 0.25, 0.5},
		}
	},
	groups = {cracky = 3,was_unit=1},
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name() or "")
		meta:set_string("channel", pos.x .." " ..pos.y .." " ..pos.z)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name and not player:get_player_control().aux1 then
			local gui="size[2,1.5]field[0,0.3;3,1;channel;Channel;" .. meta:get_string("channel") .."]"
			.."field[0,1.3;3,1;channelto;Send to channel;" .. meta:get_string("channelto") .."]"
			was.user[name]=pos
			minetest.after(0.1, function(gui,name)
				return minetest.show_formspec(name, "was.channel+channelto",gui)
			end, gui,name)
		else
			was.send(pos,meta:get_string("channelto"),name,meta:get_string("channel"))
		end
	end,
	on_punch = function(pos, node, player, pointed_thing)
		local meta = minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		was.send(pos,meta:get_string("channelto"),name,meta:get_string("channel"))
	end,
	on_waswire=function(pos,channel,from_channel,msg)
		local meta=minetest.get_meta(pos)
		local user=meta:get_string("owner")
		if channel==meta:get_string("channel") and (was.is_string(msg) or was.is_number(msg)) then
			meta:set_string("infotext",msg)
		end
	end,
})

minetest.register_node("was:router", {
	description = "Router",
	tiles = {"was_wire.png"},
	drawtype="nodebox",
	paramtype = "light",
	paramtype2="facedir",
	node_box = {
		--type = "fixed",
		type = "connected",
		connect_back={-0.05,-0.5,0, 0.05,-0.45,0.5},
		connect_front={-0.05,-0.5,-0.5, 0.05,-0.45,0},
		connect_left={-0.5,-0.5,-0.05, 0.05,-0.45,0.05},
		connect_right={0,-0.5,-0.05, 0.5,-0.45,0.05},
		connect_top = {-0.05, -0.5, -0.05, 0.05, 0.5, 0.05},
		fixed = {
			{-0.37, -0.5, -0.25, 0.37, -0.37, 0.25},
			{-0.37, -0.37, 0.18, -0.31, -0.125, 0.25},
			{0.31, -0.5, 0.18, 0.37, -0.12, 0.25}
		}
	},
	connects_to={"group:was_wire","group:was_unit"},
	groups = {oddly_breakable_by_hand = 3,was_unit=1},
	on_waswire=function(pos,channel,from_channel,msg)
		for _,p in pairs(minetest.find_nodes_in_area(vector.add(pos,10),vector.subtract(pos,10),"group:was_unit")) do
			if was.get_node(p)~="was:router" then
				was.send(p,channel,msg,from_channel)
			end
		end
	end,
	on_timer = function (pos, elapsed)
		minetest.swap_node(pos,{name="was:wire",param2=135})
	end,
})

minetest.register_node("was:sender", {
	description = "Wireless sender",
	tiles = {{name="was_wire.png"}},
	drop="was:sender",
	drawtype="nodebox",
	paramtype = "light",
	palette="was_palette.png",
	paramtype2="colorwallmounted",
	node_box = {
		type = "connected",
		connect_back={-0.05,-0.5,0, 0.05,-0.45,0.5},
		connect_front={-0.05,-0.5,-0.5, 0.05,-0.45,0},
		connect_left={-0.5,-0.5,-0.05, 0.05,-0.45,0.05},
		connect_right={0,-0.5,-0.05, 0.5,-0.45,0.05},
		connect_top = {-0.05, -0.5, -0.05, 0.05, 0.5, 0.05},
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, -0.3, 0.25},
		}
	},
	connects_to={"group:was_wire","group:was_unit"},
	groups = {oddly_breakable_by_hand = 3,was_wire=1},
	on_waswire=function(pos,channel,from_channel,msg)
		for _,p in pairs(minetest.find_nodes_in_area(vector.add(pos,10),vector.subtract(pos,10),"was:receiver")) do
			was.send(p,channel,msg,from_channel)
			minetest.swap_node(p,{name="was:receiver",param2=3})
			minetest.get_node_timer(p):start(0.1)
		end
	end,
	on_timer = function (pos, elapsed)
		minetest.swap_node(pos,{name="was:sender",param2=135})
	end,
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="was:sender",param2=135})
	end,
})

minetest.register_node("was:receiver", {
	description = "Wireless receiver",
	tiles = {{name="was_wire.png"}},
	drawtype="nodebox",
	drop="was:receiver",
	paramtype = "light",
	palette="was_palette.png",
	paramtype2="colorwallmounted",
	node_box = {
		type = "connected",
		connect_back={-0.05,-0.5,0, 0.05,-0.45,0.5},
		connect_front={-0.05,-0.5,-0.5, 0.05,-0.45,0},
		connect_left={-0.5,-0.5,-0.05, 0.05,-0.45,0.05},
		connect_right={0,-0.5,-0.05, 0.5,-0.45,0.05},
		connect_top = {-0.05, -0.5, -0.05, 0.05, 0.5, 0.05},
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, -0.3, 0.25},
			{-0.02, -0.3, -0.02, 0.02, -0.1, 0.02},
		}
	},
	connects_to={"group:was_wire","group:was_unit"},
	groups = {oddly_breakable_by_hand = 3,was_wire=1},
	on_timer = function (pos, elapsed)
		minetest.swap_node(pos,{name="was:receiver",param2=135})
	end,
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="was:sender",param2=135})
	end,
})
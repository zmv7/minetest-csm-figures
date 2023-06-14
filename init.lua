local s = core.get_mod_storage()

local poses = {}
local cwp

function hs(center,radius,dome)
	if not (center and radius) then return end
	local minp = vector.subtract(center, vector.new(radius, radius, radius))
	local maxp = vector.add(center, vector.new(radius, radius, radius))
	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				local pos = vector.new(x, y, z)
				local distance = vector.distance(center, pos)
				local node = s:get("nodecheck") == "true" and core.get_node_or_nil(pos)
				if distance >= radius - 1 and distance <= radius and (not node or node.name == "air") then
					if not dome or pos.y >= center.y then
						table.insert(poses,pos)
					end
				end
			end
		end
	end
end

core.register_globalstep(function(dtime)
	if #poses > 0 then
		local ppos = core.localplayer:get_pos()
		for _,pos in ipairs(poses) do
			local distance = vector.distance(ppos, pos)
			if distance <= (s:get_int("draw_distance") or 15) then
				local node = s:get("nodecheck") == "true" and core.get_node_or_nil(pos)
				if not node or node.name == "air" then
					core.add_particle({
						pos = pos,
						velocity = {x=0, y=0, z=0},
						acceleration = {x=0, y=0, z=0},
						expirationtime = dtime,
						size = 10,
						collisiondetection = false,
						collision_removal = false,
						vertical = false,
						texture = "cdb_add.png",
						glow = 14
					})
				end
			end
		end
	end
end)

core.register_chatcommand("sphere",{
  description = "Create hollow sphere of particles",
  params = "<radius>",
  func = function(param)
	poses = {}
	if cwp then
		core.localplayer:hud_remove(cwp)
		cwp = nil
	end
	local radius = tonumber(param)
	if radius then
		local here = vector.round(core.localplayer:get_pos())
		cwp = core.localplayer:hud_add({
			hud_elem_type = "waypoint",
			name = "Sphere center "..core.pos_to_string(here),
			number = 0xFF0000,
			world_pos = here
		})
		hs(here,radius)
		return true, "Sphere r="..param.." created, "..#poses.." positions allocated"
	end
	return true, "Sphere disabled"
end})
core.register_chatcommand("dome",{
  description = "Create hollow dome of particles",
  params = "<radius>",
  func = function(param)
	poses = {}
	if cwp then
		core.localplayer:hud_remove(cwp)
		cwp = nil
	end
	local radius = tonumber(param)
	if radius then
		local here = vector.round(core.localplayer:get_pos())
		cwp = core.localplayer:hud_add({
			hud_elem_type = "waypoint",
			name = "Dome center "..core.pos_to_string(here),
			number = 0xFF0000,
			world_pos = here
		})
		hs(here,radius,true)
		return true, "Dome r="..param.." created, "..#poses.." positions allocated"
	end
	return true, "Dome disabled"
end})

core.register_chatcommand("sphereconf",{
  description = "Configure sphere assistant",
  func = function(param)
	core.show_formspec("sphereconf",
		"size[3,3.2]" ..
		"label[0.7,0;SphereConfig]" ..
		"field[0.4,1.2;2.7,1;draw_distance;Draw distance;"..(s:get("draw_distance") or 15).."]" ..
		"field_close_on_enter[draw_distance;false]" ..
		"checkbox[0.1,1.5;nodecheck;Draw only on air;"..(s:get("nodecheck") or "false").."]" ..
		"button_exit[0.1,2.2;2.8,1;done;Done]"
	)
end})

core.register_on_formspec_input(function(formname,fields)
	if formname ~= "sphereconf" then return end
	if fields.nodecheck then
		s:set_string("nodecheck",fields.nodecheck)
	end
	if fields.done or fields.key_enter then
		local dd = tonumber(fields.draw_distance)
		if dd then
			s:set_int("draw_distance",dd)
		end
	end
end)

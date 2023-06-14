local pss = {}
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
				local node = core.get_node_or_nil(pos)
				if distance >= radius - 1 and distance <= radius and (not node or node.name == "air") then
					if not dome or pos.y >= center.y then
						local ps = core.add_particlespawner({
							amount = 1,
							time = 0,
							glow = 14,
							minpos = pos,
							maxpos = pos,
							minvel = {x=0, y=0, z=0},
							maxvel = {x=0, y=0, z=0},
							minacc = {x=0, y=0, z=0},
							maxacc = {x=0, y=0, z=0},
							minexptime = 1,
							maxexptime = 1,
							minsize = 10,
							maxsize = 10,
							collisiondetection = false,
							collision_removal = false,
							vertical = false,
							texture = "cdb_add.png",
						})
						table.insert(pss,ps)
					end
				end
			end
		end
	end
end

core.register_chatcommand("sphere",{
  description = "Create hollow sphere of particles",
  params = "<radius>",
  func = function(param)
	for _,ps in ipairs(pss) do
		core.delete_particlespawner(ps)
	end
	if cwp then
		core.localplayer:hud_remove(cwp)
		cwp = nil
	end
	local radius = tonumber(param)
	if radius then
		local here = vector.round(core.localplayer:get_pos())
		cwp = core.localplayer:hud_add({
			hud_elem_type = "waypoint",
			name = "Sphere center",
			number = 0xFF0000,
			world_pos = here
		})
		hs(here,radius)
		return true, "Sphere r="..param.." created"
	end
	return true, "Sphere disabled"
end})
core.register_chatcommand("dome",{
  description = "Create hollow dome of particles",
  params = "<radius>",
  func = function(param)
	for _,ps in ipairs(pss) do
		core.delete_particlespawner(ps)
	end
	if cwp then
		core.localplayer:hud_remove(cwp)
		cwp = nil
	end
	local radius = tonumber(param)
	if radius then
		local here = vector.round(core.localplayer:get_pos())
		cwp = core.localplayer:hud_add({
			hud_elem_type = "waypoint",
			name = "Dome center",
			number = 0xFF0000,
			world_pos = here
		})
		hs(here,radius,true)
		return true, "Dome r="..param.." created"
	end
	return true, "Dome disabled"
end})

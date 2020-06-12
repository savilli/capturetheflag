ctf_map = {}

function ctf_map.get_team_relative_z(player)
	local name = player:get_player_name()
	local tname = ctf.player(name).team
	return (tname == "red" and 1 or -1) * player:get_pos().z
end

-- Overridden by server mods
function ctf_map.can_cross(player)
	return false
end

-- Modify MTG's stone pickaxe to be capable of breaking cracky=1 nodes
-- Do it here, for lack of a better place
do
	local tool_caps = minetest.registered_items["default:pick_stone"].tool_capabilities
	tool_caps.groupcaps.cracky.times[1] = 12.0
	minetest.override_item("default:pick_stone", {
		tool_capabilities = tool_caps
	})
end

local modpath = minetest.get_modpath("ctf_map")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/emerge.lua")
dofile(modpath .. "/barrier.lua")
dofile(modpath .. "/base.lua")

if minetest.get_modpath("ctf") then
	dofile(modpath .. "/chest.lua")
	dofile(modpath .. "/give_initial_stuff.lua")
	dofile(modpath .. "/schem_map.lua")
	dofile(modpath .. "/maps_catalog.lua")

	ctf_match.register_on_build_time_end(ctf_map.remove_middle_barrier)
else
	dofile(modpath .. "/map_maker.lua")
end

local revscp049 = guthscp.modules.revscp049
local config049 = guthscp.configs.revscp049
scp049 = scp049 or {}

revscp049.filter = guthscp.players_filter:new("revscp049")

revscp049.filter_zombies = guthscp.players_filter:new("revscp049_zombie")

if SERVER then
    revscp049.filter:listen_disconnect()
    revscp049.filter:listen_weapon_users("scp049")

    
	revscp049.filter.event_added:add_listener( "revscp049:setup", function( ply )
		--  speeds
		ply:SetSlowWalkSpeed( config049.walk_speed )
		ply:SetWalkSpeed( config049.walk_speed )
		ply:SetRunSpeed( config049.run_speed )
	end )
    revscp049.filter.event_removed:add_listener("revscp049:reset", function( ply )
    end)

    //
    
    revscp049.filter_zombies:listen_disconnect()
    revscp049.filter_zombies:listen_weapon_users("scp_049_zombie")

    revscp049.filter_zombies.event_removed:add_listener("revscp049_zombie:died", function(ply)
        for _, v in ipairs(revscp049.filter:get_entities()) do
            v:ChatPrint("One of your zombies is dead")
        end
    end)
end

function revscp049.get_scps_049()
    return revscp049.filter:get_entities()
end

function revscp049.is_scp_049(ply)
    if CLIENT and ply == nil then
        ply = LocalPlayer()
    end
    return revscp049.filter:is_in(ply)
end

function revscp049.is_scp_049_zombie(ply)
    if CLIENT and ply == nil then
        ply = LocalPlayer()
    end
    return revscp049.filter_zombies:is_in(ply)
end

function revscp049.GetZombieTypes049()
    revscp049.ZombieTypes = {
        [1] = {
            name = config049.scout_name,
            model = config049.scout_model,
            health = config049.scout_health,
            speed = config049.scout_speed,
        },
        [2] = {
            name = config049.jugg_name,
            model = config049.jugg_model,
            health = config049.jugg_health,
            speed = config049.jugg_speed,
        },
        [3] = {
            name = config049.normal_name,
            model = config049.normal_model,
            health = config049.normal_health,
            speed = config049.normal_speed,
        },
    }

    return revscp049.ZombieTypes
end

local revscp049 = guthscp.modules.revscp049

revscp049.filter = guthscp.players_filter:new("revscp049")

revscp049.filter_zombies = guthscp.players_filter:new("revscp049_zombie")

if SERVER then
    revscp049.filter:listen_disconnect()
    revscp049.filter:listen_weapon_users("scp049")

    revscp049.filter.event_removed:add_listener("revscp049:reset", function(ply)
        revscp049.stop_scp_049_sounds(ply)
    end)
    
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

hook.Add("SetupMove", "revscp049:no_move", function(ply, mv, cmd)
    if not revscp049.is_scp_049(ply) then return end
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return end

    if guthscp.configs.revscp049.disable_jump then
        mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
    end
end)

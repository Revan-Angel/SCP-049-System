local revscp049 = guthscp.modules.revscp049
local config = guthscp.configs.revscp049

-- Hook pour gérer les dégâts des SCP-049
hook.Add("PlayerShouldTakeDamage", "revscp049:no_damage", function(ply)
    if guthscp.configs.revscp049.immortal and revscp049.is_scp_049(ply) then
        return false
    end
end)
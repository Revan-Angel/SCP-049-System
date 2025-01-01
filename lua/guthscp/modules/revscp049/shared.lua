local revscp049 = guthscp.modules.revscp049

surface.CreateFont('scp-sweps1', {
    font = 'Arial',  -- Change 'Arial' if needed
    size = ScrW() * 0.014,  -- Taille de la police en fonction de la largeur de l'écran
    weight = 500,  -- Poids de la police (500 est standard, peut être ajusté)
    antialias = true,  -- Activer l'anti-aliasing pour un rendu plus lisse
    shadow = false,  -- Pas d'ombre
    outline = false,  -- Pas de contour
})

revscp049.filter = guthscp.players_filter:new("revscp049")

revscp049.filter_zombies = guthscp.players_filter:new("revscp049_zombie")

if SERVER then
    revscp049.filter:listen_disconnect()
    revscp049.filter:listen_weapon_users("revscp049")

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

local function ButtonClick(a)
    net.Start('revscp049-change-zombie')
        net.WriteInt(a, 7)
    net.SendToServer()
    SCPZombieMenu:Close()
end

local ModelCol = {}
function ZombieMenu()
    for k, v in ipairs(revscp049.ZombieTypes) do
        ModelCol[k] = Color(68, 68, 68, 255)
    end
    local CloseButtonColor = Color(53, 53, 53, 255)

    SCPZombieMenu = vgui.Create('DFrame')
    local w, h = ScrW() / 2.25, ScrH() / 2.25
    SCPZombieMenu:SetSize(w, h)
    SCPZombieMenu:Center()
    SCPZombieMenu:SetTitle('')
    SCPZombieMenu:MakePopup()
    SCPZombieMenu:SetDraggable(false)
    SCPZombieMenu:ShowCloseButton(false)
    local buttonW = w / 3.5
    local modelSize = 2.5
    local modelW = ScrW() / 16 * modelSize
    local modelH = ScrH() / 9 * modelSize

    SCPZombieMenu.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(80, 80, 80, 255))

        for k, v in ipairs(revscp049.ZombieTypes) do
            local a = (k - 1) / (#revscp049.ZombieTypes - 1)
            local b = w / 5

            if not ModelCol[k] then ModelCol[k] = Color(68, 68, 68, 255) end
            draw.RoundedBox(5, b + ((w - b * 2) * a) - buttonW / 2, h / 1.925 - modelH * 1.2 / 2, buttonW, modelH * 1.1, ModelCol[k])
        end
    end

    SCPZombieMenu.Think = function()
        timer.Simple(0.001, function()
            if input.WasKeyPressed(KEY_R) then
                SCPZombieMenu:Close()
            end
        end)
    end

    SCPZombieMenu.OnRemove = function()
        openMenu = false
    end

    local CloseButton = vgui.Create('DButton', SCPZombieMenu)
    CloseButton:SetSize(w, h / 11.3)
    CloseButton:SetPos(0, 0)
    CloseButton:SetText('')
    CloseButton.Paint = function(_, w, h)
        local text = revscp049.lang[5] or "Close"
        draw.RoundedBox(5, 0, 0, w, h, CloseButtonColor)
        draw.SimpleText(text, 'scp-sweps1', w / 2, h / 2, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    CloseButton.DoClick = function()
        SCPZombieMenu:Close()
    end
    CloseButton.OnCursorEntered = function()
        CloseButtonColor = Color(65, 65, 65, 255)
    end
    CloseButton.OnCursorExited = function()
        CloseButtonColor = Color(60, 60, 60, 255)
    end

    for k, v in ipairs(revscp049.ZombieTypes) do
        local ZombieButton = vgui.Create('DButton', SCPZombieMenu)
        ZombieButton:SetSize(buttonW + 1, h / 13)
        local a = (k - 1) / (#revscp049.ZombieTypes - 1)
        local b = w / 5
        ZombieButton:SetPos(b + ((w - b * 2) * a) - buttonW / 2, h - h / 7.1)
        ZombieButton:SetText('')
        ZombieButton.Paint = function(_, w, h)
            if not ModelCol[k] then ModelCol[k] = Color(68, 68, 68, 255) end
            draw.RoundedBox(5, 0, 0, w, h, ModelCol[k])
            draw.SimpleText("Zombie " .. k, 'scp-sweps1', w / 2, h / 2, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        ZombieButton.DoClick = function()
            ButtonClick(k)
        end
        ZombieButton.OnCursorEntered = function()
            ModelCol[k] = Color(90, 90, 90, 255)
        end
        ZombieButton.OnCursorExited = function()
            ModelCol[k] = Color(68, 68, 68, 255)
        end

        local ZombieModel = vgui.Create('DModelPanel', SCPZombieMenu)
        ZombieModel:SetSize(modelW, modelH)
        ZombieModel:SetPos(b + ((w - b * 2) * a) - modelW / 2, h / 2.1 - modelH / 2)
        ZombieModel:SetModel(v.model)
        ZombieModel.DoClick = function()
            ButtonClick(k)
        end
        ZombieModel.OnCursorEntered = function()
            ModelCol[k] = Color(90, 90, 90, 255)
        end
        ZombieModel.OnCursorExited = function()
            ModelCol[k] = Color(68, 68, 68, 255)
        end
    end
end
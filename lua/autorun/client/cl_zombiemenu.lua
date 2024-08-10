surface.CreateFont('scp-sweps1', {
    font = 'Arial',  -- Change 'Arial' if needed
    size = ScrW() * 0.014,  -- Taille de la police en fonction de la largeur de l'écran
    weight = 500,  -- Poids de la police (500 est standard, peut être ajusté)
    antialias = true,  -- Activer l'anti-aliasing pour un rendu plus lisse
    shadow = false,  -- Pas d'ombre
    outline = false,  -- Pas de contour
})

local function ButtonClick(a)
    net.Start('scp049-change-zombie')
        net.WriteInt(a, 7)
    net.SendToServer()
    SCPZombieMenu:Close()
end

local ModelCol = {}
function ZombieMenu()
    for k, v in ipairs(scp049.ZombieTypes) do
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

        for k, v in ipairs(scp049.ZombieTypes) do
            local a = (k - 1) / (#scp049.ZombieTypes - 1)
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
        local text = scp049.lang[5]
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

    for k, v in ipairs(scp049.ZombieTypes) do
        local ZombieButton = vgui.Create('DButton', SCPZombieMenu)
        ZombieButton:SetSize(buttonW + 1, h / 13)
        local a = (k - 1) / (#scp049.ZombieTypes - 1)
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
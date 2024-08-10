AddCSLuaFile()

if not guthscp then
	error("revanscp049 - fatal error! https://github.com/Guthen/guthscpbase must be installed on the server!")
	return
end

if not scp049 then scp049 = {} end

include('config.lua')

if CLIENT then
    surface.CreateFont('scp-sweps1', {
        font = 'Arial',
        size = ScrW() * 0.014,
        weight = 500,
        antialias = true,
        shadow = false,
        outline = false,
    })
end

-- Initialisation de la table de langue pour éviter les erreurs
scp049.lang = scp049.lang or {}

-- Définition des langues
if scp049.Language == "EN" then 
    scp049.lang = {
        'LMB - Cure the pestilence; RMB - Restore health to the cured player;  R  - Choose a treatment method',
        'DarkRP game mode required',
        'This player doesn\'t have a pestilence!',
        'You have exceeded the limit of treatment for pestilence.',
        'Close',
        'Zombie'
    } 
end

if scp049.Language == "RU" then 
    scp049.lang = {
        'ЛКМ - Излечить от поветрия; ПКМ - Восстановить здоровье излеченному игроку;  R  - Выбрать способ лечения',
        'Необходим игровой режим DarkRP',
        'У этого игрока нет поветрия!',
        'Вы превысили лимит лечения от поветрия.',
        'Закрыть',
        'Зомби'
    }
end

if scp049.Language == "FR" then 
    scp049.lang = {
        'LMB - Soigner la Pestillence; RMB - Restaurer la vie du joueur guéri;  R  - Choisir la méthode du traitement',
        'La base DarkRP est requise',
        'Ce joueur n a pas la pestillence',
        'Vous avez dépassé la limite de traitement contre la peste.',
        'Fermer',
        'Zombie'
    }
end

if scp049.Language == "GER" then 
    scp049.lang = {
        'LMB – Heile die Pest; RMB - Stellen Sie das Leben des geheilten Spielers wieder her;  R  - Wählen Sie die Behandlungsmethode',
        'DarkRP-Basis ist erforderlich',
        'Dieser Spieler hat keine Pest',
        'Sie haben die Pestbehandlungsgrenze überschritten.',
        'schließen',
        'Zombie'
    }
end

-- Si aucune langue n'est définie ou si la langue est introuvable, utilisez l'anglais par défaut
if #scp049.lang == 0 then
    scp049.lang = {
        'LMB - Cure the pestilence; RMB - Restore health to the cured player;  R  - Choose a treatment method',
        'DarkRP game mode required',
        'This player doesn\'t have a pestilence!',
        'You have exceeded the limit of treatment for pestilence.',
        'Close',
        'Zombie'
    }
end

local isDarkRP
if SERVER then
    util.AddNetworkString('scp049-change-zombie')
    isDarkRP = engine.ActiveGamemode() == 'darkrp'
    if not isDarkRP then print('SCP-049 SWEP | ' .. scp049.lang[2]) end
end

SWEP.Base = "weapon_base"

SWEP.Author = 'RevanAngel'
SWEP.PrintName = 'SCP-049'
SWEP.Instructions = scp049.lang[1]
SWEP.Category = 'SCP'

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.Weight = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModelFlip = false
SWEP.SetHoldType = 'melee'

SWEP.ViewModel = 'models/weapons/c_arms.mdl'
SWEP.WorldModel = ''

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1

SWEP.ShouldDropOnDie = false

local openMenu = false
local target
local cd = 0
local soundcd = 0
scp049.Zombies = 0
local ZombieType = scp049.DefaultZombieType

net.Receive('scp049-change-zombie', function()
    ZombieType = net.ReadInt(7)
end)

hook.Add('Think', 'scp049-zombies-table', function()
    scp049.Zombies = 0
    -- Ici, vous pouvez vérifier les joueurs qui ont été transformés en zombies, en fonction des critères que vous avez définis.
    -- Par exemple, vous pouvez marquer les joueurs comme zombies en utilisant une variable d'état ou un autre mécanisme.
end)

hook.Add('PlayerDeathThink', 'scp049-death', function(ply)
    if ply.scp049Death and ply:scp049Death() then
        return false
    end
end)

function SWEP:Think()
    if CLIENT then
        if self.Owner:KeyPressed(IN_RELOAD) then
            if not IsValid(SCPZombieMenu) then
                ZombieMenu()
            end
        end
    end

    if SERVER then
        if self.Owner:KeyDown(IN_ATTACK2) then
            local ply = self:GetOwner()
            local shootPos = ply:GetShootPos()
            local endShootPos = shootPos + ply:GetAimVector() * 150

            local tr = util.TraceHull({
                start = shootPos,
                endpos = endShootPos,
                filter = ply,
                mask = MASK_SHOT_HULL
            })

            if not IsValid(tr.Entity) then
                tr = util.TraceLine({
                    start = shootPos,
                    endpos = endShootPos,
                    filter = ply,
                    mask = MASK_SHOT_HULL
                })
            end

            target = tr.Entity

            if IsValid(target) and (target:IsPlayer() or target:IsNPC()) then
                local isZombie = target:GetNWBool("IsZombie", false)
                if isZombie then
                    if CurTime() > cd then
                        target:SetHealth(math.min(target:Health() + 1, target:GetMaxHealth()))
                        if target:Health() < target:GetMaxHealth() then
                            if soundcd <= 0 then
                                self.Owner:EmitSound('buttons/blip1.wav', 75, (20 + target:Health() / target:GetMaxHealth() * 105))
                                soundcd = 2
                            else
                                soundcd = soundcd - 1
                            end
                            cd = CurTime() + scp049.ZombieHealDelay
                        end
                    end
                end
            end
        else
            soundcd = 1
        end
    end
end

function SWEP:PrimaryAttack()
    if SERVER then
        local ply = self:GetOwner()
        local shootPos = ply:GetShootPos()
        local endShootPos = shootPos + ply:GetAimVector() * 150

        local tr = util.TraceHull({
            start = shootPos,
            endpos = endShootPos,
            filter = ply,
            mask = MASK_SHOT_HULL
        })

        if not IsValid(tr.Entity) then
            tr = util.TraceLine({
                start = shootPos,
                endpos = endShootPos,
                filter = ply,
                mask = MASK_SHOT_HULL
            })
        end

        local target = tr.Entity
        self:SetNextPrimaryFire(CurTime())

        if IsValid(target) and (target:IsPlayer() or target:IsNPC()) then
            if target:IsPlayer() and target:GetNWBool("IsZombie", false) then
                if isDarkRP then
                    DarkRP.notify(self.Owner, 1, 1, scp049.lang[3])
                end
                return
            end

            if scp049.Zombies >= scp049.ZombiesLimit and scp049.ZombiesLimit ~= 0 then
                if isDarkRP then
                    DarkRP.notify(self.Owner, 1, 1, scp049.lang[4])
                end
                return
            end

            if isDarkRP then
                -- Au lieu de tuer le joueur ou le bot, appliquez directement les modifications
                local pos = target:GetPos()

                -- Assurez-vous que ZombieType est défini correctement
                local zombieData = scp049.ZombieTypes[ZombieType]
                if not zombieData then
                    print("ZombieType is not defined correctly.")
                    return
                end

                -- Appliquer les modifications au joueur/bot
                target:SetModel(zombieData.model)
                target:SetHealth(zombieData.health)
                target:SetWalkSpeed(zombieData.speed)
                target:SetRunSpeed(zombieData.speed)
                target:SetNWBool("IsZombie", true)

                -- Assurez-vous que le bot ne meurt pas mais se transforme directement
                target:SetPos(pos) -- Assurez-vous que la position est correctement définie
            else
                print('SCP-049 SWEP | ' .. scp049.lang[2])
            end
        end
    end
end

function SWEP:SecondaryAttack()
    if SERVER then
        self:SetNextSecondaryFire(CurTime())
    end
end

function SWEP:DrawHUD()
    local dist = ScrH() / 27.5
    for k, v in ipairs(string.Explode('; ', self.Instructions)) do
        draw.SimpleText(v, 'scp-sweps1', ScrW() / 1.6, ScrH() / dist + k * 20, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end
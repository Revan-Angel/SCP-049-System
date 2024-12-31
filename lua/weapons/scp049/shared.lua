AddCSLuaFile()
if not scp049 then scp049 = {} end
local dist_sqr = 125 * 125 -- second number is the threshold distance between the player and the scp
local revscp049 = guthscp.modules.revscp049


if not guthscp then
    error("guthscp049 - fatal error! https://github.com/Guthen/guthscpbase must be installed on the server!")
    return
end

include('config.lua')

scp049.Language = guthscp.configs.language_doctor 

scp049.lang = scp049.lang or {}

if scp049.Language then
    scp049.lang = {
        guthscp.configs.translation_1,
        guthscp.configs.translation_2,
        guthscp.configs.translation_3,
        guthscp.configs.translation_4,
        guthscp.configs.translation_5,
        guthscp.configs.translation_6
    }
end


-----------------------------

local isDarkRP
if SERVER then
    util.AddNetworkString('scp049-change-zombie')
    isDarkRP = engine.ActiveGamemode() == 'darkrp'
    if not isDarkRP then print('SCP-049 SWEP | ' .. scp049.lang[2]) end
end

function ProgressBar()
    hook.Add("HUDPaint", "revscp_049_infect_progress", function()
        local ply = LocalPlayer()
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "scp049" then
            local progress = wep:GetNWFloat("Progress", 0)

            surface.SetDrawColor(50, 50, 50, 220)
            surface.DrawRect(ScrW() * 0.5 - 100, ScrH() * 0.9, 200, 20)

            surface.SetDrawColor(0, 255, 0, 220)
            surface.DrawRect(ScrW() * 0.5 - 100, ScrH() * 0.9, progress * 2, 20)
        end
    end)
end

SWEP.Base = "weapon_base"

SWEP.Author = 'RevanAngel'
SWEP.PrintName = 'SCP-049'
SWEP.Instructions = scp049.lang[1]
SWEP.Category = 'GuthSCP'

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
SWEP.SetHoldType = 'pistol'

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

hook.Add('PlayerDeathThink', 'scp049-death', function(ply)
    if ply.scp049Death and ply:scp049Death() then
        return false
    end
end)

SWEP.LastHealTime = 0

local function HealZombie(self, target)
    if not IsValid(target) or not target:IsPlayer() or not target:GetNWBool("IsZombie", false) then
        return
    end

    if not self.LastHealTime then
        self.LastHealTime = 0
    end

    local healTime = (guthscp and guthscp.configs and guthscp.configs.revscp049 and guthscp.configs.revscp049.heal_time) or 2

    if CurTime() > self.LastHealTime + healTime then
        local maxHealth = target:GetMaxHealth()
        target:SetHealth(math.min(target:Health() + 1, maxHealth))
        
        if target:Health() < maxHealth then
            if not self.soundcd then
                self.soundcd = 1
            end

            if self.soundcd <= 0 then
                self.Owner:EmitSound('buttons/blip1.wav', 75, (20 + target:Health() / maxHealth * 105))
                self.soundcd = 2
            else
                self.soundcd = self.soundcd - 1
            end
            self.LastHealTime = CurTime()
        end
    end
end

function SWEP:Think()
    if CLIENT then
        if self.Owner:KeyPressed(IN_RELOAD) then
            if not IsValid(SCPZombieMenu) then
                ZombieMenu()
            end
        end
    end

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

        if self.Owner:KeyDown(IN_ATTACK2) then
            HealZombie(self, target)
        end
    end
end

scp049.Zombies = scp049.Zombies or 0

-- Fonction pour vérifier si un joueur est déjà un zombie SCP
function revscp049.is_scp_049_zombie(ply)
    return ply:GetNWBool("IsZombie", false) -- Retourne vrai si le joueur est un zombie
end

-- Fonction pour gérer la transformation de la cible en zombie
function SWEP:CallRagdollTarget(owner, target)
    -- Vérifier si la cible est déjà un zombie
    if revscp049.is_scp_049_zombie(target) then
        if isDarkRP then
            DarkRP.notify(owner, 1, 1, scp049.lang[3]) -- Message: "La cible est déjà un zombie"
        end
        return
    end

    -- Rendre la cible invisible et la bloquer
    target:SetNoDraw(true)
    target:Lock()
    target:StripWeapons()
    target:SetCollisionGroup(COLLISION_GROUP_WORLD)
    
    -- Créer le ragdoll basé sur la cible
    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetModel(target:GetModel())
    ragdoll:SetPos(target:GetPos())
    ragdoll:SetAngles(target:GetAngles())
    ragdoll:Spawn()
    ragdoll:Activate()

    -- Appliquer une force pour lancer le ragdoll
    local phys = ragdoll:GetPhysicsObject()
    if IsValid(phys) then
        phys:ApplyForceCenter(owner:GetForward() * 500 * 500)
    end

    -- Définir la vue de la cible sur le ragdoll
    target:SetViewEntity(ragdoll)

    -- Timer pour restaurer la cible après 5 secondes
    timer.Simple(5, function()
        if IsValid(target) and IsValid(ragdoll) then
            -- Restaurer la position du joueur
            target:SetPos(ragdoll:GetPos())
            ragdoll:Remove() -- Supprimer le ragdoll

            -- Modifier le modèle et les caractéristiques du zombie
            local zombieData = scp049.ZombieTypes[ZombieType]
            if not zombieData then
                print("ZombieType is not defined correctly.")
                return
            end
            target:SetModel(zombieData.model)
            target:SetMaxHealth(zombieData.health)
            target:SetHealth(zombieData.health)
            target:SetWalkSpeed(zombieData.speed)
            target:SetRunSpeed(zombieData.speed)
            target:SetNWBool("IsZombie", true)

            -- Supprimer toutes les armes du joueur
            target:StripWeapons()

            -- Donner une nouvelle arme au joueur
            target:Give("revscp049_zombie")

            -- Incrémenter le nombre de zombies
            scp049.Zombies = scp049.Zombies + 1

            -- Restaurer la position de la cible
            target:SetPos(target:GetPos())

            -- Émettre un son de douleur zombie
            target:EmitSound("npc/zombie/zombie_pain5.mp3")

            -- Jouer l'animation de levée
            target:DoAnimationEvent(ACT_HL2MP_ZOMBIE_SLUMP_RISE)

            -- Restaurer les collisions du joueur
            target:SetCollisionGroup(COLLISION_GROUP_NONE)
        end
    end)

    -- Timer pour déverrouiller le joueur et restaurer sa vue après 4 secondes
    timer.Simple(4, function()
        if IsValid(target) then
            target:UnLock() -- Déverrouiller le joueur
            target:SetViewEntity(target) -- Restaurer la vue normale du joueur
        end
    end)

    -- Réinitialiser la barre de progression
    self:SetNWFloat("Progress", 0)
end

-- Fonction d'attaque primaire pour infecter la cible
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
            -- Vérifier si la cible est déjà un zombie
            if revscp049.is_scp_049_zombie(target) then
                if isDarkRP then
                    DarkRP.notify(self.Owner, 1, 1, scp049.lang[3]) -- Message: "La cible est déjà un zombie"
                end
                return
            end
        
            -- Vérifier si la cible est un SCP
            local ignoreSCPs = guthscp.configs.revscp049.ignore_scps
            if ignoreSCPs and guthscp.is_scp(target) then
                if isDarkRP then
                    DarkRP.notify(self.Owner, 1, 1, "It's an SCP, You cannot.")
                end
                return
            end
        
            -- Vérifier les équipes à ignorer
            local ignoreTeams = guthscp.configs.revscp049.ignore_teams
            local targetTeam = target:Team()
            local teamKeyName = guthscp.get_team_keyname(targetTeam)
            
            if ignoreTeams[teamKeyName] then
                if isDarkRP then
                    DarkRP.notify(self.Owner, 1, 1, "This team cannot be transformed")
                end
                return
            end
        
            -- Vérifier la limite de zombies
            scp049.Zombies = scp049.Zombies or 0
            if scp049.Zombies >= guthscp.configs.revscp049.zb_limits and guthscp.configs.revscp049.zb_limits ~= 0 then
                if isDarkRP then
                    DarkRP.notify(self.Owner, 1, 1, scp049.lang[4]) -- "Vous avez dépassé la limite de traitement pour la peste."
                end
                return
            end

            -- Si toutes les conditions sont remplies, transformer la cible en zombie
            if isDarkRP then
                -- Appeler la fonction pour transformer la cible en zombie avec ragdoll
                self:CallRagdollTarget(self:GetOwner(), target)
            else
                print('SCP-049 SWEP | ' .. scp049.lang[2]) -- "La base DarkRP est requise"
            end
        end
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
    if SERVER then
        net.Start('scp049-change-zombie')
        net.Send(self.Owner)
    end
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:Holster()
    return true
end

function SWEP:Deploy()
    return true
end

if CLIENT then
    guthscp.spawnmenu.add_weapon(SWEP, "SCP-049 SWEP")
end
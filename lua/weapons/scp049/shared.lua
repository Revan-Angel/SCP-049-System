AddCSLuaFile()
if not scp049 then scp049 = {} end
local revscp049 = guthscp.modules.revscp049
local config049 = guthscp.configs.revscp049

if not guthscp then
    error("guthscp049 - fatal error! https://github.com/Guthen/guthscpbase must be installed on the server!")
    return
end

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

if SERVER then
    util.AddNetworkString('scp049-change-zombie')
    print('SCP-049 SWEP | ' .. (scp049.lang and scp049.lang[2] or "Langue non définie"))
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

hook.Add('PlayerDeath', 'scp049-zombie-death', function(victim, inflictor, attacker)
    if victim:GetNWBool("IsZombie", false) then
        victim:SetNWBool("IsZombie", false)

        scp049.Zombies = math.max(0, scp049.Zombies - 1)
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

function revscp049.is_scp_049_zombie(ply)
    return ply:GetNWBool("IsZombie", false)
end

function SWEP:CallRagdollTarget(owner, target)
    if revscp049.is_scp_049_zombie(target) then
        return
    end

    target:SetNoDraw(true)
    target:Lock()
    target:StripWeapons()
    target:SetCollisionGroup(COLLISION_GROUP_WORLD)
    
    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetModel(target:GetModel())
    ragdoll:SetPos(target:GetPos())
    ragdoll:SetAngles(target:GetAngles())
    ragdoll:Spawn()
    ragdoll:Activate()

    local phys = ragdoll:GetPhysicsObject()
    if IsValid(phys) then
        phys:ApplyForceCenter(owner:GetForward() * 500 * 500)
    end

    target:SetViewEntity(ragdoll)

    timer.Simple(5, function()
        if IsValid(target) and IsValid(ragdoll) then
            target:SetNoDraw(false)
            target:SetPos(ragdoll:GetPos())
            ragdoll:Remove()

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
            target:StripWeapons()
            target:Give("revscp049_zombie")

            scp049.Zombies = scp049.Zombies + 1

            target:EmitSound("npc/zombie/zombie_pain5.mp3")
            target:DoAnimationEvent(ACT_HL2MP_ZOMBIE_SLUMP_RISE)
            target:SetCollisionGroup(COLLISION_GROUP_NONE)
        end
    end)

    timer.Simple(4, function()
        if IsValid(target) then
            target:UnLock()
            target:SetViewEntity(target)
        end
    end)
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
        self:SetNextPrimaryFire(CurTime() + 3)
        
        if IsValid(target) and (target:IsPlayer() or target:IsNPC()) then
            if revscp049.is_scp_049_zombie(target) then
                return
            end
        
            local ignoreSCPs = guthscp.configs.revscp049.ignore_scps
            if ignoreSCPs and guthscp.is_scp(target) then
                return
            end
        
            local ignoreTeams = guthscp.configs.revscp049.ignore_teams
            local targetTeam = target:Team()
            local teamKeyName = guthscp.get_team_keyname(targetTeam)
            
            if ignoreTeams[teamKeyName] then
                return
            end
        
            scp049.Zombies = scp049.Zombies or 0
            if scp049.Zombies >= guthscp.configs.revscp049.zb_limits and guthscp.configs.revscp049.zb_limits ~= 0 then
                return
            end

            self:CallRagdollTarget(self:GetOwner(), target)
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
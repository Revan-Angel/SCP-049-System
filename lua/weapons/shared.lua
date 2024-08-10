if not scp049 then scp049 = {} end

include('scp049_voice_sounds.lua')

-- ("EN", "RU", "FR", "GER")
scp049.Language = "FR"

-- Délai de guérison du zombie en secondes
scp049.ZombieHealDelay = 1.0

-- Limite maximale du nombre de zombies créés par SCP-049. Mettez 0 pour désactiver la limite.
scp049.ZombiesLimit = 10

-- Délai avant qu'un zombie ne puisse réapparaître après avoir été transformé (en secondes)
scp049.ZombieSpawnDelay = 2.0

-- Liste des équipes zombie
scp049.ZombieTeams = {
    TEAM_ZOMBIE_STANDARD = 1,
    TEAM_ZOMBIE_FAST = 2,
}

scp049.ZombieTeamNames = {
    [scp049.ZombieTeams.TEAM_ZOMBIE_STANDARD] = "Zombie Standard",  -- Remplacez avec un nom descriptif
    [scp049.ZombieTeams.TEAM_ZOMBIE_FAST] = "Zombie Rapide",    -- Remplacez avec un autre nom descriptif
}

scp049.ZombieTypes = {
    [1] = {
        model = "models/player/zombie_fast.mdl",
        health = 350,
        speed = 200,
    },
    [2] = {
        model = "models/player/zombie_soldier.mdl",
        health = 1000,
        speed = 100,
    },
    [3] = {
        model = "models/player/charple.mdl",
        health = 750,
        speed = 130,
    },
}

scp049.DefaultZombieType = 1 -- Type de zombie par défaut
scp049.ZombiesLimit = 10 -- Limite de zombies
scp049.ZombieHealDelay = 5 -- Délai de guérison
AddCSLuaFile()
scp049 = scp049 or {}

surface.CreateFont('scp-sweps1', {
    font = 'Arial',
    size = ScrW() * 0.014, 
    weight = 500, 
    antialias = true, 
    shadow = false, 
    outline = false, 
})


scp049.ZombieTypes = {
    [1] = {
        model = "models/player/alski/scp049-2_scientist.mdl",
        health = 400,
        speed = 240,
    },
    [2] = {
        model = "models/player/alski/scp049-2mtf2.mdl",
        health = 1500,
        speed = 140,
    },
    [3] = {
        model = "models/player/alski/scp049-2.mdl",
        health = 800,
        speed = 180,
    },
}

scp049.DefaultZombieType = 1
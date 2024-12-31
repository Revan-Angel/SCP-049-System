if not scp049 then scp049 = {} end

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

scp049.DefaultZombieType = 1
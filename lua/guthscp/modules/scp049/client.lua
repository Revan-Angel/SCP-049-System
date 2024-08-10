local guthscp049 = guthscp.modules.guthscp049

local voice_sounds = {
    "scp049/don'tafraid.wav",
    "scp049/greetings.wav",
    "scp049/hello.wav",
    "scp049/iseeinyou.wav",
    "scp049/notadoctor.wav",
	"scp049/song049.wav"
}

local function PlayRandomVoiceSound(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local sound = voice_sounds[math.random(#voice_sounds)]
    ply:EmitSound(sound, 75, 100)
end

local function StartVoiceSoundTimer(ply)
    if timer.Exists("scp049_voice_timer_" .. ply:SteamID()) then
        timer.Remove("scp049_voice_timer_" .. ply:SteamID())
    end

    timer.Create("scp049_voice_timer_" .. ply:SteamID(), math.random(5, 10), 0, function()
        if IsValid(ply) and ply:IsPlayer() then
            PlayRandomVoiceSound(ply)
        else
            timer.Remove("scp049_voice_timer_" .. ply:SteamID())
        end
    end)
end

hook.Add("PlayerSpawn", "scp049_start_voice_timer", function(ply)
    if ply:IsPlayer() and ply:GetActiveWeapon():GetClass() == "scp049" then
        StartVoiceSoundTimer(ply)
    end
end)

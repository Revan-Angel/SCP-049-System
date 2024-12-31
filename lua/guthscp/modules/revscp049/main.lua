local MODULE = {
    name = "SCP-049",
    author = "RevanAngel",
    version = "1.0.0",
    description = "Be the doctor. Heal your patients",
    icon = "icon16/user.png",
	version_url = "https://raw.githubusercontent.com/augaton/scp-hacking-device-reloaded/main/lua/guthscp/modules/hdevicereloaded/main.lua",
    dependencies = {
		base = "2.2.0",
		guthscpkeycard = "2.1.4",
	},
    requires = {
		["server.lua"] = guthscp.REALMS.SERVER,
		["shared.lua"] = guthscp.REALMS.SHARED,
	},
}

MODULE.menu = {
	config = {
		form = {
			"General",
			{
				{
					type = "Number",
					name = "Keycard Level",
					id = "keycard_level",
					desc = [[Compatibility with keycard system. Set a keycard level to SCP-049's swep]],
					default = 5,
					min = 0,
					max = function( self, numwang )
						if self:is_disabled() then return 0 end

						return guthscp.modules.guthscpkeycard.max_keycard_level
					end,
					is_disabled = function( self, numwang )
						return guthscp.modules.guthscpkeycard == nil
					end,
				},
				{
					type = "Bool",
					name = "Disable Jump",
					id = "disable_jump",
					desc = "Should SCP-049 be able to jump?",
					default = true,
				},
				{
					type = "Bool",
					name = "Immortal",
					id = "immortal",
					desc = "If checked, SCP-049 can't take damage",
					default = true,
				},
				{
					type = "Number",
					name = "Heal Delay",
					id = "heal_time",
					desc = "Zombie healing time by SCP-049 (in seconds)",
					default = 2,
					min = 0.1,
				},
				{
					type = "Number",
					name = "Zombie Limits",
					id = "zb_limits",
					desc = "Zombie limits wich SCP-049 can transform (0 = No Limit)",
					default = 9,
					min = 0,
				},
				{
					type = "Bool",
					name = "Ignores SCPs",
					id = "ignore_scps",
					desc = "If checked, SCP-049 won't be able to transform others SCP's Teams",
					default = true,
				},
				{
					type = "Teams",
					name = "Ignore Teams",
					id = "ignore_teams",
					desc = "All teams that can't be transform by SCP-049.",
					default = {},
				},
			},
			"Sounds",
			{
				{
					type = "String[]",
					name = "Random Sounds",
					id = "random_sound",
					desc = "Random-sound played by 049",
					default = {
						"scp049/don'tafraid.wav",
						"scp049/greetings.wav",
						"scp049/hello.wav",
						"scp049/iseeinyou.wav",
                        "scp049/notadoctor.wav",
                        "scp049/song049.wav",
					},
				},
			},
			"Translations",
			{
				type = "String",
				name = "Languages",
				id = "language_doctor",
				desc = "Language uses. (EN ; FR ; RU ; GER)",
				default = "EN",
			},
		},
	},
	details = {
		{
			text = "CC-BY-SA",
			icon = "icon16/page_white_key.png",
		},
		"Wiki",
		{
			text = "Read Me",
			icon = "icon16/information.png",
			url = "https://github.com/Revan-Angel/scp049-guthen/blob/main/README.md",
		},
		"Social",
		{
			text = "Github",
			icon = "guthscp/icons/github.png",
			url = "https://github.com/Revan-Angel/scp049-guthen/tree/main",
		},
		{
			text = "Steam",
			icon = "guthscp/icons/steam.png",
			url = "https://steamcommunity.com/id/RevanAngel/"
		},
		{
			text = "Discord",
			icon = "guthscp/icons/discord.png",
			url = "https://discord.gg/Jpr7gshRXR",	
		},
	},
}

guthscp.module.hot_reload("scp049")
return MODULE
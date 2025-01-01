--[[
	Fonctionnalités:
		- Clic gauche: Transformer le joueur en zombie
		- Reload: Menu Types de Zombies
		- Animation de la main lorsque 049 est proche d'un joueur non zombie (configurable)
		- Animation lors de l'infection
		- Barre de progression pour infecter un joueur (configurable)
		- Particules lors de l'infection (configurable)
		- QTE pour éviter d'être infecté (configurable)

		- Voir les zombies à travers les murs (configurable)
		- Nombre maximal de zombies (configurable)
		- Les zombies ne peuvent pas ouvrir les portes (configurable)
		- Permettre aux zombies de parler qu'à 049 ou Alors les empêcher de parler (Configurable)
		- SCP 049 Immortel (configurable)
		- SCP 049 ne peux pas sauter (configurable)

		- Vitesse de marche pour SCP-049 & zombies (configurable)
		- SWEP Lavende pour bypass PrimaryAttack
		- SWEP Lavende permet de voir le joueur qui le possède en évidence (Configurable)
		- Système de traduction (configurable)
		- Sons aléatoire jouer par 049 (Configurable)
		- Délai de guérison des zombies par 049 (Configurable)
]]--

local MODULE = {
    name = "SCP-049",
    author = "RevanAngel",
    version = "1.0.0",
    description = "Be the doctor. Heal your patients",
    icon = "icon16/user.png",
	version_url = "https://raw.githubusercontent.com/Revan-Angel/scp049-guthen/refs/heads/main/lua/guthscp/modules/revscp049/main.lua?",
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
			"Progress Bar [TEST : Don't touch]",
			{
				{
				type = "Bool",
				name = "Progress Bar [TEST]",
				id = "progressbar",
				desc = "Should progress bar for SCP-049 be enabled?",
				default = false,
				},
				{
				type = "Number",
				name = "Progress Bar Speed [TEST]",
				id = "progressbar_speed",
				desc = "How fast should the progress bar be filled?",
				default = 0.5,
				},
			},
			"Sounds [TEST : Don't touch]",
			{
				{
					type = "String[]",
					name = "Random Sounds [TEST]",
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
			"Translations [In development..]",
			{
				type = "String",
				name = "Text display", 
				id = "translation_1", 
				desc = "Text display with the weapon", 
				default = "LMB - Cure the pestilence; RMB - Restore health to the cured player;  R  - Choose a treatment method",
			},
			{
				type = "String",
				name = "DarkRP game mode required",
				id = "translation_2", 
				desc = "Text shown to the player when the hack is complete",
				default = "DarkRP game mode required",
			},
			{
				type = "String",
				name = "This player doesn\'t have a pestilence!",
				id = "translation_3", 
				desc = "Text display when the player is a zombie", 
				default = "This player doesn\'t have a pestilence!",
			},
			{
				type = "String",
				name = "You have exceeded the limit of treatment for pestilence.",
				id = "translation_4", 
				desc = "Max zombie limit reach'", 
				default = "You have exceeded the limit of treatment for pestilence.",
			},
			{
				type = "String",
				name = "Close",
				id = "translation_5", 
				desc = "Close button", 
				default = "Close",
			},
			{
				type = "String",
				name = "Zombie",
				id = "translation_6", 
				desc = "Zombie name", 
				default = "Zombie",
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

function MODULE:init()
    MODULE:info("The 049 system has been loaded !")
end

guthscp.module.hot_reload("scp049")
return MODULE

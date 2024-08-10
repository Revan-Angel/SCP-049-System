local MODULE = {
    name = "SCP-049",
    author = "RevanAngel",
    version = "1.0.0",
    description = "Be the doctor. Heal your patients",
    icon = "icon16/user.png", -- change if you have a different icon
}

-- Add your SWEP file here
MODULE.files = {
    "scp049.lua"
}

-- Enable hot reload
guthscp.module.hot_reload("scp049")

return MODULE
local _, core = ...;
core.addonName = "GroupBuilder";
core.raidTable = {};
core.invitedTable = {};

core.eventHandlerTable = {
	["PLAYER_LOGIN"] = function(self) core.Config:OnInitialize(self) end,
    ["CHAT_MSG_WHISPER"] = function(self, ...) core.GB.HandleWhispers(self, ...) end,
    ["GROUP_ROSTER_UPDATE"] = function (self, ...) core.GB.HandleGroupRosterUpdate(self, ...) end
};

core.roles = {
    ["healer"] = {
        "resto",
        "rsham",
        "rdruid",
        "rdru",
        "disc",
        "hpal",
        "holy pal",
        "holy paladin",
        "hpal"
    },
    ["tank"] = {
        "prot pal",
        "prot",
        "protection",
        "tank",
        "frost dk",
        "blood dk",
        "frost deathknight",
        "blood deathknight",
    },
    ["melee_dps"] = {
        "rogue",
        "rog",
        "feral",
        "enh",
        "enhancement",
        "enhance",
        "fury warr",
        "dps warr",
        "warr dps",
        "fwar",
        "ret",
        "retribution",
    },
    ["ranged_dps"] = {
        "hunter",
        "hunt",
        "mage",
        "ele shaman",
        "elesham",
        "ele sham",
        "warlock",
        "lock",
        "spriest",
        "shadow"
    },
}
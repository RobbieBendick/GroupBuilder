local _, core = ...;
core.GB = {};
GB = core.GB;
core.addonName = "GroupBuilder";
core.raidTable = {};
core.invitedTable = {};


core.eventHandlerTable = {
	["PLAYER_LOGIN"] = function(self) core.Config:OnInitialize(self) end,
    ["CHAT_MSG_WHISPER"] = function(self, ...) core.GB.HandleWhispers(self, ...) end,
    ["GROUP_ROSTER_UPDATE"] = function (self, ...) core.GB.HandleGroupRosterUpdate(self, ...) end,
    ["CHAT_MSG_SYSTEM"] = function(self, ...) core.GB.HandleErrorMessages(self, ...) end
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
        "hpal",
        "h pal",
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
        "war",
        "enhancement",
        "enhance",
        "fury warr",
        "dps warr",
        "warr dps",
        "fwar",
        "ret",
        "retribution",
        "warrior",
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
        "boom",
        "moon",
        "balance",
    },
};
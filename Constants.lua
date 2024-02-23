local GroupBuilder = _G.LibStub("AceAddon-3.0"):NewAddon("GroupBuilder", "AceConsole-3.0", "AceEvent-3.0");
GroupBuilder.addonName = "GroupBuilder";
GroupBuilder.raidTable = {};
GroupBuilder.invitedTable = {};
GroupBuilder.roles = {
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
        "shadow",
        "boom",
        "moon",
        "balance",
    },
};

GroupBuilder.classes = {
    "ROGUE",
    "WARRIOR",
    "PRIEST",
    "MAGE",
    "PALADIN",
    "HUNTER",
    "DEATHKNIGHT",
    "SHAMAN",
    "WARLOCK",
    "DRUID"
};

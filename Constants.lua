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

GroupBuilder.amountOfRaidBosses = {
    ["Icecrown Citadel"] = 12,
    ["Ruby Sanctum"] = 1,
}

GroupBuilder.raidInstanceDropdownAcronyms = {
    ["ICC 25"] = "Icecrown Citadel 25",
    ["ICC 10"] = "Icecrown Citadel 10",
    ["RS 25"] = "Ruby Sanctum 25",
    ["RS 10"] = "Ruby Sanctum 10",
};

GroupBuilder.roleClasses = {
    ["healer"] = {
        "PRIEST",
        "PALADIN",
        "DRUID",
        "SHAMAN",
    },
    ["tank"] = {
        "PALADIN",
        "DEATHKNIGHT",
        "DRUID",
        "WARRIOR",
    },
    ["melee_dps"] = {
        "WARRIOR",
        "ROGUE",
        "DRUID",
        "DEATHKNIGHT",
        "PALADIN",
        "SHAMAN",
    },
    ["ranged_dps"] = {
        "HUNTER",
        "Warlock",
        "MAGE",
        "SHAMAN",
        "PRIEST",
        "DRUID",
    },
};

function GroupBuilder:Contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true;
        end
    end
    return false;
end
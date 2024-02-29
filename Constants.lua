local GroupBuilder = _G.LibStub("AceAddon-3.0"):NewAddon("GroupBuilder", "AceConsole-3.0", "AceEvent-3.0");
GroupBuilder.addonName = "GroupBuilder";
GroupBuilder.raidTable = {};
GroupBuilder.invitedTable = {};
GroupBuilder.inviteConstruction = {};
GroupBuilder.recentlyInteractedWith = {};
GroupBuilder.minDelayTime = 4;
GroupBuilder.maxDelayTime = 10;
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
        "frost d",
        "blood",
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

GroupBuilder.classAbberviations = {
    ["roeg"] = "ROGUE",
    ["rog"] = "ROGUE",

    ["warrior"] = "WARRIOR",
    ["war"] = "WARRIOR",

    ["disc"] = "PRIEST",
    ["priest"] = "PRIEST",
    ["pri"] = "PRIEST",

    ["mage"] = "MAGE",
    ["mag"] = "MAGE",

    ["hunter"] = "HUNTER",
    ["hunt"] = "HUNTER",
    
    ["death"] = "DEATHKNIGHT",
    ["deaht"] = "DEATHKNIGHT",
    ["dk"] = "DEATHKNIGHT",
    
    ["warlock"] = "WARLOCK",
    ["lock"] = "WARLOCK",

    ["shaman"] = "SHAMAN",
    ["sham"] = "SHAMAN",
    ["ele"] = "SHAMAN",
    ["enh"] = "SHAMAN",


    ["boom"] = "DRUID",
    ["balance"] = "DRUID",
    ["feral"] = "DRUID",
    ["rdruid"] = "DRUID",
    ["rdru"] = "DRUID",
    ["dru"] = "DRUID",
    ["druid"] = "DRUID",
    ["moon"] = "DRUID",

    ["hpal"] = "PALADIN",
    ["holy pa"] = "PALADIN",
    ["hpal"] = "PALADIN",
    ["h pal"] = "PALADIN",
    ["pala"] = "PALADIN",
    ["pally"] = "PALADIN",
    ["ret"] = "PALADIN",
    ["rpal"] = "PALADIN",
    ["r pal"] = "PALADIN",
}

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
        "WARLOCK",
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
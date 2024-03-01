local GroupBuilder = _G.LibStub("AceAddon-3.0"):NewAddon("GroupBuilder", "AceConsole-3.0", "AceEvent-3.0");
GroupBuilder.addonName = "GroupBuilder";
GroupBuilder.recentlyInteractedWith = {};
GroupBuilder.inviteExpirationTime = 122;
GroupBuilder.minDelayTime = 4;
GroupBuilder.maxDelayTime = 10;
GroupBuilder.roles = {
    ["healer"] = {
        "resto",
        "rsham",
        "resto sh",

        "rdrru",
        "rdruu",
        "rdruid",
        "rdru",
        "tree",

        "dics",
        "disc",
        "dpr",

        "hpal",
        "holy pa",
        "hpal",
        "h pal",
    },
    ["tank"] = {
        "prot",
        "tank",
        "blood",
    },
    ["melee_dps"] = {
        "rogue",
        "rog",

        "feral",

        "enh",
        "enhancement",
        "enhance",
    
        "ret",
        "retr",

        "warrior",
        "war",
        "fwar",
        "warr dps",
        "fury war",
        "dps war",

        "unh",
        "dk",
        "frost",
        "death",
        "deaht",
    },
    ["ranged_dps"] = {
        "hunter",
        "hunt",
        "surv",
        "marks",
        "bm",
        "beast",

        "mage",
        "mag",

        "ele shaman",
        "elesham",
        "ele sham",

        "warlock",
        "lock",

        "spr",
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
    ["dics"] = "PRIEST",
    ["priest"] = "PRIEST",
    ["pri"] = "PRIEST",
    ["dpr"] = "PRIEST",

    ["mage"] = "MAGE",
    ["mag"] = "MAGE",

    ["hunter"] = "HUNTER",
    ["hunt"] = "HUNTER",
    ["surv"] = "HUNTER",
    
    ["death"] = "DEATHKNIGHT",
    ["deaht"] = "DEATHKNIGHT",
    ["dk"] = "DEATHKNIGHT",
    ["unh"] = "DEATHKNIGHT",
    ["frost"] = "DEATHKNIGHT",
    ["frots"] = "DEATHKNIGHT",

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
    ["tree"] = "DRUID",

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


function GroupBuilder:Contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true;
        end
    end
    return false;
end
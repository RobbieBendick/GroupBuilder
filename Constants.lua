local GroupBuilder = _G.LibStub("AceAddon-3.0"):NewAddon("GroupBuilder", "AceConsole-3.0", "AceEvent-3.0");
GroupBuilder.addonName = "GroupBuilder";
GroupBuilder.recentlyInteractedWith = {};
GroupBuilder.inviteExpirationTime = 122;
GroupBuilder.minDelayTime = 4;
GroupBuilder.maxDelayTime = 10;
GroupBuilder.maxGearscoreNumber = 10000;
GroupBuilder.amountOfInteractionsBeforeStoppingWhispers = 1;
GroupBuilder.roles = {
    ["healer"] = {
        "resto",
        "rseto",
        "retso",

        "rsham",
        "healer sha",
        "healer sah",
        "heal sham",
        "hael sham",
        "hael shma",
        "sham heal",
        "shma heal",
        "shaman heal",
        "shamna heal",

        "rdrru",
        "rdruid",
        "rdru",
        "rddru",
        "tree",
        "haeler dru",
        "hael dru",
        "heal dru",
        "healre dru",
        "hael dru",
        "dru heal",
        "dru hae",
        "druid heal",
        "druid hae",
        "dru hae",
        "dru heal",
        "drood hea",
        "droo hea",

        "dics",
        "disc",
        "dsi",
        "dpr",
        "heal pri",
        "haeler pri",
        "healre pri",
        "priest hea",
        "pri hea",
        "preist hea",
        "prist hea",
        "perist hea",

        "holy pa",
        "hpal",
        "h pal",
        "h apl",
        "heal pal",
        "haeler pal",
        "healre pal",
        "pal heal",
        "pall heal",
        "pali heal",
        "palli heal",
        "pala heal",
        "pally heal",
    },
    ["tank"] = {
        "prot",
        "prt",
        "port",
        "tank",
        "tnak",
        "blood",
        "blod",
    },
    ["melee_dps"] = {
        "rogue",
        "rog",

        "feral",
        "freal",

        "enh",
        "enhance",
        "ehnanc",
    
        "ret",
        "rte",

        "warrior",
        "war",
        "fwar",
        "war dps",
        "warr dps",
        "fuyr",
        "fruy",
        "fury",
        "dps war",

        "unh",
        "dk",
        "frost",
        "frsot",
        "death",
        "deaht",
    },
    ["ranged_dps"] = {
        "hunt",
        "htun",
        "hnut",
        "surv",
        "marks",
        "bm",
        "beast",
        "baest",

        "mage",
        "mag",
        "maeg",

        "ele shaman",
        "elesham",
        "ele sham",
        "eel sham",

        "warlock",
        "lock",

        "spr",
        "shad",
        "shda",

        "boom",
        "booy",
        "moon",
        "mono",
        "balacn",
        "balance",
        "blanc",
        "baalnce",

    },
};

GroupBuilder.classAbberviations = {
    ["roeg"] = "ROGUE",
    ["rog"] = "ROGUE",
    ["riog"] = "ROGUE",

    ["warrior"] = "WARRIOR",
    ["war"] = "WARRIOR",

    ["disc"] = "PRIEST",
    ["dsi"] = "PRIEST",
    ["dics"] = "PRIEST",
    ["priest"] = "PRIEST",
    ["preis"] = "PRIEST",
    ["pri"] = "PRIEST",
    ["dpr"] = "PRIEST",

    ["mage"] = "MAGE",
    ["mag"] = "MAGE",
    ["maeg"] = "MAGE",

    ["hunter"] = "HUNTER",
    ["hunt"] = "HUNTER",
    ["hnt"] = "HUNTER",
    ["hutn"] = "HUNTER",
    ["surv"] = "HUNTER",
    ["sruv"] = "HUNTER",
    ["mark"] = "HUNTER",
    ["bm"] = "HUNTER",
    ["beast"] = "HUNTER",
    
    ["death"] = "DEATHKNIGHT",
    ["daet"] = "DEATHKNIGHT",
    ["deaht"] = "DEATHKNIGHT",
    ["dk"] = "DEATHKNIGHT",
    ["unh"] = "DEATHKNIGHT",
    ["frost"] = "DEATHKNIGHT",
    ["frots"] = "DEATHKNIGHT",

    ["warlock"] = "WARLOCK",
    ["lock"] = "WARLOCK",

    ["shaman"] = "SHAMAN",
    ["sham"] = "SHAMAN",
    ["shma"] = "SHAMAN",
    ["ele"] = "SHAMAN",
    ["enh"] = "SHAMAN",

    ["boom"] = "DRUID",
    ["booy"] = "DRUID",
    ["balance"] = "DRUID",
    ["balac"] = "DRUID",
    ["blanc"] = "DRUID",
    ["baalnce"] = "DRUID",
    ["moon"] = "DRUID",
    ["mono"] = "DRUID",
    ["feral"] = "DRUID",
    ["freal"] = "DRUID",
    ["rdriu"] = "DRUID",
    ["rdruid"] = "DRUID",
    ["rddru"] = "DRUID",
    ["dru"] = "DRUID",
    ["druid"] = "DRUID",
    ["tree"] = "DRUID",
    ["tere"] = "DRUID",

    ["pal"] = "PALADIN",
    ["holy pa"] = "PALADIN",
    ["hloy pa"] = "PALADIN",
    ["rte pa"] = "PALADIN",
    ["ret"] = "PALADIN",
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


function GroupBuilder:Contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true;
        end
    end
    return false;
end
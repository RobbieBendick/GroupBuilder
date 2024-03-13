local GroupBuilder = _G.LibStub("AceAddon-3.0"):NewAddon("GroupBuilder", "AceConsole-3.0", "AceEvent-3.0");
GroupBuilder.addonName = "GroupBuilder";
GroupBuilder.recentlyInteractedWith = {};
GroupBuilder.inviteExpirationTime = 122;
GroupBuilder.minDelayTime = 4;
GroupBuilder.maxDelayTime = 10;
GroupBuilder.maxGearscoreNumber = 10000;
GroupBuilder.amountOfInteractionsBeforeStoppingWhispers = 1;
GroupBuilder.selectedKickPlayer = "";
GroupBuilder.roles = {
    ["healer"] = {
        "resto",
        "rsham",

        "rdruid",
        "rdru",
        "tree",
        "healer",
        "heal",

        "disc",
        "dpr",
    },
    ["tank"] = {
        "prot",
        "tank",
        "blood",
    },
    ["melee_dps"] = {
        "rogue",

        "feral",

        "enh",
        "enhance",
    
        "ret",

        "warrior",
        "war",
        "fwar",
        "fury",

        "unh",
        "unholy",
        "dk",
        "frost",
        "death",
    },
    ["ranged_dps"] = {
        "hunter",
        "hunt",
        "surv",
        "survival",

        "marks",
        "bm",
        "beast",

        "mage",
        "mag",
        "fire",
        
        "ele",
        "elesham",

        "warlock",
        "lock",

        "spr",
        "shadow",
        "dps priest",
        "dsp priest",
        "pds priest",
        "priest dps",
        "priest pds",
        "preist pds",
        "priest dsp",



        "boom",
        "boomkin",
        "moon",
        "balance",
    },
};

GroupBuilder.classAbberviations = {
    ["rog"] = "ROGUE",
    ["rogue"] = "ROGUE",

    ["warrior"] = "WARRIOR",
    ["war"] = "WARRIOR",

    ["disc"] = "PRIEST",
    ["priest"] = "PRIEST",
    ["pri"] = "PRIEST",
    ["dpr"] = "PRIEST",

    ["mage"] = "MAGE",
    ["fire"] = "MAGE",

    ["hunter"] = "HUNTER",
    ["hunt"] = "HUNTER",
    ["surv"] = "HUNTER",
    ["mark"] = "HUNTER",
    ["bm"] = "HUNTER",
    ["beast"] = "HUNTER",
    
    ["death"] = "DEATHKNIGHT",
    ["dk"] = "DEATHKNIGHT",
    ["unh"] = "DEATHKNIGHT",
    ["frost"] = "DEATHKNIGHT",

    ["warlock"] = "WARLOCK",
    ["lock"] = "WARLOCK",

    ["shaman"] = "SHAMAN",
    ["sham"] = "SHAMAN",
    ["ele"] = "SHAMAN",
    ["enh"] = "SHAMAN",

    ["boomy"] = "DRUID",
    ["boomkin"] = "DRUID",
    ["balance"] = "DRUID",
    ["moon"] = "DRUID",
    ["feral"] = "DRUID",
    ["rdruid"] = "DRUID",
    ["dru"] = "DRUID",
    ["druid"] = "DRUID",
    ["tree"] = "DRUID",

    ["pal"] = "PALADIN",
    ["pally"] = "PALADIN",
    ["paladin"] = "PALADIN",
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

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
        "ehnanc",
    
        "ret",

        "warrior",
        "war",
        "fwar",
        "war dps",
        "warr dps",
        "fury",
        "dps war",

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
        "baest",

        "mage",
        "mag",
        "fire",
        
        "ele shaman",
        "elesham",
        "ele sham",

        "warlock",
        "lock",

        "spr",
        "shadow",
        "dps priest",
        "priest dps",


        "boom",
        "moon",
        "balance",
    },
};

GroupBuilder.classAbberviations = {
    ["rog"] = "ROGUE",

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
    ["balance"] = "DRUID",
    ["moon"] = "DRUID",
    ["feral"] = "DRUID",
    ["rdruid"] = "DRUID",
    ["dru"] = "DRUID",
    ["druid"] = "DRUID",
    ["tree"] = "DRUID",

    ["pal"] = "PALADIN",
    ["holy pa"] = "PALADIN",
    ["hloy pa"] = "PALADIN",
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

function GroupBuilder:Levenshtein(str1, str2)
    local len1 = #str1;
    local len2 = #str2;
    local matrix = {};
    
    for i = 0, len1 do
        matrix[i] = {};
        for j = 0, len2 do
            if i == 0 then
                matrix[i][j] = j;
            elseif j == 0 then
                matrix[i][j] = i;
            else
                matrix[i][j] = 0;
            end
        end
    end
    
    -- compute the Levenshtein distance
    for i = 1, len1 do
        for j = 1, len2 do
            local cost = (str1:sub(i, i) ~= str2:sub(j, j)) and 1 or 0;
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,
                matrix[i][j-1] + 1,
                matrix[i-1][j-1] + cost
            );
        end
    end
    
    return matrix[len1][len2];
end

function GroupBuilder:FuzzyFind(message, keyWords, threshold)
    local results = {};
    for _, keyWord in ipairs(keyWords) do
        local distance = GroupBuilder:Levenshtein(message, keyWord);
        if distance <= threshold then
            table.insert(results, keyWord);
        end
    end
    return results;
end


function GroupBuilder:Contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true;
        end
    end
    return false;
end

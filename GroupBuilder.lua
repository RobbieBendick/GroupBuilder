local _, core = ...;
local GroupBuilder = _G.LibStub("AceAddon-3.0"):NewAddon(core.addonName, "AceConsole-3.0", "AceEvent-3.0");

local Config = core.Config;
core.GB = {};
GB = core.GB;

local addonLoadedFrame = CreateFrame("Frame");
addonLoadedFrame:RegisterEvent("ADDON_LOADED");
local eventFrame = CreateFrame("Frame");

function GB:AddonLoaded(self, addonName)
    -- register all relevant events
    if addonName == core.addonName then
        for event, func in pairs(core.eventHandlerTable) do
            eventFrame:RegisterEvent(event);
        end
    end
end

function GB:CountPlayersByRole(table, role)
    local count = 0;
    if role == "dps" then
        for _, playerRole in pairs(core.raidTable) do
            if playerRole == "melee_dps" or playerRole == "ranged_dps" then
                count = count + 1;
            end
        end
    else
        for _, playerRole in pairs(core.raidTable) do
            if playerRole == role then
                count = count + 1;
            end
        end
    end
    return count;
end

function GB:FindRole(message)
    local foundRole;
    for role, values in pairs(core.roles) do
        for _, value in ipairs(values) do
            if message:lower():find(value) then
                foundRole = role;
                break;
            end
        end
        if foundRole then
            break;
        end
    end
    return foundRole;
end

function GB:FindGearscore(message)
    local keywordPatternWithGS = "(%d+%.?%d*)([kK]?)%s*gs%s*";
    local keywordPatternWithGearscore = "(%d+%.?%d*)([kK]?)%s*gearscore%s*";
    local keywordPatternWithGearscoreSpace = "(%d+%.?%d*)([kK]?)%s*gear%s*score%s*";
    local gearscoreNumber;

    function checkMessageForPattern(pattern)
        if not gearscoreNumber then
            for number, k in message:lower():gmatch(pattern) do
                gearscoreNumber = tonumber(number)
    
                if k:lower() == "k" then
                    gearscoreNumber = gearscoreNumber * 1000;
                    print('gearScoreNumber:', gearscoreNumber);
                    break;
                end
            end
        end
    end

    checkMessageForPattern(keywordPatternWithGS);
    checkMessageForPattern(keywordPatternWithGearscore);
    checkMessageForPattern(keywordPatternWithGearscoreSpace);

    return gearscoreNumber;
end


function GB:HandleWhispers(message, sender, ...)
    if core.db.profile.isPaused then return end
    local gearscoreNumber = GB:FindGearscore(message);
    if not gearscoreNumber then return end

    local role = GB:FindRole(message);
    if not role then return end

    if gearscoreNumber < tonumber(core.db.profile.gearscore) then return end
    if role == "ranged_dps" then        
        if GB:CountPlayersByRole("dps") >= core.db.profile.maxDPS or GB:CountPlayersByRole(role) >= core.db.profile.maxRangedDPS then return end
    end

    if role == "melee_dps" then
        if GB:CountPlayersByRole("dps") >= core.db.profile.maxDPS or GB:CountPlayersByRole(role) >= core.db.profile.maxMeleeDPS then return end
    end

    if role == "tank" then
        if GB:CountPlayersByRole(role) >= core.db.profile.maxTanks then return end
    end

    if role == "healer" then
        if GB:CountPlayersByRole(role) >= core.db.profile.maxHealers then return end
    end
    
    local senderCharacterName = sender:match("([^%-]+)");

    -- invite them
    C_Timer.After(math.random(4, 10), function ()
        print('inviting ', senderCharacterName);
        InviteUnit(senderCharacterName);
        core.invitedTable[senderCharacterName] = role;
    end)

    -- remove them from invited table if invite expires
    C_Timer.After(122 + 10, function ()
        if not core.raidTable[senderCharacterName] then
            core.invitedTable[senderCharacterName] = nil;
        end
    end);
end


-- event handler
function GB:EventHandler(event, ...)
    return core.eventHandlerTable[event](self, ...);
end

addonLoadedFrame:SetScript("OnEvent", GB.AddonLoaded);
eventFrame:SetScript("OnEvent", GB.EventHandler);
local _, core = ...;
local ArenaMarker = _G.LibStub("AceAddon-3.0"):NewAddon(core.addonName, "AceConsole-3.0", "AceEvent-3.0");

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

function GB:FindGearscore(message)
    local keywordPattern = "(%d+%.?%d*)%s*[kK]?%s*gs%s*";
    local keywordPatternWithGearscore = "(%d+%.?%d*)%s*[kK]?%s*gearscore%s*";
    local keywordPatternWithGearScore = "(%d+%.?%d*)%s*[kK]?%s*gear%s*score%s*";
    local gearscoreNumber;

    for number in message:gmatch(keywordPattern) do
        -- extract only the numeric value from the matched string
        gearscoreNumber = tonumber(number);
    end
    if not gearscoreNumber then
        for number in message:gmatch(keywordPatternWithGearscore) do
            -- extract only the numeric value from the matched string
            gearscoreNumber = tonumber(number);
        end
    end
    if not gearscoreNumber then
        for number in message:gmatch(keywordPatternWithGearScore) do
            -- extract only the numeric value from the matched string
            gearscoreNumber = tonumber(number);
        end
    end

    return gearscoreNumber;
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
                break;  -- no need to continue checking other values once one is found
            end
        end
        if foundRole then
            break;  -- no need to continue checking other roles once one is found
        end
    end
    return foundRole;
end

function GB:FindGearscore(message)
    local keywordPattern = "(%d+%.?%d*)%s*[kK]?%s*gs%s*";
    local keywordPatternWithGearscore = "(%d+%.?%d*)%s*[kK]?%s*gearscore%s*";
    local keywordPatternWithGearScore = "(%d+%.?%d*)%s*[kK]?%s*gear%s*score%s*";
    local gearscoreNumber;

    for number in message:gmatch(keywordPattern) do
        -- extract only the numeric value from the matched string
        gearscoreNumber = tonumber(number);
        -- check if "k" or "K" is present and multiply by 1000 if so
        if message:lower():find("k", 1, true) then
            gearscoreNumber = gearscoreNumber * 1000;
        end
    end
    if not gearscoreNumber then
        for number in message:gmatch(keywordPatternWithGearscore) do
            -- extract only the numeric value from the matched string
            gearscoreNumber = tonumber(number);
            -- check if "k" or "K" is present and multiply by 1000 if so
            if message:lower():find("k", 1, true) then
                gearscoreNumber = gearscoreNumber * 1000;
            end
        end
    end
    if not gearscoreNumber then
        for number in message:gmatch(keywordPatternWithGearScore) do
            -- extract only the numeric value from the matched string
            gearscoreNumber = tonumber(number);
            -- check if "k" or "K" is present and multiply by 1000 if so
            if message:lower():find("k", 1, true) then
                gearscoreNumber = gearscoreNumber * 1000;
            end
        end
    end

    return gearscoreNumber;
end

function GB:HandleWhispers(message, sender, ...)
    if core.db.profile.isPaused then return end
    local characterName = sender:match("([^%-]+)")
    local gearscoreNumber = GB:FindGearscore(message);
    if not gearscoreNumber then return print('no gs') end

    local role = GB:FindRole(message);
    if not role then return print('no role') end
    print('gearscoreNumber: ', gearscoreNumber);
    print('minGearscore: ', core.db.profile.gearscore);

    if gearscoreNumber < tonumber(core.db.profile.gearscore) then return print('gs too low') end
    if role == "ranged_dps" then
        print(GB:CountPlayersByRole("dps"))
        
        if GB:CountPlayersByRole("dps") >= core.db.profile.dps or GB:CountPlayersByRole(role) >= core.db.profile.maxRangedDPS then return print('Too many '.. role) end
    end

    if role == "melee_dps" then
        if GB:CountPlayersByRole("dps") >= core.db.profile.dps or GB:CountPlayersByRole(role) >= core.db.profile.maxMeleeDPS then return print('Too many '.. role) end
    end

    if role == "tank" then
        if GB:CountPlayersByRole(role) >= core.db.profile.tanks then return print('Too many '.. role) end
    end

    if role == "healer" then
        if GB:CountPlayersByRole(role) >= core.db.profile.healers then return print('Too many '.. role) end
    end

    print('robdog 2')
    -- invite them
    C_Timer.After(math.random(4, 10), function ()
        print('inviting ', characterName);
        InviteUnit(characterName);
        core.invitedTable[characterName] = role;
    end)

    -- remove them from invited table if invite expires
    C_Timer.After(122 + 10, function ()
        if not core.raidTable[sender] then
            core.invitedTable[characterName] = nil;
        end
    end);
end


-- event handler
function GB:EventHandler(event, ...)
    return core.eventHandlerTable[event](self, ...);
end

addonLoadedFrame:SetScript("OnEvent", GB.AddonLoaded);
eventFrame:SetScript("OnEvent", GB.EventHandler);
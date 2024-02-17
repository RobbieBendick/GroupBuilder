local _, core = ...;
local GroupBuilder = _G.LibStub("AceAddon-3.0"):NewAddon(core.addonName, "AceConsole-3.0", "AceEvent-3.0");
local Config = core.Config;

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
    for role, keyWords in pairs(core.roles) do
        for _, keyWord in ipairs(keyWords) do
            if message:lower():find(keyWord) then
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
    local rolePattern = "(%d+%.?%d*)([kK]?)%s*(%a+)";
    local gearscoreNumber;

    function checkMessageForPattern(pattern)
        if gearscoreNumber then return gearscoreNumber end
        for number, k in message:lower():gmatch(pattern) do
            gearscoreNumber = tonumber(number)

            if k:lower() == "k" then
                gearscoreNumber = gearscoreNumber * 1000;
                break;
            end
        end
    end

    checkMessageForPattern(keywordPatternWithGS);
    checkMessageForPattern(keywordPatternWithGearscore);
    checkMessageForPattern(keywordPatternWithGearscoreSpace);

    if gearscoreNumber then return gearscoreNumber end

    -- check for pattern with number followed by a role
    for number, k, role in message:lower():gmatch(rolePattern) do
        gearscoreNumber = tonumber(number);

        if k:lower() == "k" then
            gearscoreNumber = gearscoreNumber * 1000;
        end
        break;
    end
    return gearscoreNumber;
end

function GB:IsInRaidTable(name)
    return core.raidTable[name] ~= nil;
end

function GB:IsInInvitedTable(name)
    return core.invitedTable[name] ~= nil;
end

function GB:HandleWhispers(message, sender, ...)
    if core.db.profile.isPaused then return end

    local gearscoreNumber = GB:FindGearscore(message);
    if not gearscoreNumber then return end

    local role = GB:FindRole(message);
    if not role then return end

    if gearscoreNumber < tonumber(core.db.profile.minGearscore) then return end
    
    local maxRoleValues = {
        ["ranged_dps"] = core.db.profile.maxRangedDPS,
        ["melee_dps"] = core.db.profile.maxMeleeDPS,
        ["tank"] = core.db.profile.maxTanks,
        ["healer"] = core.db.profile.maxHealers
    };

    for role, max in pairs(maxRoleValues) do
        if role == "ranged_dps" or role == "melee_dps" then
            if GB:CountPlayersByRole("dps") >= core.db.profile.maxDPS or GB:CountPlayersByRole(role) >= max then return end
        else
            if GB:CountPlayersByRole(role) >= max then return end
        end
    end

    local senderCharacterName = sender:match("([^%-]+)");

    -- invite them
    local minTimeToInvite, maxTimeToInvite = 4, 10;
    C_Timer.After(math.random(minTimeToInvite, maxTimeToInvite), function ()
        print('inviting ', senderCharacterName);
        InviteUnit(senderCharacterName);
        core.invitedTable[senderCharacterName] = role;
    end)

    -- remove them from invited table if invite expires
    local inviteExpirationTime = 122;
    C_Timer.After(inviteExpirationTime + maxTimeToInvite, function ()
        if not GB:IsInRaidTable(senderCharacterName) and GB:IsInInvitedTable(senderCharacterName) then
            core.invitedTable[senderCharacterName] = nil;
        end
    end);
end

function GB:HandleErrorMessages(msg)
    if not msg:find("is already in a group") then return end
    local playerName = msg:match("(%S+)");
    core.invitedTable[playerName] = nil;
end

function GB:HandleGroupRosterUpdate(self, ...)
    local playerName = UnitName("player");
    if core.db.profile.selectedRole and not core.raidTable[playerName] then
        core.raidTable[playerName] = core.db.profile.selectedRole;
    end

    for i = 1, GetNumGroupMembers() do
        local name = GetRaidRosterInfo(i);
        if GB:IsInInvitedTable(name) and not GB:IsInRaidTable(name) then
            -- add to raid table
            core.raidTable[name] = core.invitedTable[name];
            
            -- remove from inv table
            core.invitedTable[name] = nil; 
        elseif GB:IsInInvitedTable(name) and GB:IsInRaidTable(name) then
            -- remove them from the invited table
            core.invitedTable[name] = nil;
        end
    end
end


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

-- event handler
function GB:EventHandler(event, ...)
    return core.eventHandlerTable[event](self, ...);
end

addonLoadedFrame:SetScript("OnEvent", GB.AddonLoaded);
eventFrame:SetScript("OnEvent", GB.EventHandler);
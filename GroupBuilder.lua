local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local Config = GroupBuilder.Config;

function GroupBuilder:CountPlayersByRole(table, role)
    local count = 0;
    if role == "dps" then
        for _, playerData in pairs(GroupBuilder.raidTable) do
            if playerData.role == "melee_dps" or playerData.role == "ranged_dps" then
                count = count + 1;
            end
        end
    else
        for _, playerData in pairs(GroupBuilder.raidTable) do
            if playerData.role == role then
                count = count + 1;
            end
        end
    end
    return count;
end

function GroupBuilder:FindRole(message)
    local foundRole;
    for role, keyWords in pairs(GroupBuilder.roles) do
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

function GroupBuilder:FindGearscore(message)
    local keywordPatternWithGS = "(%d+%.?%d*)([kK]?)%s*gs%s*";
    local keywordPatternWithGearscore = "(%d+%.?%d*)([kK]?)%s*gearscore%s*";
    local keywordPatternWithGearscoreSpace = "(%d+%.?%d*)([kK]?)%s*gear%s*score%s*";
    local keywordPatternWithGearscoreRole = "(%d+%.?%d*)([kK]?)%s*(%a+)";
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
    for number, k, role in message:lower():gmatch(keywordPatternWithGearscoreRole) do
        gearscoreNumber = tonumber(number);

        if k:lower() == "k" then
            gearscoreNumber = gearscoreNumber * 1000;
        end
        break;
    end
    return gearscoreNumber;
end

function GroupBuilder:IsInRaidTable(name)
    return GroupBuilder.raidTable[name] ~= nil;
end

function GroupBuilder:IsInInvitedTable(name)
    return GroupBuilder.invitedTable[name] ~= nil;
end

function GroupBuilder:HandleWhispers(event, message, sender, ...)
    if GroupBuilder.db.profile.isPaused then return end

    local gearscoreNumber = GroupBuilder:FindGearscore(message);
    if not gearscoreNumber then return end

    local role = GroupBuilder:FindRole(message);
    if not role then return end
    if gearscoreNumber < tonumber(GroupBuilder.db.profile.minGearscore) then return end
    
    local maxRoleValues = {
        ["ranged_dps"] = GroupBuilder.db.profile.maxRangedDPS,
        ["melee_dps"] = GroupBuilder.db.profile.maxMeleeDPS,
        ["tank"] = GroupBuilder.db.profile.maxTanks,
        ["healer"] = GroupBuilder.db.profile.maxHealers
    };

    for role, max in pairs(maxRoleValues) do
        if role == "ranged_dps" or role == "melee_dps" then
            if GroupBuilder:CountPlayersByRole("dps") >= GroupBuilder.db.profile.maxDPS or GroupBuilder:CountPlayersByRole(role) >= max then return end
        else
            if GroupBuilder:CountPlayersByRole(role) >= max then return end
        end
    end

    local whispererCharacterName = sender:match("([^%-]+)");

    -- invite them
    local minTimeToInvite, maxTimeToInvite = 4, 10;
    C_Timer.After(math.random(minTimeToInvite, maxTimeToInvite), function ()
        print('inviting ', whispererCharacterName);
        InviteUnit(whispererCharacterName);

        local _, whispererClass = UnitClass(whispererCharacterName);

        GroupBuilder.invitedTable[whispererCharacterName] = {
            ["class"] = whispererClass,
            ["role"] = role,
        };
    end)

    -- remove them from invited table if invite expires
    local inviteExpirationTime = 122;
    C_Timer.After(inviteExpirationTime + maxTimeToInvite, function ()
        if not GroupBuilder:IsInRaidTable(whispererCharacterName) and GroupBuilder:IsInInvitedTable(whispererCharacterName) then
            GroupBuilder.invitedTable[whispererCharacterName] = nil;
        end
    end);
end

function GroupBuilder:HandleErrorMessages(event, msg)
    if not msg:find("is already in a group") then return end
    local playerName = msg:match("(%S+)");
    GroupBuilder.invitedTable[playerName] = nil;
end

function GroupBuilder:AddPlayerToRaidTable(name, role)
    local _, class = UnitClass(name);
    GroupBuilder.raidTable[name] = {
        ["class"] = class,
        ["role"] = role,
    };
end

function GroupBuilder:FindClassCount(class)
    if not class then return end
    local count = 0;
    for characterName, characterData in pairs(GroupBuilder.raidTable) do
        if characterData.class == class then
            count = count + 1;
        end
    end
    return count;
end

function GroupBuilder:RemovePlayerFromRaidTable(name)
    GroupBuilder.raidTable[name] = nil;
end

function GroupBuilder:HandleGroupRosterUpdate(self, event, ...)
    local playerName = UnitName("player");
    if GroupBuilder.db.profile.selectedRole and not GroupBuilder:IsInRaidTable(playerName) then
        GroupBuilder:AddPlayerToRaidTable(playerName, GroupBuilder.db.profile.selectedRole);
    end

    for i = 1, GetNumGroupMembers() do
        local name = GetRaidRosterInfo(i);
        if GroupBuilder:IsInInvitedTable(name) and not GroupBuilder:IsInRaidTable(name) then
            local role = GroupBuilder.invitedTable[name].role;
            GroupBuilder:AddPlayerToRaidTable(name, role);            
            GroupBuilder:RemovePlayerFromRaidTable(name);
        elseif GroupBuilder:IsInInvitedTable(name) and GroupBuilder:IsInRaidTable(name) then
            GroupBuilder.invitedTable[name] = nil;
        end
    end
end
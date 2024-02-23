local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local Config = GroupBuilder.Config;

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

function GroupBuilder:AddPlayerToRaidTable(name, role)
    local _, class = UnitClass(name);
    GroupBuilder.raidTable[name] = {
        ["class"] = class,
        ["role"] = role,
    };
end

function GroupBuilder:RemovePlayerFromRaidTable(name)
    GroupBuilder.raidTable[name] = nil;
end

function GroupBuilder:FindClassCount(class)
    if not class then return end
    local count = 0;
    for characterName, characterData in pairs(GroupBuilder.raidTable) do
        if characterData.class == class then
            count = count + 1;
        end
    end
    for characterName, characterData in pairs(GroupBuilder.invitedTable) do
        if characterData.class == class then
            count = count + 1;
        end
    end
    return count;
end

function GroupBuilder:FindRoleCount(role)
    if not role then return end
    local count = 0;
    for characterName, characterData in pairs(GroupBuilder.raidTable) do
        if characterData.role == role then
            count = count + 1;
        end
    end
    for characterName, characterData in pairs(GroupBuilder.invitedTable) do
        if characterData.role == role then
            count = count + 1;
        end
    end
    return count;
end

function GroupBuilder:CountPlayersByRoleAndClass(role, class)
    if not role or not class then return end
    local count = 0;
    for characterName, characterData in pairs(GroupBuilder.raidTable) do
        if characterData.role == role and characterData.class == class then
            count = count + 1;
        end
    end
    for characterName, characterData in pairs(GroupBuilder.invitedTable) do
        if characterData.role == role and characterData.class == class then
            count = count + 1;
        end
    end
    return count;
end

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


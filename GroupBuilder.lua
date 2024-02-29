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
    local keywordPatternWithGearscoreRole = "(%d*%.?%d+)";
    local gearscoreNumber;
    -- check for pattern with number followed by a role
    for number, role in message:lower():gmatch(keywordPatternWithGearscoreRole) do
        gearscoreNumber = tonumber(number);
        if gearscoreNumber < 1000 then
            gearscoreNumber = gearscoreNumber * 1000;
        end
        -- multiply the number by 1000 to interpret decimals as thousands
        break;
    end

    return gearscoreNumber;
end



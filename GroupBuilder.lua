local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local Config = GroupBuilder.Config;

function GroupBuilder:FindRole(message)
    local foundRole;
    for role, keyWords in pairs(GroupBuilder.roles) do
        for _, keyWord in ipairs(keyWords) do
            if message:find(keyWord) then
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
    local keywordPatternWithGearscoreRole = "(%d*%.?%d*)%s*([kK]?)%s*gs%s*(%d*%.?%d*)%s*([kK]?)%s*(.-)";
    local gearscoreNumber;

    -- check for pattern with number followed by a role
    for number, gsSuffix1, number2, gsSuffix2, role in message:gmatch(keywordPatternWithGearscoreRole) do
        if not string.find(role, "budg") then
            gearscoreNumber = tonumber(number) or tonumber(number2);
            if gearscoreNumber and gearscoreNumber < 1000 then
                -- treat numbers below 1000 as decimals and multiply them by 1000
                gearscoreNumber = gearscoreNumber * 1000;
            end
            -- either a fake gs or was calculated wrong
            if gearscoreNumber >= GroupBuilder.maxGearscoreNumber then
                return nil;
            end

            return gearscoreNumber
        end
    end

    -- check for a number followed by a role without "gs" in between
    local keywordPatternWithRole = "(%d*%.?%d*)%s*([kK]?)%s*(.-)";
    for number, gsSuffix, role in message:gmatch(keywordPatternWithRole) do
        if not string.find(role, "budg") then
            gearscoreNumber = tonumber(number);
            if gearscoreNumber and gearscoreNumber < 1000 then
                -- treat numbers below 1000 as decimals and multiply them by 1000
                gearscoreNumber = gearscoreNumber * 1000;
            end

            -- either a fake gs or was calculated wrong
            if gearscoreNumber and gearscoreNumber >= GroupBuilder.maxGearscoreNumber then
                return nil;
            end

            return gearscoreNumber;
        end
    end

    return nil;
end


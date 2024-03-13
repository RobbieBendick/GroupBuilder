local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local Config = GroupBuilder.Config;

function GroupBuilder:FindRole(message)
    local words = {};
    for word in message:gmatch("%S+") do
        table.insert(words, word);
    end

    -- check for direct matches first
    for _, word in ipairs(words) do
        for role, keyWords in pairs(GroupBuilder.roles) do
            if GroupBuilder:Contains(keyWords, word) then
                return role;
            end
        end
    end

    for _, word in ipairs(words) do
        for role, keyWords in pairs(GroupBuilder.roles) do
            local matches = GroupBuilder:FuzzyFind(word, keyWords, (#word > 3 and 2 or 1));
            if #matches > 0 then
                return role;
            end
        end
    end

    return nil;
end

function GroupBuilder:FindGearscore(message)
    local keywordPatternWithGearscoreRole = "(%d*%.?%d*)%s*([kK]?)%s*gs%s*(%d*%.?%d*)%s*([kK]?)%s*(.-)";
    local gearscoreNumber;

    -- check for pattern with number followed by a role
    for number, gsSuffix1, number2, gsSuffix2, role in message:gmatch(keywordPatternWithGearscoreRole) do
        if not role:find("budg") then
            gearscoreNumber = tonumber(number) or tonumber(number2);
            if gearscoreNumber and gearscoreNumber < 1000 then
                -- treat numbers below 1000 as decimals and multiply them by 1000
                gearscoreNumber = gearscoreNumber * 1000;
            end

            -- either a fake gs, typo, or was calculated wrong
            if gearscoreNumber and gearscoreNumber >= GroupBuilder.maxGearscoreNumber then
                return nil;
            end

            return gearscoreNumber;
        end
    end

    -- check for a number followed by a role without "gs" in between
    local keywordPatternWithRole = "(%d*%.?%d*)%s*([kK]?)%s*(.-)";
    for number, gsSuffix, role in message:gmatch(keywordPatternWithRole) do
        if not role:find("budg") then
            gearscoreNumber = tonumber(number);
            if gearscoreNumber and gearscoreNumber < 1000 then
                -- treat numbers below 1000 as decimals and multiply them by 1000
                gearscoreNumber = gearscoreNumber * 1000;
            end

            -- either a fake gs, typo, or was calculated wrong
            if gearscoreNumber and gearscoreNumber >= GroupBuilder.maxGearscoreNumber then
                return nil;
            end

            return gearscoreNumber;
        end
    end

    return nil;
end


local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");

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

    -- fuzzy find
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

function GroupBuilder:FindClass(message)
    local words = {}
    for word in message:gmatch("%S+") do
        table.insert(words, word);
    end
    
    -- check for exact matches first
    for _, word in ipairs(words) do
        for abbreviation, className in pairs(GroupBuilder.classAbberviations) do
            if word == abbreviation then
                return className;
            end
        end
    end
    
    -- fuzzy find
    for _, word in ipairs(words) do
        for abbreviation, className in pairs(GroupBuilder.classAbberviations) do
            local matches = GroupBuilder:FuzzyFind(word, {abbreviation},  (#word > 3 and 2 or 1));
            if #matches > 0 then
                return className;
            end
        end
    end

    return nil;
end

function GroupBuilder:FindGearscore(message)
    -- match numbers with optional decimal points followed by optional "k" suffix
    local pattern = "(%d*%.?%d+)([kK]?)";

    local gearscoreNumber;

    -- search for the pattern in the message
    for number, kSuffix in message:gmatch(pattern) do
        if not message:match(number.."[kK]?[%s]*[bB]udg?%w*") then
            if kSuffix:lower() == "k" then
                gearscoreNumber = tonumber(number) * 1000;
            else
                gearscoreNumber = tonumber(number);
            end

            -- treat numbers less than 1000 as decimals
            if gearscoreNumber and gearscoreNumber < 1000 then
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

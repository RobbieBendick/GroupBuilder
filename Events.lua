local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local Config = GroupBuilder.Config;


function GroupBuilder:IsInRaidTable(name)
    if not GroupBuilder.db.profile.raidTable then return nil end
    return GroupBuilder.db.profile.raidTable[name] ~= nil;
end

function GroupBuilder:IsInInvitedTable(name)
    if not GroupBuilder.db.profile.invitedTable then return nil end
    return GroupBuilder.db.profile.invitedTable[name] ~= nil;
end

function GroupBuilder:AddPlayerToRaidTable(name, role, gearscore)
    local _, class = UnitClass(name);
    local playerInfo = {
        ["class"] = class,
        ["role"] = role,
    }
    if gearscore then
        playerInfo["gearscore"] = gearscore;
    end
    GroupBuilder.db.profile.raidTable[name] = playerInfo;
    print(("Added %s to raidTab as %s %s with a gearscore of %s"):format(name, role, class, gearscore or "N/A"))
end

function GroupBuilder:RemovePlayerFromRaidTable(name)
    GroupBuilder.db.profile.raidTable[name] = nil;
end

function GroupBuilder:GetClassFromMessage(message)
    message = message:lower();

    for abbreviation, className in pairs(GroupBuilder.classAbberviations) do
        if message:find(abbreviation) then
            return className;
        end
    end

    return nil;
end

function GroupBuilder:IncrementCharacterInteractedWith(characterName)
    if GroupBuilder.recentlyInteractedWith[characterName] then
        GroupBuilder.recentlyInteractedWith[characterName] = GroupBuilder.recentlyInteractedWith[characterName] + 1;
    else
        GroupBuilder.recentlyInteractedWith[characterName] = 1;
    end
end

function GroupBuilder:HandleWhispers(event, message, sender, ...)
    if GroupBuilder.db.profile.isPaused then return end

    local whispererCharacterName = sender:match("([^%-]+)");
    if GroupBuilder:IsInRaidTable(whispererCharacterName) and whispererCharacterName ~= UnitName("player") then
        -- don't want to message or invite people who are already in the group.
        print('in raid table alrdy')
        return
    end 

    -- if whispererCharacterName == UnitName("player") then
    --     return self:Print("Cannot invite yourself.");
    -- end

    local previousWhispersData;
    if GroupBuilder.db.profile.inviteConstruction then
        previousWhispersData = GroupBuilder.db.profile.inviteConstruction[whispererCharacterName];
    end

    local whispererClass = GroupBuilder:GetClassFromMessage(message);



    local gearscoreNumber = GroupBuilder:FindGearscore(message);
    if not gearscoreNumber then
        if previousWhispersData and previousWhispersData.gearscore then
            gearscoreNumber = previousWhispersData.gearscore;
        else
            self:Print("Gearscore not found.");
        end
    end

    local role = GroupBuilder:FindRole(message);
    if not role then
        if previousWhispersData and previousWhispersData.role then
            role = previousWhispersData.role;
        else
            self:Print("Role not found.");
        end
    end

    if previousWhispersData and not whispererClass then
        if previousWhispersData.class then
            whispererClass = previousWhispersData.class
        else
            self:Print("No class mentioned.");
        end
    end

    if GroupBuilder.db.profile.minGearscore and gearscoreNumber and gearscoreNumber < tonumber(GroupBuilder.db.profile.minGearscore) then
        self:Print("Player does not meet Gearscore requirement.");
    end


    -- check what is missing: (gs, class, role)
    local onlyRoleIsMissing = not role and whispererClass and gearscoreNumber;
    local onlyClassIsMissing = not whispererClass and role and gearscoreNumber;
    local onlyGSIsMissing = not gearscoreNumber and whispererClass and role;
    
    local onlyHaveGS = not whispererClass and not role and gearscoreNumber;
    local onlyHaveClass = not gearscoreNumber and not role and whispererClass;
    local onlyHaveRole = not gearscoreNumber and not whispererClass and role;

    local allMissing = not whispererClass and not gearscoreNumber and not role;

    local amountOfInteractionsBeforeStopping = 1;

    if not GroupBuilder.db.profile.inviteConstruction[whispererCharacterName] then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName] = {};
    end

   
    if onlyRoleIsMissing then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].class = whispererClass;
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].gearscore = gearscoreNumber;

        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end

        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("spec?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyClassIsMissing then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].role = role;
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].gearscore = gearscoreNumber;
        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end
        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("class?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyGSIsMissing then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].class = whispererClass;
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].role = role;
        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end
        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("gs?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyHaveGS then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].gearscore = gearscoreNumber;
        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end
        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("spec & class?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyHaveClass then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].class = whispererClass;
        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end

        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("spec & gs?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyHaveRole then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].role = role;

        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end
        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("spec & gs?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    end
    -- check maximum of this particular class
    if GroupBuilder.db.profile[whispererClass.."Maximum"] ~= nil and GroupBuilder.db.profile[whispererClass.."Maximum"] ~= "" and GroupBuilder:FindClassCount(whispererClass) >= tonumber(GroupBuilder.db.profile[whispererClass.."Maximum"]) then
        return self:Print("Too many " .. whispererClass:sub(1, 1) .. whispererClass:sub(2):lower() .. "s");
    end

    if not GroupBuilder.db.profile.maxTotalPlayers then
        return self:Print("Please set the total number of expected players in the Group Requirements options page.");
    end
    -- TODO: gotta refactor this ugly section later...
    -- check if we have room with minimum number of other classes we need in mind
    if GroupBuilder:IsClassNeededForMinimum(whispererClass) then
        if GetNumGroupMembers() + GroupBuilder:FindTotalMinimumOfMissingClasses() - 1 >= GroupBuilder.db.profile.maxTotalPlayers then
            return self:Print("Too many players, Need room for selected minimum classes.");
        end
    else
        if GetNumGroupMembers() + GroupBuilder:FindTotalMinimumOfMissingClasses() >= GroupBuilder.db.profile.maxTotalPlayers then
            return self:Print("Too many players, Need room for selected minimum classes.");
        end
    end

    local maxRoleValues = {
        ["ranged_dps"] = GroupBuilder.db.profile.maxRangedDPS,
        ["melee_dps"] = GroupBuilder.db.profile.maxMeleeDPS,
        ["tank"] = GroupBuilder.db.profile.maxTanks,
        ["healer"] = GroupBuilder.db.profile.maxHealers
    };
    -- check role compatibility with group
    for roleName, max in pairs(maxRoleValues) do
        if max and max ~= "" then
            if roleName == "ranged_dps" or roleName == "melee_dps" then
                print("max: ", tostring(max or 0))
                print('roleName: ', roleName)
                if ( GroupBuilder:CountPlayersByRole("dps") >= tonumber(GroupBuilder.db.profile.maxDPS) ) or ( GroupBuilder:CountPlayersByRole(roleName) >= tonumber(max) ) then 
                    self:Print("Too many " .. roleName .. "s " .. "or full on DPS.");
                    return;
                end
            else
                if GroupBuilder:CountPlayersByRole(roleName) >= tonumber(max) then 
                    self:Print("Too many " .. roleName .. "s");
                    return;
                end
            end
        end
    end

    -- check max role and class (ex: only 1 healer paladin)
    if GroupBuilder.db.profile[role .. whispererClass .. "Maximum"] ~= nil and GroupBuilder.db.profile[role .. whispererClass .. "Maximum"] ~= "" and GroupBuilder:CountPlayersByRoleAndClass(role, whispererClass) >= tonumber(GroupBuilder.db.profile[role .. whispererClass .. "Maximum"]) then
        return self:Print("Too many " .. role:gsub("_", " ") ..  " " .. whispererClass:lower() .. "s, " .. "max is " .. tostring(GroupBuilder.db.profile[role .. whispererClass .. "Maximum"]));
    end


    -- invite them
    C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
        GroupBuilder:Print('inviting', whispererCharacterName);
        InviteUnit(whispererCharacterName);

        GroupBuilder.db.profile.invitedTable[whispererCharacterName] = {
            ["class"] = whispererClass,
            ["role"] = role,
            ["gearscore"] = gearscoreNumber,
        };

        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName] = nil;
    end)

    -- remove them from invited table if invite expires
    local inviteExpirationTime = 122;
    C_Timer.After(inviteExpirationTime + GroupBuilder.maxDelayTime, function ()
        if not GroupBuilder:IsInRaidTable(whispererCharacterName) and GroupBuilder:IsInInvitedTable(whispererCharacterName) then
            GroupBuilder.db.profile.invitedTable[whispererCharacterName] = nil;
        end
    end);
end


function GroupBuilder:HandleGroupRosterUpdate(self, event, ...)
    local playerName = UnitName("player");
    if GroupBuilder.db.profile.selectedRole and not GroupBuilder:IsInRaidTable(playerName) then
        GroupBuilder:AddPlayerToRaidTable(playerName, GroupBuilder.db.profile.selectedRole);
    end

    if GetNumGroupMembers() == 0 then
        GroupBuilder.db.profile.raidTable = {};
        GroupBuilder.db.profile.invitedTable = {};
        GroupBuilder.db.profile.inviteConstruction = {};
    end

    for i = 1, GetNumGroupMembers() do
        local name = GetRaidRosterInfo(i);
	
        if GroupBuilder:IsInInvitedTable(name) and not GroupBuilder:IsInRaidTable(name) then
            local role = GroupBuilder.db.profile.invitedTable[name].role;
            local gs = GroupBuilder.db.profile.invitedTable[name].gearscore;
            GroupBuilder:AddPlayerToRaidTable(name, role, gs);  

            -- remove from invited table
            GroupBuilder.db.profile.invitedTable[name] = nil;
            GroupBuilder.db.profile.inviteConstruction[name] = nil;

        elseif GroupBuilder:IsInInvitedTable(name) and GroupBuilder:IsInRaidTable(name) then
            GroupBuilder.db.profile.invitedTable[name] = nil;
            GroupBuilder.db.profile.inviteConstruction[name] = nil;
        end
    end
    local j = 1;
    if GroupBuilder.db.profile.raidTable and #GroupBuilder.db.profile.raidTable > 0 then
        for unitName, unitData in pairs(GroupBuilder.db.profile.raidTable) do
            GroupBuilder:Print("Raid member ".. j .. "is " .. unitName .. ", a" .. unitData.role .. " " .. unitData.class);
            j = j + 1;
        end
    end
end

function GroupBuilder:HandleErrorMessages(event, msg)
    if not msg:find("is already in a group") then return end
    local playerName = msg:match("(%S+)");
    GroupBuilder.db.profile.invitedTable[playerName] = nil;
end


local defaults = {
    profile = {
        maxHealers = 0,
        maxDPS = 0,
        maxTanks = 0,
        minGearscore = 0,
        maxRangedDPS = 0,
        maxMeleeDPS = 0,
        message = "",
        minimapCoords = {},
        raidTable = {},
        invitedTable = {},
        inviteConstruction = {},
        isPaused = true,
        selectedRaidTemplate = "",
        selectedRole = "",
        selectedRaidType = "",
        selectedSRRaidInfo = "",
        selectedGDKPRaidInfo = "",
        selectedAdvertisementRaid = "",
        minPlayersForAdvertisingCount = 15,
        constructMessageIsActive = false,
        outOfMaxPlayers = 0,
    }
};

function GroupBuilder:OnInitialize()
    -- initialize saved variables with defaults
    GroupBuilder.db = LibStub("AceDB-3.0"):New("GroupBuilderDB", defaults, true);

    C_Timer.After(1, function ()
        if GetNumGroupMembers() == 0 then
            GroupBuilder.db.profile.raidTable = {};
            GroupBuilder.db.profile.invitedTable = {};
            GroupBuilder.db.profile.inviteConstruction = {};
        end 
    end);
    
    -- handle events
    self:RegisterEvent("CHAT_MSG_WHISPER", "HandleWhispers");
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "HandleGroupRosterUpdate");
    self:RegisterEvent("CHAT_MSG_SYSTEM", "HandleErrorMessages");

    -- load config stuff
    Config:LoadStaticPopups();
    Config:CreateMinimapIcon();
    Config:CreateMenu();
end

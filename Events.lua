local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local Config = GroupBuilder.Config;


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
    print("added " .. name .. " to raidTab as " .. class .. " " .. role);
end

function GroupBuilder:RemovePlayerFromRaidTable(name)
    GroupBuilder.raidTable[name] = nil;
end

function GroupBuilder:GetClassFromMessage(message)
    message = message:lower();

    -- iterate over each class and check if it's mentioned in the message
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
    -- if whispererCharacterName == UnitName("player") then
    --     return self:Print("Cannot invite yourself.");
    -- end
    local previousWhispersData = GroupBuilder.inviteConstruction[whispererCharacterName];

    local whispererClass = GroupBuilder:GetClassFromMessage(message);
    local maxRoleValues = {
        ["ranged_dps"] = GroupBuilder.db.profile.maxRangedDPS,
        ["melee_dps"] = GroupBuilder.db.profile.maxMeleeDPS,
        ["tank"] = GroupBuilder.db.profile.maxTanks,
        ["healer"] = GroupBuilder.db.profile.maxHealers
    };



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

    -- check what is missing: (gs, class, role)
    local onlyRoleIsMissing = not role and whispererClass and gearscoreNumber;
    local onlyClassIsMissing = not whispererClass and role and gearscoreNumber;
    local onlyGSIsMissing = not gearscoreNumber and whispererClass and role;
    
    local onlyHaveGS = not whispererClass and not role and gearscoreNumber;
    local onlyHaveClass = not gearscoreNumber and not role and whispererClass;
    local onlyHaveRole = not gearscoreNumber and not whispererClass and role;

    local allMissing = not whispererClass and not gearscoreNumber and not role;

    local amountOfInteractionsBeforeStopping = 1;

    if not GroupBuilder.inviteConstruction[whispererCharacterName] then
        GroupBuilder.inviteConstruction[whispererCharacterName] = {};
    end

    if onlyRoleIsMissing then
        GroupBuilder.inviteConstruction[whispererCharacterName].class = whispererClass;
        GroupBuilder.inviteConstruction[whispererCharacterName].gearscore = gearscoreNumber;

        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end

        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("spec?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyClassIsMissing then
        GroupBuilder.inviteConstruction[whispererCharacterName].role = role;
        GroupBuilder.inviteConstruction[whispererCharacterName].gearscore = gearscoreNumber;
        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end
        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("class?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyGSIsMissing then
        GroupBuilder.inviteConstruction[whispererCharacterName].class = whispererClass;
        GroupBuilder.inviteConstruction[whispererCharacterName].role = role;
        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end
        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("gs?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyHaveGS then
        GroupBuilder.inviteConstruction[whispererCharacterName].gearscore = gearscoreNumber;
        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end
        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("spec & class?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyHaveClass then
        GroupBuilder.inviteConstruction[whispererCharacterName].class = whispererClass;
        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end

        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("spec & gs?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    elseif onlyHaveRole then
        GroupBuilder.inviteConstruction[whispererCharacterName].role = role;

        if GroupBuilder.recentlyInteractedWith[whispererCharacterName] and GroupBuilder.recentlyInteractedWith[whispererCharacterName] >= amountOfInteractionsBeforeStopping then
            return
        end
        C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
            SendChatMessage("spec & gs?", "WHISPER", nil, whispererCharacterName);
            self:IncrementCharacterInteractedWith(whispererCharacterName);
        end);
        return
    end


    if gearscoreNumber < tonumber(GroupBuilder.db.profile.minGearscore) then
        self:Print("Player does not meet Gearscore requirement.");
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

    -- check role compatibility with group
    for roleName, max in pairs(maxRoleValues) do
        if roleName == "ranged_dps" or roleName == "melee_dps" then
            if GroupBuilder:CountPlayersByRole("dps") >= GroupBuilder.db.profile.maxDPS or GroupBuilder:CountPlayersByRole(roleName) >= max then 
                self:Print("Too many " .. roleName .. "s " .. "or full on DPS.");
                return;
            end
        else
            if GroupBuilder:CountPlayersByRole(roleName) >= max then 
                self:Print("Too many " .. roleName .. "s.");
                return;
            end
        end
    end

    -- check max role and class (ex: only 1 healer paladin)
    if GroupBuilder.db.profile[role .. whispererClass .. "Maximum"] ~= nil and GroupBuilder.db.profile[role .. whispererClass .. "Maximum"] ~= "" and GroupBuilder:CountPlayersByRoleAndClass(role, whispererClass) >= tonumber(GroupBuilder.db.profile[role .. whispererClass .. "Maximum"]) then
        return self:Print("Too many " .. role:gsub("_", " ") ..  " " .. whispererClass:lower() .. "s");
    end


    -- invite them
    C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
        GroupBuilder:Print('inviting', whispererCharacterName);
        InviteUnit(whispererCharacterName);

        GroupBuilder.invitedTable[whispererCharacterName] = {
            ["class"] = whispererClass,
            ["role"] = role,
            ["gearscore"] = gearscoreNumber,
        };

        GroupBuilder.inviteConstruction[whispererCharacterName] = nil;
    end)

    -- remove them from invited table if invite expires
    local inviteExpirationTime = 122;
    C_Timer.After(inviteExpirationTime + GroupBuilder.maxDelayTime, function ()
        if not GroupBuilder:IsInRaidTable(whispererCharacterName) and GroupBuilder:IsInInvitedTable(whispererCharacterName) then
            GroupBuilder.invitedTable[whispererCharacterName] = nil;
        end
    end);
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

            -- remove from invited table
            GroupBuilder.invitedTable[name] = nil;

        elseif GroupBuilder:IsInInvitedTable(name) and GroupBuilder:IsInRaidTable(name) then
            GroupBuilder.invitedTable[name] = nil;  
        end
    end
    local j = 1;
    if GroupBuilder.raidTable and #GroupBuilder.raidTable > 0 then
        for unitName, unitData in pairs(GroupBuilder.raidTable) do
            GroupBuilder:Print("Raid member ".. j .. "is " .. unitName .. ", a" .. unitData.role .. " " .. unitData.class);
            j = j + 1;
        end
    end
end

function GroupBuilder:HandleErrorMessages(event, msg)
    if not msg:find("is already in a group") then return end
    local playerName = msg:match("(%S+)");
    GroupBuilder.invitedTable[playerName] = nil;
end

function GroupBuilder:OnInitialize()
    -- initialize saved variables with defaults
    GroupBuilder.db = LibStub("AceDB-3.0"):New("GroupBuilderDB", defaults, true);
    
    -- handle events
    self:RegisterEvent("CHAT_MSG_WHISPER", "HandleWhispers");
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "HandleGroupRosterUpdate");
    self:RegisterEvent("CHAT_MSG_SYSTEM", "HandleErrorMessages");

    -- load config stuff
    Config:LoadStaticPopups();
    Config:CreateMinimapIcon();
    Config:CreateMenu();
end

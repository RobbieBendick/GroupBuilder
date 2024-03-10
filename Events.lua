local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local Config = GroupBuilder.Config;

function GroupBuilder:IsInRaidTable(name)
    return GroupBuilder.db.profile.raidTable[name] ~= nil;
end

function GroupBuilder:IsInInvitedTable(name)
    return GroupBuilder.db.profile.invitedTable[name] ~= nil;
end

function GroupBuilder:GetMaxNumPlayersNeededForRole(role)
    if role == "healer" then
        return tonumber(GroupBuilder.db.profile.maxHealers) or 0;
    elseif role == "tank" then
        return tonumber(GroupBuilder.db.profile.maxTanks) or 0;
    elseif role == "melee_dps" or role == "ranged_dps" then
        return tonumber(GroupBuilder.db.profile.maxDPS) or 0;
    else
        return 0;
    end
end

function GroupBuilder:FindMostNeededRoles()
    local roleCounts = {
        ["tank"] = 0,
        ["healer"] = 0,
        ["dps"] = 0,
    }
    
    -- count the number of players in each role
    for playerName, playerData in pairs(GroupBuilder.db.profile.raidTable) do
        if playerData.role then
            if playerData.role == "melee_dps" or playerData.role == "ranged_dps" then
                roleCounts["dps"] = roleCounts["dps"] + 1;
            else
                roleCounts[playerData.role] = roleCounts[playerData.role] + 1;
            end
        end
    end
    
    -- calculate the percentage of each role filled
    local rolePercentages = {};
    for role, count in pairs(roleCounts) do
        local playersNeededForRole = GroupBuilder:GetMaxNumPlayersNeededForRole(role);
        rolePercentages[role] = count / playersNeededForRole;
    end
    
    -- find the most "missing" two roles based on the lowest percentages
    local mostNeededRoles = {};
    local lowestPercentages = {math.huge, math.huge};
    
    for role, percentage in pairs(rolePercentages) do
        if percentage < lowestPercentages[1] then
            mostNeededRoles[2] = mostNeededRoles[1];
            lowestPercentages[2] = lowestPercentages[1];
            mostNeededRoles[1] = role;
            lowestPercentages[1] = percentage;
        elseif percentage < lowestPercentages[2] then
            mostNeededRoles[2] = role;
            lowestPercentages[2] = percentage;
        end
    end
    
    return mostNeededRoles[1], mostNeededRoles[2];
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
    print(("Added %s to Raid Table as %s %s with a gearscore of %s"):format(name, role, class, gearscore or "N/A"));
end

function GroupBuilder:AddPlayerToInviteTable(name, role, gearscore)
    local _, class = UnitClass(name);
    local playerInfo = {
        ["class"] = class,
        ["role"] = role,
    }
    if gearscore then
        playerInfo["gearscore"] = gearscore;
    end
    GroupBuilder.db.profile.invitedTable[name] = playerInfo;
    C_Timer.After(GroupBuilder.inviteExpirationTime, function ()
        if not GroupBuilder:IsInRaidTable(name) then
            GroupBuilder.db.profile.invitedTable[name] = nil;
        end
    end);

    print(("Added %s to Invited Table as %s %s with a gearscore of %s"):format(name, role, class, gearscore or "N/A"));
end

function GroupBuilder:RemovePlayerFromRaidTable(name)
    GroupBuilder.db.profile.raidTable[name] = nil;
end

function GroupBuilder:FindClass(message)
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

function GroupBuilder:SendDelayedMessage(message, characterName)
    local interactedWithTooManyTimes = GroupBuilder.recentlyInteractedWith[characterName] and GroupBuilder.recentlyInteractedWith[characterName] >= GroupBuilder.amountOfInteractionsBeforeStoppingWhispers;
    if interactedWithTooManyTimes then
        return;
    end
    C_Timer.After(math.random(GroupBuilder.minDelayTime, GroupBuilder.maxDelayTime), function ()
        SendChatMessage(message, "WHISPER", nil, characterName);
        self:IncrementCharacterInteractedWith(characterName);
    end);
end

function GroupBuilder:CheckMissingRequirementsAndReply(role, class, gearscore)
    
end

function GroupBuilder:HandleWhispers(event, message, sender, ...)
    if GroupBuilder.db.profile.isPaused then return end
    message = message:lower();

    local whispererCharacterName = sender:match("([^%-]+)");

    if GroupBuilder:IsInRaidTable(whispererCharacterName) and whispererCharacterName ~= UnitName("player") then
        -- don't want to message or invite people who are already in the group.
        self:Print('in raid table alrdy');
        return;
    end 

    -- if whispererCharacterName == UnitName("player") then
    --     return self:Print("Cannot invite yourself.");
    -- end

    local previousWhispersData;
    if GroupBuilder.db.profile.inviteConstruction then
        previousWhispersData = GroupBuilder.db.profile.inviteConstruction[whispererCharacterName];
    end


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

    local whispererClass = GroupBuilder:FindClass(message);
    if not whispererClass then
        if previousWhispersData and previousWhispersData.class then
            whispererClass = previousWhispersData.class;
        else
            self:Print("Class not found.");
        end
    end

    if GroupBuilder.db.profile.minGearscore and gearscoreNumber and gearscoreNumber < tonumber(GroupBuilder.db.profile.minGearscore) then
        return self:Print("Player does not meet Gearscore requirement.");
    end

    if not GroupBuilder:IsInRaidTable(whispererCharacterName) and GroupBuilder.db.profile.raidPlayersThatLeftGroup[whispererCharacterName] then
        whispererClass = GroupBuilder.db.profile.raidPlayersThatLeftGroup[whispererCharacterName].class;
        role = GroupBuilder.db.profile.raidPlayersThatLeftGroup[whispererCharacterName].role;
        gearscoreNumber = GroupBuilder.db.profile.raidPlayersThatLeftGroup[whispererCharacterName].gearscore;
        self:Print("Getting previous character data for ".. whispererCharacterName);
    end


    -- check what is missing: (gs, class, role)
    local onlyRoleIsMissing = not role and whispererClass and gearscoreNumber;
    local onlyClassIsMissing = not whispererClass and role and gearscoreNumber;
    local onlyGSIsMissing = not gearscoreNumber and whispererClass and role;
    
    local onlyHaveGS = not whispererClass and not role and gearscoreNumber;
    local onlyHaveClass = not gearscoreNumber and not role and whispererClass;
    local onlyHaveRole = not gearscoreNumber and not whispererClass and role;

    local allMissing = not whispererClass and not gearscoreNumber and not role;

    if not GroupBuilder.db.profile.inviteConstruction[whispererCharacterName] then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName] = {};
    end

    if onlyRoleIsMissing then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].class = whispererClass;
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].gearscore = gearscoreNumber;
        GroupBuilder:SendDelayedMessage("spec?", whispererCharacterName);
        return;
    elseif onlyClassIsMissing then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].role = role;
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].gearscore = gearscoreNumber;
        GroupBuilder:SendDelayedMessage("class?", whispererCharacterName);
        return;
    elseif onlyGSIsMissing then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].class = whispererClass;
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].role = role;
        GroupBuilder:SendDelayedMessage("gs?", whispererCharacterName);
        return;
    elseif onlyHaveGS then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].gearscore = gearscoreNumber;
        GroupBuilder:SendDelayedMessage("spec & class?", whispererCharacterName);
        return;
    elseif onlyHaveClass then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].class = whispererClass;
        GroupBuilder:SendDelayedMessage("spec & gs?", whispererCharacterName);
        return;
    elseif onlyHaveRole then
        GroupBuilder.db.profile.inviteConstruction[whispererCharacterName].role = role;
        GroupBuilder:SendDelayedMessage("class & gs?", whispererCharacterName);
        return;
    end

    if not whispererClass then
        self:Print("No class found.");
        GroupBuilder:SendDelayedMessage("spec, class & gs?", whispererCharacterName);
        return;
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
                if ( GroupBuilder:CountPlayersByRole("dps") >= tonumber(GroupBuilder.db.profile.maxDPS) ) or ( GroupBuilder:CountPlayersByRole(roleName) >= tonumber(max) ) then 
                    return self:Print("Too many " .. roleName .. "s " .. "or full on DPS.");
                end
            else
                if GroupBuilder:CountPlayersByRole(roleName) >= tonumber(max) then 
                    return self:Print("Too many " .. roleName .. "s");
                end
            end
        end
    end

    -- check max role and class (ex: only 1 healer paladin)
    if GroupBuilder.db.profile[role .. whispererClass .. "Maximum"] ~= nil and GroupBuilder.db.profile[role .. whispererClass .. "Maximum"] ~= "" and GroupBuilder:CountPlayersByRoleAndClass(role, whispererClass) >= tonumber(GroupBuilder.db.profile[role .. whispererClass .. "Maximum"]) then
        return self:Print("Too many " .. role:gsub("_", " ") ..  " " .. whispererClass:lower() .. "s, " .. "max is " .. tostring(GroupBuilder.db.profile[role .. whispererClass .. "Maximum"]));
    end

    -- everything is good, invite them
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
    C_Timer.After(GroupBuilder.inviteExpirationTime + GroupBuilder.maxDelayTime, function ()
        if not GroupBuilder:IsInRaidTable(whispererCharacterName) and GroupBuilder:IsInInvitedTable(whispererCharacterName) then
            GroupBuilder.db.profile.invitedTable[whispererCharacterName] = nil;
        end
    end);
end

function GroupBuilder:HandleGroupRosterUpdate(self, event, ...)
    if GroupBuilder.db.profile.isPaused then
        return;
    end

    -- convert to raid
    if not IsInRaid() and GetNumGroupMembers() > 0 then
        C_Timer.After(1, function ()
            C_PartyInfo.ConvertToRaid();
        end)
    end

    -- update player in the raid table
    local playerName = UnitName("player");
    if GroupBuilder:IsInRaidTable(playerName) and GroupBuilder.db.profile.selectedRole ~= GroupBuilder.db.profile.raidTable[playerName].role then
        GroupBuilder.db.profile.raidTable[playerName].role = GroupBuilder.db.profile.selectedRole;
    end 
    if GroupBuilder.db.profile.selectedRole and not GroupBuilder:IsInRaidTable(playerName) then
        GroupBuilder:AddPlayerToRaidTable(playerName, GroupBuilder.db.profile.selectedRole);
    end

    if GetNumGroupMembers() == 0 then
        GroupBuilder.db.profile.raidTable = {};
        GroupBuilder.db.profile.invitedTable = {};
        GroupBuilder.db.profile.inviteConstruction = {};
        GroupBuilder.db.profile.raidPlayersThatLeftGroup = {};
    end

    local _, instanceType = IsInInstance();

    -- (24/25) (9/10) // this would be a thresholdPlayersMissing of 1
    local thresholdPlayersMissing = 1;
    -- group is about ready. wake up.
    if not GroupBuilder.db.profile.isPaused and instanceType ~= "pvp" and GetNumGroupMembers() >= GroupBuilder.db.profile.maxTotalPlayers - thresholdPlayersMissing then
        for i = 1, 5 do
            C_Timer.After(2, function()
                PlaySound(SOUNDKIT.READY_CHECK, "Dialog");
            end);
        end
    end


    local names = {};
    for i = 1, GetNumGroupMembers() do
        local name = GetRaidRosterInfo(i);
        table.insert(names, name);
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

    for playerName, playerData in pairs(GroupBuilder.db.profile.raidTable) do
        if not GroupBuilder:Contains(names, playerName) then
            -- player left the group.
            GroupBuilder.db.profile.raidPlayersThatLeftGroup[playerName] = playerData;
            GroupBuilder:RemovePlayerFromRaidTable(playerName);
        end
    end
    GroupBuilder:UpdateGUI();
end

function GroupBuilder:HandleErrorMessages(event, msg)
    if not msg:find("is already in a group") then return end
    local playerName = msg:match("(%S+)");
    GroupBuilder.db.profile.invitedTable[playerName] = nil;
end
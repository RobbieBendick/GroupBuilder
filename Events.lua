local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local Config = GroupBuilder.Config;

function GroupBuilder:HandleWhispers(event, message, sender, ...)
    if GroupBuilder.db.profile.isPaused then return end

    local gearscoreNumber = GroupBuilder:FindGearscore(message);
    if not gearscoreNumber then return end

    if gearscoreNumber < tonumber(GroupBuilder.db.profile.minGearscore) then return end

    local role = GroupBuilder:FindRole(message);
    if not role then return end
    
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
    local _, whispererClass = UnitClass(whispererCharacterName);

    -- check maximum of this particular class
    if GroupBuilder.db.profile[whispererClass.."Maximum"] ~= nil and GroupBuilder:FindClassCount(whispererClass) >= tonumber(GroupBuilder.db.profile[whispererClass.."Maximum"]) then
        return self:Print("Too many " .. whispererClass:sub(1,1) .. whispererClass:sub(2):lower() .. "s");
    end

    -- TODO: add up all the leftover required minimum players needed.

    -- invite them
    local minTimeToInvite, maxTimeToInvite = 4, 10;
    C_Timer.After(math.random(minTimeToInvite, maxTimeToInvite), function ()
        GroupBuilder:Print('inviting', whispererCharacterName);
        InviteUnit(whispererCharacterName);

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

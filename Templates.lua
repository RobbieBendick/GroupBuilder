local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

function GroupBuilder:ResetTemplate()
    GroupBuilder.db.profile.maxDPS = 0;
    GroupBuilder.db.profile.maxTanks = 0;
    GroupBuilder.db.profile.maxHealers = 0;
    GroupBuilder.db.profile.maxRangedDPS = 0;
    GroupBuilder.db.profile.maxMeleeDPS = 0;
    GroupBuilder.db.profile.minGearscore = 0;
    GroupBuilder.db.profile.maxTotalPlayers = 0;

    for roleName in pairs(GroupBuilder.roles) do
        for i, class in ipairs(GroupBuilder.classes) do
            if GroupBuilder.db.profile[roleName .. class .. "Maximum"] and GroupBuilder:Contains(GroupBuilder.roleClasses[roleName], class) then
                GroupBuilder.db.profile[roleName .. class .. "Maximum"] = "";
            end
        end
    end

end

function GroupBuilder:CheckForPlayerRole()
    local selectedRole = GroupBuilder.db.profile.selectedRole;
    if not selectedRole then return end
    if selectedRole == "ranged_dps" then
        if GroupBuilder.db.profile.maxDPS ~= "" and GroupBuilder.db.profile.maxDPS ~= 0 then
            GroupBuilder.db.profile.maxDPS = GroupBuilder.db.profile.maxDPS - 1;
        end
        if GroupBuilder.db.profile.maxRangedDPS ~= "" and GroupBuilder.db.profile.maxRangedDPS ~= 0 then
            GroupBuilder.db.profile.maxRangedDPS = GroupBuilder.db.profile.maxRangedDPS - 1;
        end
    elseif selectedRole == "melee_dps" then
        if GroupBuilder.db.profile.maxDPS ~= "" and GroupBuilder.db.profile.maxDPS ~= 0 then
            GroupBuilder.db.profile.maxDPS = GroupBuilder.db.profile.maxDPS - 1;
        end
        if GroupBuilder.db.profile.maxMeleeDPS ~= "" and GroupBuilder.db.profile.maxMeleeDPS ~= 0 then
            GroupBuilder.db.profile.maxMeleeDPS = GroupBuilder.db.profile.maxMeleeDPS - 1;
        end
    elseif selectedRole == "tank" then
        if GroupBuilder.db.profile.maxTanks ~= "" and GroupBuilder.db.profile.maxTanks ~= 0 then
            GroupBuilder.db.profile.maxTanks = GroupBuilder.db.profile.maxTanks - 1;
        end
    elseif selectedRole == "healer" then
        if GroupBuilder.db.profile.maxHealers ~= "" and GroupBuilder.db.profile.maxHealers ~= 0 then
            GroupBuilder.db.profile.maxHealers = GroupBuilder.db.profile.maxHealers - 1;
        end
    end
end

function GroupBuilder:IcecrownCitadel25Template()
    GroupBuilder:ResetTemplate()
    GroupBuilder.db.profile.maxDPS = 17;
    GroupBuilder.db.profile.maxTanks = 2;
    GroupBuilder.db.profile.maxHealers = 6;
    GroupBuilder.db.profile.maxRangedDPS = 10;
    GroupBuilder.db.profile.maxMeleeDPS = 10;
    GroupBuilder.db.profile.minGearscore = 5600;
    GroupBuilder.db.profile.maxTotalPlayers = 25;
    GroupBuilder.db.profile["healerPRIESTMaximum"] = 1;
    GroupBuilder.db.profile["healerSHAMANMaximum"] = 2;
    GroupBuilder.db.profile["healerPALADINMaximum"] = 2;
    GroupBuilder.db.profile["healerDRUIDMaximum"] = 2;

    GroupBuilder.db.profile["tankDRUIDMaximum"] = 1;

    GroupBuilder.db.profile["WARLOCKMinimum"] = 1;


    GroupBuilder:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(GroupBuilder.addonName);
end

function GroupBuilder:IcecrownCitadel10Template()
    GroupBuilder:ResetTemplate()
    GroupBuilder.db.profile.maxDPS = 5;
    GroupBuilder.db.profile.maxTanks = 2;
    GroupBuilder.db.profile.maxHealers = 3;
    GroupBuilder.db.profile.maxRangedDPS = 4;
    GroupBuilder.db.profile.maxMeleeDPS = 4;
    GroupBuilder.db.profile.minGearscore = 5400;
    GroupBuilder.db.profile.maxTotalPlayers = 10;
    GroupBuilder:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(GroupBuilder.addonName);
end

function GroupBuilder:RubySanctum10Template()
    GroupBuilder:ResetTemplate()
    GroupBuilder.db.profile.maxDPS = 5;
    GroupBuilder.db.profile.maxTanks = 2;
    GroupBuilder.db.profile.maxHealers = 3;
    GroupBuilder.db.profile.maxRangedDPS = 4;
    GroupBuilder.db.profile.maxMeleeDPS = 4;
    GroupBuilder.db.profile.minGearscore = 5400;
    GroupBuilder.db.profile.maxTotalPlayers = 10;
    GroupBuilder:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(GroupBuilder.addonName);
end

function GroupBuilder:RubySanctum25Template()
    GroupBuilder:ResetTemplate()
    GroupBuilder.db.profile.maxDPS = 17;
    GroupBuilder.db.profile.maxTanks = 2;
    GroupBuilder.db.profile.maxHealers = 6;
    GroupBuilder.db.profile.maxRangedDPS = 10;
    GroupBuilder.db.profile.maxMeleeDPS = 10;
    GroupBuilder.db.profile.minGearscore = 5600;
    GroupBuilder.db.profile.maxTotalPlayers = 25;
    GroupBuilder:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(GroupBuilder.addonName);
end

function GroupBuilder:VaultOfArchavon25Template()
    GroupBuilder:ResetTemplate()
    GroupBuilder.db.profile.minGearscore = 4000;
    GroupBuilder.db.profile.maxTanks = 2;
    GroupBuilder.db.profile.maxHealers = 4;
    GroupBuilder.db.profile.maxDPS = 15;
    GroupBuilder.db.profile.maxMeleeDPS = "";
    GroupBuilder.db.profile.maxRangedDPS = "";

    GroupBuilder.db.profile.maxTotalPlayers = 25;


    -- set 1 for each role/class pair
    for roleName in pairs(GroupBuilder.roles) do
        for i, class in ipairs(GroupBuilder.classes) do
            if GroupBuilder:Contains(GroupBuilder.roleClasses[roleName], class) then
                GroupBuilder.db.profile[roleName .. class .. "Maximum"] = 1;
            end
        end
    end
    GroupBuilder:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(GroupBuilder.addonName);
end

function GroupBuilder:VaultOfArchavon10Template()
    GroupBuilder:ResetTemplate()
    GroupBuilder.db.profile.minGearscore = 4000;
    GroupBuilder.db.profile.maxTanks = 2;
    GroupBuilder.db.profile.maxHealers = 3;
    GroupBuilder.db.profile.maxDPS = 5;
    GroupBuilder.db.profile.maxMeleeDPS = "";
    GroupBuilder.db.profile.maxRangedDPS = "";
    GroupBuilder.db.profile.maxTotalPlayers = 10;

    -- set 1 for each role/class pair
    for roleName in pairs(GroupBuilder.roles) do
        for i, class in ipairs(GroupBuilder.classes) do
            if GroupBuilder:Contains(GroupBuilder.roleClasses[roleName], class) then
                GroupBuilder.db.profile[roleName .. class .. "Maximum"] = 1;
            end
        end
    end


    GroupBuilder:CheckForPlayerRole();
    AceConfigRegistry:NotifyChange(GroupBuilder.addonName);
end



GroupBuilder.raidTemplates = {
    ["Reset"] = GroupBuilder.ResetTemplate,
    ["Icecrown Citadel 25"] = GroupBuilder.IcecrownCitadel25Template,
    ["Icecrown Citadel 10"] = GroupBuilder.IcecrownCitadel10Template,
    ["Ruby Sanctum 25"] = GroupBuilder.RubySanctum25Template,
    ["Ruby Sanctum 10"] = GroupBuilder.RubySanctum10Template,
    ["Vault Of Archavon 25"] = GroupBuilder.VaultOfArchavon25Template,
    ["Vault Of Archavon 10"] = GroupBuilder.VaultOfArchavon10Template,
}

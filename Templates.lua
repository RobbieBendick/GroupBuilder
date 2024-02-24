local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

function GroupBuilder:NoneTemplate()
    GroupBuilder.db.profile.maxDPS = 0;
    GroupBuilder.db.profile.maxTanks = 0;
    GroupBuilder.db.profile.maxHealers = 0;
    GroupBuilder.db.profile.maxRangedDPS = 0;
    GroupBuilder.db.profile.maxMeleeDPS = 0;
    GroupBuilder.db.profile.minGearscore = 0;
    GroupBuilder.db.profile.maxTotalPlayers = 0;
end

function GroupBuilder:CheckForPlayerRole()
    local selectedRole = GroupBuilder.db.profile.selectedRole;
    if not selectedRole then return end
    if selectedRole == "ranged_dps" then
        GroupBuilder.db.profile.maxDPS = GroupBuilder.db.profile.maxDPS - 1;
        GroupBuilder.db.profile.maxRangedDPS = GroupBuilder.db.profile.maxRangedDPS - 1;
    elseif selectedRole == "melee_dps" then
        GroupBuilder.db.profile.maxDPS = GroupBuilder.db.profile.maxDPS - 1;
        GroupBuilder.db.profile.maxMeleeDPS = GroupBuilder.db.profile.maxMeleeDPS - 1;
    elseif selectedRole == "tank" then
        GroupBuilder.db.profile.maxTanks = GroupBuilder.db.profile.maxTanks - 1;
    elseif selectedRole == "healer" then
        GroupBuilder.db.profile.maxHealers = GroupBuilder.db.profile.maxHealers - 1;
    end
end

function GroupBuilder:IcecrownCitadel25Template()
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

function GroupBuilder:IcecrownCitadel10Template()
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


GroupBuilder.raidTemplates = {
    ["None"] = GroupBuilder.NoneTemplate,
    ["Icecrown Citadel 25"] = GroupBuilder.IcecrownCitadel25Template,
    ["Icecrown Citadel 10"] = GroupBuilder.IcecrownCitadel10Template,
    ["Ruby Sanctum 25"] = GroupBuilder.RubySanctum25Template,
    ["Ruby Sanctum 10"] = GroupBuilder.RubySanctum10Template,
}

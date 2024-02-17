local _, core = ...;

function GB:NoneTemplate()
    core.db.profile.maxDPS = 0;
    core.db.profile.maxTanks = 0;
    core.db.profile.maxHealers = 0;
    core.db.profile.maxRangedDPS = 0;
    core.db.profile.maxMeleeDPS = 0;
    core.db.profile.minGearscore = 0;
end

function GB:CheckForPlayerRole()
    local selectedRole = core.db.profile.selectedRole;
    if not selectedRole then return end
    if selectedRole == "ranged_dps" then
        core.db.profile.maxDPS = core.db.profile.maxDPS - 1;
        core.db.profile.maxRangedDPS = core.db.profile.maxRangedDPS - 1;
    elseif selectedRole == "melee_dps" then
        core.db.profile.maxDPS = core.db.profile.maxDPS - 1;
        core.db.profile.maxMeleeDPS = core.db.profile.maxMeleeDPS - 1;
    elseif selectedRole == "tank" then
        core.db.profile.maxTanks = core.db.profile.maxTanks - 1;
    elseif selectedRole == "healer" then
        core.db.profile.maxHealers = core.db.profile.maxHealers - 1;
    end
end

function GB:IcecrownCitadelTemplate()
    core.db.profile.maxDPS = 17;
    core.db.profile.maxTanks = 2;
    core.db.profile.maxHealers = 6;
    core.db.profile.maxRangedDPS = 10;
    core.db.profile.maxMeleeDPS = 10;
    core.db.profile.minGearscore = 5600;
    GB:CheckForPlayerRole();
end

GB.raidTemplates = {
    ["None"] = GB.NoneTemplate,
    ["Icecrown Citadel"] = GB.IcecrownCitadelTemplate,
}
local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local AceGUI = LibStub("AceGUI-3.0");

GroupBuilder.GUIFrame = AceGUI:Create("Frame");
GroupBuilder.GUIFrame:SetTitle("Raid Group Representation");
GroupBuilder.GUIFrame:SetLayout("Flow");

local tankGroup = AceGUI:Create("InlineGroup");
tankGroup:SetFullWidth(true);
tankGroup:SetTitle("Tanks");
GroupBuilder.GUIFrame:AddChild(tankGroup);

local healerGroup = AceGUI:Create("InlineGroup");
healerGroup:SetFullWidth(true);
healerGroup:SetTitle("Healers");
GroupBuilder.GUIFrame:AddChild(healerGroup);

local dpsGroup = AceGUI:Create("InlineGroup");
dpsGroup:SetFullWidth(true);
dpsGroup:SetTitle("DPS");
GroupBuilder.GUIFrame:AddChild(dpsGroup);

local function CreatePlayerWidget(playerName, playerData)
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullWidth(true)

    local playerNameLabel = AceGUI:Create("Label")
    local classColor = RAID_CLASS_COLORS[playerData.class].colorStr
    local playerNameText = "|c" .. classColor .. playerName .. "|r"

    playerNameLabel:SetText(playerNameText)
    playerNameLabel:SetRelativeWidth(0.2)

    local classIcon = "|TInterface\\icons\\ClassIcon_" .. playerData.class:upper() .. ":20:20|t"
    local classIconLabel = AceGUI:Create("Label")
    classIconLabel:SetText(classIcon)
    classIconLabel:SetRelativeWidth(0.1)

    local roleDropdown = AceGUI:Create("Dropdown")
    roleDropdown:SetList({
        tank = "Tank",
        healer = "Healer",
        melee_dps = "Melee DPS",
        ranged_dps = "Ranged DPS"
    })
    roleDropdown:SetValue(playerData.role);
    roleDropdown:SetWidth(100);
    roleDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        playerData.role = value;
        GroupBuilder.UpdateGUI();
    end)

    local playerDataLabel = AceGUI:Create("Label");
    playerDataLabel:SetText("Role: " .. playerData.role:gsub("_", " ") .. "\n" .. "Gearscore: " .. tostring(playerData.gearscore));
    playerDataLabel:SetRelativeWidth(0.6);

    local kickButton = AceGUI:Create("Button");
    kickButton:SetText("Kick");
    kickButton:SetWidth(60);
    kickButton:SetCallback("OnClick", function()
        UninviteUnit(playerName);
        GroupBuilder.db.profile.raidTable[playerName] = nil;
        GroupBuilder.UpdateGUI();
    end);

    group:AddChild(playerNameLabel);
    group:AddChild(classIconLabel);
    group:AddChild(roleDropdown);
    group:AddChild(playerDataLabel);
    group:AddChild(kickButton);

    return group
end


function GroupBuilder:CreateCounterLabel(count, maxCount)
    return string.format("(%d/%d)", count, maxCount);
end

function GroupBuilder:UpdateGUI()
    tankGroup:ReleaseChildren();
    healerGroup:ReleaseChildren();  
    dpsGroup:ReleaseChildren();

    local tankCount = GroupBuilder:CountPlayersByRole("tank");
    local healerCount = GroupBuilder:CountPlayersByRole("healer");
    local dpsCount = GroupBuilder:CountPlayersByRole("dps");

    tankGroup:SetTitle("Tanks " .. GroupBuilder:CreateCounterLabel(tankCount, (GroupBuilder.db.profile.selectedRole == "tank" and GroupBuilder.db.profile.maxTanks + 1) or GroupBuilder.db.profile.maxTanks));
    healerGroup:SetTitle("Healers " .. GroupBuilder:CreateCounterLabel(healerCount, (GroupBuilder.db.profile.selectedRole == "healer" and GroupBuilder.db.profile.maxHealers + 1) or GroupBuilder.db.profile.maxHealers));
    dpsGroup:SetTitle("DPS " .. GroupBuilder:CreateCounterLabel(dpsCount, ( (GroupBuilder.db.profile.selectedRole == "ranged_dps" or GroupBuilder.db.profile.selectedRole == "melee_dps") and GroupBuilder.db.profile.maxDPS + 1) or GroupBuilder.db.profile.maxDPS));

    if GroupBuilder.db.profile.raidTable then
        for playerName, playerData in pairs(GroupBuilder.db.profile.raidTable) do
            local playerInfoWidget = CreatePlayerWidget(playerName, playerData);
            playerInfoWidget:SetFullWidth(true);
            
            if playerData.role == "tank" then
                tankGroup:AddChild(playerInfoWidget);
            elseif playerData.role == "ranged_dps" or playerData.role == "melee_dps" then
                dpsGroup:AddChild(playerInfoWidget);
            elseif playerData.role == "healer" then
                healerGroup:AddChild(playerInfoWidget);
            end
        end
    end

    if GroupBuilder:CountPlayersByRole("tank") == 0 then
        local tankLabel = AceGUI:Create("Label");
        tankLabel:SetText("Group doesn't have any tanks");
        tankLabel:SetFullWidth(true);
        tankGroup:AddChild(tankLabel);
    end

    if GroupBuilder:CountPlayersByRole("healer") == 0 then
        local healerLabel = AceGUI:Create("Label");
        healerLabel:SetText("Group doesn't have any healers");
        healerLabel:SetFullWidth(true);
        healerGroup:AddChild(healerLabel);
    end

    if GroupBuilder:CountPlayersByRole("dps") == 0 then
        local dpsLabel = AceGUI:Create("Label");
        dpsLabel:SetText("Group doesn't have any DPS");
        dpsLabel:SetFullWidth(true);
        dpsGroup:AddChild(dpsLabel);
    end
    GroupBuilder.GUIFrame:DoLayout()

end

GroupBuilder.GUIFrame:Hide();
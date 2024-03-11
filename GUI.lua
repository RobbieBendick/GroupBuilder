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

function GroupBuilder:CreateMargin()
    local margin = AceGUI:Create("Label");
    margin:SetText(" ");
    margin:SetRelativeWidth(0.1);
    return margin;
end

local function CreatePlayerWidget(playerName, playerData)
    local group = AceGUI:Create("SimpleGroup");
    group:SetFullWidth(true);

    local playerNameLabel = AceGUI:Create("Label");
    local classColor = RAID_CLASS_COLORS[playerData.class].colorStr;
    local playerNameText = "|c" .. classColor .. playerName .. "|r";
    local classIcon = "|TInterface\\icons\\ClassIcon_" .. playerData.class:upper() .. ":20:20|t";

    playerNameLabel:SetText(classIcon .. " " .. playerNameText);
    playerNameLabel:SetRelativeWidth(0.2);

    local roleDropdown = AceGUI:Create("Dropdown");
    roleDropdown:SetList({
        tank = "Tank",
        healer = "Healer",
        melee_dps = "Melee",
        ranged_dps = "Ranged"
    });
    roleDropdown:SetValue(playerData.role);
    roleDropdown:SetWidth(80);
    roleDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        playerData.role = value;
        GroupBuilder.UpdateGUI();
    end)

    local playerDataLabel = AceGUI:Create("Label");
    playerDataLabel:SetText(tostring(playerData.gearscore) .. " gs");
    playerDataLabel:SetRelativeWidth(0.7);

    local kickButton = AceGUI:Create("Button");
    kickButton:SetText("Kick");
    kickButton:SetWidth(60);
    kickButton:SetCallback("OnClick", function()
        StaticPopupDialogs["ARE_YOU_SURE_YOU_WANT_TO_KICK"].text = "Are you sure you want to kick " .. playerName .. " from the raid?";
        StaticPopupDialogs["ARE_YOU_SURE_YOU_WANT_TO_KICK"].OnAccept = function ()
            UninviteUnit(playerName);
            GroupBuilder.db.profile.raidTable[playerName] = nil;
            GroupBuilder.db.profile.inviteConstruction[playerName] = nil;
            GroupBuilder:UpdateGUI();
        end
        StaticPopup_Show("ARE_YOU_SURE_YOU_WANT_TO_KICK");
    end);

    group:AddChild(playerNameLabel);
    group:AddChild(roleDropdown);
    group:AddChild(GroupBuilder:CreateMargin());
    group:AddChild(playerDataLabel);
    group:AddChild(GroupBuilder:CreateMargin());
    group:AddChild(kickButton);

    return group;
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
    
    GroupBuilder.GUIFrame:DoLayout();
end

GroupBuilder.GUIFrame:Hide();
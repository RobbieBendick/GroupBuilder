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
    local playerNameText = "|c" .. classColor .. playerName .. "|r"  -- Adjust the color here

    playerNameLabel:SetText(playerNameText)
    playerNameLabel:SetFullWidth(true)
    playerNameLabel:SetRelativeWidth(0.2) -- Adjust the relative width

    local classIcon = "|TInterface\\icons\\ClassIcon_" .. string.upper(playerData.class) .. ":20:20|t"
    local classIconLabel = AceGUI:Create("Label")
    classIconLabel:SetText(classIcon)
    classIconLabel:SetRelativeWidth(0.1) -- Adjust the relative width

    local playerDataLabel = AceGUI:Create("Label")
    playerDataLabel:SetText("Role: " .. playerData.role .. "\n" .. "Gearscore: " .. playerData.gearscore)
    playerDataLabel:SetRelativeWidth(0.7) -- Adjust the relative width

    group:AddChild(playerNameLabel)
    group:AddChild(classIconLabel)
    group:AddChild(playerDataLabel)

    return group
end


function GroupBuilder:UpdateGUI()
    tankGroup:ReleaseChildren()
    healerGroup:ReleaseChildren()
    dpsGroup:ReleaseChildren()

    if GroupBuilder.db.profile.raidTable then
        for playerName, playerData in pairs(GroupBuilder.db.profile.raidTable) do
            local playerNameLabel = AceGUI:Create("Label");
            local playerInfoLabel = CreatePlayerWidget(playerName, playerData);
            playerInfoLabel:SetFullWidth(true);
            
            if playerData.role == "tank" then
                tankGroup:AddChildren(playerNameLabel, playerInfoLabel);
            elseif playerData.role == "ranged_dps" or playerData.role == "melee_dps" then
                dpsGroup:AddChildren(playerNameLabel, playerInfoLabel);
            elseif playerData.role == "healer" then
                healerGroup:AddChildren(playerNameLabel, playerInfoLabel);
            end
        end
    end
end


GroupBuilder.GUIFrame:Hide();


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


local function CreateLabelWidget(text)
    local label = AceGUI:Create("Label");
    label:SetText(text);
    label:SetFullWidth(true);
    return label;
end

function GroupBuilder:UpdateGUI()
    tankGroup:ReleaseChildren()
    healerGroup:ReleaseChildren()
    dpsGroup:ReleaseChildren()
    if self.db.profile.raidTable and #self.db.profile.raidTable > 0 then
        for playerName, playerData in pairs(GroupBuilder.db.profile.raidTable) do
            local playerNameLabel = CreateLabelWidget(playerName);
            if playerData.role == "tank" then
                tankGroup:AddChild(playerNameLabel)
            elseif playerData.role == "ranged_dps" or playerData.role == "melee_dps" then
                dpsGroup:AddChild(playerNameLabel)
            elseif playerData.role == "healer" then
                healerGroup:AddChild(playerNameLabel);
            end
        end
    end
end


GroupBuilder.GUIFrame:Hide();


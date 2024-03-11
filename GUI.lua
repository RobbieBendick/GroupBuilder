local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local AceGUI = LibStub("AceGUI-3.0");


local mainScrollFrame = AceGUI:Create("ScrollFrame");
mainScrollFrame:SetFullWidth(true);
mainScrollFrame:SetFullHeight(true);

GroupBuilder.GUIFrame = AceGUI:Create("Frame");
GroupBuilder.GUIFrame:SetTitle("Raid Group Representation");
GroupBuilder.GUIFrame:SetLayout("Fill");
GroupBuilder.GUIFrame:AddChild(mainScrollFrame);

local tankGroup = AceGUI:Create("InlineGroup");
tankGroup:SetLayout("Flow")
tankGroup:SetFullWidth(true);
tankGroup:SetTitle("Tanks");
mainScrollFrame:AddChild(tankGroup);

local healerGroup = AceGUI:Create("InlineGroup");
healerGroup:SetLayout("Flow");

healerGroup:SetFullWidth(true);
healerGroup:SetTitle("Healers");
mainScrollFrame:AddChild(healerGroup);

local dpsGroup = AceGUI:Create("InlineGroup");
dpsGroup:SetLayout("Flow")
dpsGroup:SetFullWidth(true);
dpsGroup:SetTitle("DPS");
mainScrollFrame:AddChild(dpsGroup);

function GroupBuilder:CreateMargin()
    local margin = AceGUI:Create("Label");
    margin:SetText(" ");
    margin:SetRelativeWidth(0.1);
    return margin;
end
local function CreateAddPlayerDialog()
    local dialog = AceGUI:Create("Frame");
    dialog:SetTitle("Add Player");
    dialog:SetLayout("Flow");

    local playerNameEditBox = AceGUI:Create("EditBox");
    playerNameEditBox:SetLabel("Player Name");
    playerNameEditBox:SetFullWidth(true);
    dialog:AddChild(playerNameEditBox);

    local roleDropdown = AceGUI:Create("Dropdown");
    roleDropdown:SetLabel("Role");
    roleDropdown:SetList({
        tank = "Tank",
        healer = "Healer",
        melee_dps = "Melee",
        ranged_dps = "Ranged"
    });
    roleDropdown:SetFullWidth(true);
    dialog:AddChild(roleDropdown);

    local classDropdown = AceGUI:Create("Dropdown");
    classDropdown:SetLabel("Class");
    classDropdown:SetList({
        ["ROGUE"] = "Rogue",
        ["WARRIOR"] = "Warrior",
        ["PRIEST"] = "Priest",
        ["MAGE"] = "Mage", 
        ["PALADIN"] = "Paladin",
        ["HUNTER"] = "Hunter",
        ["DEATHKNIGHT"] = "Deathknight",
        ["SHAMAN"] = "Shaman",
        ["WARLOCK"] = "Warlock",
        ["DRUID"] = "Druid",
    });
    classDropdown:SetFullWidth(true);
    dialog:AddChild(classDropdown);
    
    local gearscoreEditBox = AceGUI:Create("EditBox");
    gearscoreEditBox:SetLabel("Gearscore");
    gearscoreEditBox:SetFullWidth(true);
    dialog:AddChild(gearscoreEditBox);

    local addButton = AceGUI:Create("Button");
    addButton:SetText("Add Player");
    addButton:SetRelativeWidth(1);
    addButton:SetCallback("OnClick", function()
        local playerName = playerNameEditBox:GetText():sub(1,1):upper() .. playerNameEditBox:GetText():sub(2):lower();
        local role = roleDropdown:GetValue();
        local class = classDropdown:GetValue();
        local gearscore = tonumber(gearscoreEditBox:GetText()) or 0;

        if playerName == "" or not role or not class or not gearscore then
            return;
        end
        
        GroupBuilder.db.profile.raidTable[playerName] = {
            ["class"] = class,
            ["role"] = role,
            ["gearscore"] = gearscore,
        };

        GroupBuilder:UpdateGUI();

        dialog:Hide();
    end)
    dialog:AddChild(addButton);

    return dialog;
end

local function ShowAddPlayerDialog()
    local dialog = CreateAddPlayerDialog();
    dialog:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget);
    end)
    dialog:SetWidth(350);
    dialog:SetHeight(275);
    dialog:SetLayout("List");
    dialog:Show();
    dialog:DoLayout();
end

local addPlayerButton = AceGUI:Create("Button");
addPlayerButton:SetText("Add Player");
addPlayerButton:SetCallback("OnClick", ShowAddPlayerDialog);

local function CreatePlayerWidget(playerName, playerData)
    local playerGroup = AceGUI:Create("InlineGroup");
    playerGroup:SetWidth(103);

    local playerNameLabel = AceGUI:Create("Label");
    local classColor = RAID_CLASS_COLORS[playerData.class:upper()].colorStr;
    local playerNameText = "|c" .. classColor .. playerName .. "|r";
    local classIcon = "|TInterface\\icons\\ClassIcon_" .. playerData.class:upper() .. ":20:20|t";

    playerNameLabel:SetText(classIcon .. " " .. playerNameText);
    playerNameLabel:SetWidth(80);

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

    local gearscoreEditBox = AceGUI:Create("EditBox");
    gearscoreEditBox:SetLabel("Gearscore");
    gearscoreEditBox:SetText(tostring(playerData.gearscore));
    gearscoreEditBox:SetWidth(80);
    gearscoreEditBox:SetCallback("OnEnterPressed", function(widget, event, text)
        playerData.gearscore = tonumber(text) or 0;
        GroupBuilder.UpdateGUI();
    end)

    local kickButton = AceGUI:Create("Button");
    kickButton:SetText("Kick");
    kickButton:SetWidth(80);
    kickButton:SetCallback("OnClick", function()
        StaticPopupDialogs["ARE_YOU_SURE_YOU_WANT_TO_KICK"].text = "Are you sure you want to kick " .. playerName .. " from the raid?";
        StaticPopupDialogs["ARE_YOU_SURE_YOU_WANT_TO_KICK"].OnAccept = function ()
            UninviteUnit(playerName);
            GroupBuilder.db.profile.raidTable[playerName] = nil;
            GroupBuilder.db.profile.inviteConstruction[playerName] = nil;
            
            GroupBuilder.UpdateGUI();
        end
        StaticPopup_Show("ARE_YOU_SURE_YOU_WANT_TO_KICK");
    end)

    playerGroup:AddChild(playerNameLabel);
    playerGroup:AddChild(roleDropdown);
    playerGroup:AddChild(gearscoreEditBox);
    playerGroup:AddChild(kickButton);

    return playerGroup;
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

local addPlayerButton = AceGUI:Create("Button");
addPlayerButton:SetText("Add Player");
addPlayerButton:SetCallback("OnClick", ShowAddPlayerDialog);

mainScrollFrame:AddChild(addPlayerButton);

GroupBuilder.GUIFrame:Hide();
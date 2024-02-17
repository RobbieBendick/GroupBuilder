local _, core = ...;
local LibDBIcon = LibStub("LibDBIcon-1.0");
core.Config = {};
local Config = core.Config;
local GBConfig;
local GB = core.GB;
local defaults = {
    profile = {
        maxHealers = 0,
        maxDPS = 0,
        maxTanks = 0,
        minGearscore = 0,
        maxRangedDPS = 0,
        maxMeleeDPS = 0,
        message = "",
        minimapCoords = {},
        isPaused = true,
        selectedRaid = "",
        selectedRole = "",
    }
}
function Config:Toggle()
    InterfaceOptionsFrame_OpenToCategory(GBConfig);
    InterfaceOptionsFrame_OpenToCategory(GBConfig);
end

function Config:CreateMenu()
    GBConfig = CreateFrame("Frame", "GroupBuilderConfig", UIParent);

    GBConfig.name = "GroupBuilder";

    GBConfig.title = GBConfig:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
    GBConfig.title:SetParent(GBConfig);
    GBConfig.title:SetPoint("TOPLEFT", 16, -16);
    GBConfig.title:SetText(GBConfig.name);

    local options = {
        name = "GroupBuilder",
        type = "group",
        args = {
            message = {
                order = 1,
                name = "Advertising Message",
                desc = "Advertising message for LFG",
                type = "input",
                width = "full",
                set = function(info, value) 
                    core.db.profile.message = value;
                end,
                get = function(info) 
                    return core.db.profile.message;
                end,
                validate = function(info, value)
                    return #value <= 255;
                end,
            },
            roleDropdown = {
                order = 2,
                type = "select",
                name = "Select Your Role",
                desc = "Select your role.",
                values = {
                    ["ranged_dps"] = "Ranged DPS",
                    ["melee_dps"] = "Melee DPS",
                    ["tank"] = "Tank",
                    ["healer"] = "Healer",
                },
                width = "full",
                set = function(info, value)
                    core.db.profile.selectedRole = value;
                    GB.raidTemplates[core.db.profile.selectedRaid]();
                end,
                get = function(info)
                    return core.db.profile.selectedRole;
                end,
            },
            raidDropdown = {
                order = 3,
                type = "select",
                name = "Select Raid Template",
                desc = "Select raid template to fill in the group requirements.",
                values = {
                    ["None"] = "None",
                    ["Icecrown Citadel 25"] = "Icecrown Citadel 25",
                    ["Icecrown Citadel 10"] = "Icecrown Citadel 10",

                },
                width = "full",
                set = function(info, value)
                    core.db.profile.selectedRaid = value;
                    if GB.raidTemplates[value] then
                        GB.raidTemplates[value]();
                    end
                end,
                get = function(info)
                    return core.db.profile.selectedRaid;
                end,
            },
            groupRequirements = {
                order = 4,
                type = "group",
                inline = true,
                name = "Group Requirements",
                args = {
                    tanks = {
                        order = 1,
                        name = "Tanks",
                        desc = "Number of tanks",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            core.db.profile.maxTanks = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.maxTanks);
                        end
                    }, 
                    maxHealers = {
                        order = 2,
                        name = "Healers",
                        desc = "Number of healers",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            core.db.profile.maxHealers = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.maxHealers);
                        end
                    },
                    maxDPS = {
                        order = 3,
                        name = "DPS",
                        desc = "Number of DPS",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            core.db.profile.maxDPS = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.maxDPS);
                        end
                    },
                    maxRangedDPS = {
                        order = 4,
                        name = "Max Ranged DPS",
                        desc = "Maximum number of ranged DPS",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            core.db.profile.maxRangedDPS = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.maxRangedDPS);
                        end
                    },
                    maxMeleeDPS = {
                        order = 5,
                        name = "Max Melee DPS",
                        desc = "Maximum number of melee DPS",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            core.db.profile.maxMeleeDPS = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.maxMeleeDPS);
                        end
                    },
                    gearscore = {
                        order = 6,
                        name = "Minimum Gearscore",
                        desc = "Minimum gearscore required to join the group.",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            core.db.profile.minGearscore = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.minGearscore);
                        end
                    }
                }
            },
            sendButton = {
                order = 7,
                type = "execute",
                name = function ()
                    if core.db.profile.isPaused then
                        return "Activate Auto Inviting";
                    else
                        return "Pause Auto inviting";
                    end
                end,
                desc = function ()
                    if core.db.profile.isPaused then
                        return "Activate auto inviting";
                    else
                        return "Pause auto inviting";
                    end
                end,
                func = function()
                   core.db.profile.isPaused = not core.db.profile.isPaused; 
                end,
                width = "full",
            },
        }
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("GroupBuilder", options);
    self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GroupBuilder", "GroupBuilder");

    GBConfig:Hide();
end

function Config:IsInLookingForGroup()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i)
        if channelName == "LookingForGroup" then
            return true;
        end
    end
    return false;
end

function Config:FindLFGChannelIndex()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i);
        if channelName == "LookingForGroup" then
            return id;
        end
    end
    return nil;
end

function Advertise()
    if not core.db.profile.message then 
        return print("Please enter an advertisement message.");
    end
    if Config:IsInLookingForGroup() then
        local lookingForGroupChannelID = Config:FindLFGChannelIndex();
        SendChatMessage(core.db.profile.message, "CHANNEL", nil, lookingForGroupChannelID);
    else
        ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "LookingForGroup");
        print("Advertisement failed because you're not in the LookingForGroup channel. Joining now...");
        C_Timer.After(8, function ()
            StaticPopup_Show("NOT_IN_LFG");
        end);
    end
end

function Config:CreateMinimapIcon()
    LibDBIcon:Register(core.addonName, {
        icon = "Interface\\GROUPFRAME\\UI-Group-LeaderIcon",
        OnClick = self.Toggle,
        OnTooltipShow = function(tt)
            tt:AddLine(core.addonName .. " |cff808080" .. GetAddOnMetadata(core.addonName, "Version"));
            tt:AddLine("|cffCCCCCCClick|r to open options");
            tt:AddLine("|cffCCCCCCDrag|r to move this button");
        end,
        text = core.addonName,
        iconCoords = {0.05, 0.85, 0.15, 0.95},
    });

    C_Timer.After(0.25, function ()
        if #core.db.profile.minimapCoords > 0 then
            LibDBIcon:GetMinimapButton(core.addonName):SetPoint(unpack(core.db.profile.minimapCoords));
        end
        LibDBIcon:GetMinimapButton(core.addonName):SetScript("OnDragStop", function (self)
            self:SetScript("OnUpdate", nil);
            self.isMouseDown = false;
            self.icon:UpdateCoord();
            self:UnlockHighlight();

            local point, relativeFrame, relativePoint, x, y = self:GetPoint();
            core.db.profile.minimapCoords = { point, relativeFrame:GetName(), relativePoint, x, y };
        end);
    end);
end

function Config:OnInitialize()
    -- initialize saved variables with defaults
    core.db = LibStub("AceDB-3.0"):New("GroupBuilderDB", defaults, true);
    StaticPopupDialogs["NOT_IN_LFG"] = {
        text = "You weren't previously in the LFG channel. Resend your advertisement?",
        button1 = "Send Advertisement",
        button2 = "Cancel",
        timeout = 120,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS,
        OnAccept = Advertise,
        OnCancel = function ()
            StaticPopup_Hide("NOT_IN_LFG");
        end
    };
    Config:CreateMinimapIcon();
    Config:CreateMenu();
end
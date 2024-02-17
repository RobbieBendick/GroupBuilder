local _, core = ...;
local LibDBIcon = LibStub("LibDBIcon-1.0");
core.Config = {};
local Config = core.Config;
local GBConfig;

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
        isPaused = true;
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
                    return value:len() <= 255;
                end,
            },
            group1 = {
                order = 2,
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

function Advertise()
    SendChatMessage(core.db.profile.message or "", "CHANNEL", nil, 2);
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
        text = GB.addonName,
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

    Config:CreateMinimapIcon();
    Config:CreateMenu();
end
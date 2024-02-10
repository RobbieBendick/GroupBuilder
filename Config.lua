local _, core = ...;
local LibDBIcon = LibStub("LibDBIcon-1.0");
core.Config = {};
local Config = core.Config;
local GBConfig;


local defaults = {
    profile = {
        healers = 0,
        dps = 0,
        tanks = 0,
        gearscore = 0,
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

local frame = CreateFrame("Frame");

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
                end
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
                            core.db.profile.tanks = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.tanks);
                        end
                    }, 
                    healers = {
                        order = 2,
                        name = "Healers",
                        desc = "Number of healers",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            core.db.profile.healers = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.healers);
                        end
                    },
                    dps = {
                        order = 3,
                        name = "DPS",
                        desc = "Number of DPS",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            core.db.profile.dps = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.dps);
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
                            core.db.profile.gearscore = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(core.db.profile.gearscore);
                        end
                    }
                }
            },
            sendButton = {
                order = 7,
                type = "execute",
                name = function ()
                    if core.db.profile.isPaused then
                        return "Start Group";
                    else
                        return "Pause";
                    end
                end,
                desc = "Pause the auto inviting.",
                func = function()
                   core.db.profile.isPaused = not core.db.profile.isPaused; 
                end,
                width = "full",
            },
        }
    }   
    

    LibStub("AceConfig-3.0"):RegisterOptionsTable("GroupBuilder", options)
    self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GroupBuilder", "GroupBuilder")

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
            core.db.profile.minimapCoords = { unpack({point, relativeFrame:GetName(), relativePoint, x, y}) };
        end);
    end);
end

function Config:OnInitialize()
    if not GroupBuilderDB then
        GroupBuilderDB = {};
    end

    -- initialize saved variables with defaults
    core.db = LibStub("AceDB-3.0"):New("GroupBuilderDB", defaults, true)

    Config:CreateMinimapIcon();
    Config:CreateMenu();

end
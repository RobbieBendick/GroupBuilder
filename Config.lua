local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");
local LibDBIcon = LibStub("LibDBIcon-1.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
GroupBuilder.Config = {};
local Config = GroupBuilder.Config;
local GBConfig;
local _, playerClass = UnitClass("player");
local raidInstanceDropdownValues = {
    ["Icecrown Citadel 25"] = "Icecrown Citadel 25",
    ["Icecrown Citadel 10"] = "Icecrown Citadel 10",
    ["Ruby Sanctum 25"] = "Ruby Sanctum 25",
    ["Ruby Sanctum 10"] = "Ruby Sanctum 10",
    ["Vault Of Archavon 25"] = "Vault Of Archavon 25",
    ["Vault Of Archavon 10"] = "Vault Of Archavon 10",
    ["Reset"] = "Reset",
};

function GroupBuilder:Toggle(button)
    if button == "RightButton" then
        InterfaceOptionsFrame_OpenToCategory(GBConfig);
        InterfaceOptionsFrame_OpenToCategory(GBConfig);
    elseif button == "LeftButton" then
        if GroupBuilder.GUIFrame:IsShown() then
            GroupBuilder.GUIFrame:Hide()
        else
            GroupBuilder.GUIFrame:Show()
        end
    end
end

function GroupBuilder:GetKeyByValue(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k;
        end
    end
    return nil;
end

function GroupBuilder:FindClassCount(class)
    if not class then return end
    local count = 0;
    for characterName, characterData in pairs(GroupBuilder.db.profile.raidTable) do
        if characterData.class == class then
            count = count + 1;
        end
    end
    for characterName, characterData in pairs(GroupBuilder.db.profile.invitedTable) do
        if characterData.class == class then
            count = count + 1;
        end
    end
    return count;
end


function GroupBuilder:CountPlayersByRole(table, role)
    local count = 0;
    if role == "dps" then
        for _, playerData in pairs(GroupBuilder.db.profile.raidTable) do
            if playerData.role == "melee_dps" or playerData.role == "ranged_dps" then
                count = count + 1;
            end
        end
    else
        for _, playerData in pairs(GroupBuilder.db.profile.raidTable) do
            if playerData.role == role then
                count = count + 1;
            end
        end
    end
    return count;
end

function GroupBuilder:CountPlayersByRoleAndClass(role, class)
    if not role or not class then return end
    local count = 0;
    for characterName, characterData in pairs(GroupBuilder.db.profile.raidTable) do
        if characterData.role == role and characterData.class == class then
            count = count + 1;
        end
    end
    for characterName, characterData in pairs(GroupBuilder.db.profile.invitedTable) do
        if characterData.role == role and characterData.class == class then
            count = count + 1;
        end
    end
    return count;
end

function GroupBuilder:IsClassNeededForMinimum(class)
    if not class then return end
    local classMinimum = GroupBuilder.db.profile[class.."Minimum"];
    if classMinimum ~= nil and tonumber(classMinimum) ~= 0 and classMinimum ~= "" then
        if GroupBuilder:FindClassCount(class) < tonumber(classMinimum) then
            return true;
        end
    else
        return false;
    end
end

function GroupBuilder:GenerateClassTabs()
    local classTabs = {}

    for i, className in ipairs(GroupBuilder.classes) do
        classTabs[className .. "Tab"] = {
            order = i,
            type = "group",
            name = className:sub(1, 1) .. className:sub(2):lower(),
            args = {
                [className .. "Maximum"] = {
                    order = 1,
                    type = "input",
                    name = "Maximum number of " .. className:sub(1, 1) .. className:sub(2):lower() .. "s",
                    desc = "This option is to select the minmum number of " .. className:sub(1, 1) .. className:sub(2):lower() .. "s allowed in the raid.\n(If maximum is 0, the group won't fill that class)",
                    width = "normal",
                    get = function(info)
                        local classMax = className .. "Maximum";
                        return tostring(GroupBuilder.db.profile[classMax] or "");
                    end,
                    set = function(info, value)
                        local classMax = className .. "Maximum";
                        GroupBuilder.db.profile[classMax] = value;
                    end,
                },
                [className .. "Minimum"] = {
                    order = 2,
                    type = "input",
                    name = "Minimum number of " .. className:sub(1, 1) .. className:sub(2):lower() .. "s",
                    desc = "This option is to select the minmum number of " .. className:sub(1, 1) .. className:sub(2):lower() .. "s allowed in the raid.\n(If minimum is 3, the group won't fill until it reaches 3 Rogues)",
                    width = "normal",
                    get = function(info)
                        local classMin = className .. "Minimum";
                        return tostring(GroupBuilder.db.profile[classMin] or "");
                    end,
                    set = function(info, value)
                        local classMin = className .. "Minimum";
                        GroupBuilder.db.profile[classMin] = value;
                    end,
                },
            },
        }
    end
    return classTabs;
end
function GroupBuilder:GenerateRoleTabs()
    local roleTabs = {};
    local i = 1;
    for roleName, keyWordList in pairs(GroupBuilder.roles) do
        roleTabs[roleName .. "Tab"] = {
            order = i,
            type = "group",
            name = roleName:gsub("_", " "),
            args = {}
        }
        for _, classList in pairs(GroupBuilder.roleClasses) do
            for i, class in ipairs(classList) do
                if GroupBuilder:Contains(GroupBuilder.roleClasses[roleName], class) then
                    roleTabs[roleName .. "Tab"].args[roleName .. class .. "Tab"] = {
                        order = i,
                        type = "group",
                        name = class:sub(1,1) .. class:sub(2):lower(),
                        desc = class, 
                        args = {
                            [roleName .. class .. "Maxmimum"] = {
                                order = 1,
                                type = "input",
                                name = "Maximum " .. roleName:gsub("_", " ") .. " " .. class:sub(1,1) .. class:sub(2):lower() .."s",
                                desc = "Maximum " .. roleName:gsub("_", " ") .. " " .. class:sub(1,1) .. class:sub(2):lower() .."s", 
                                width = "normal",
                                get = function (info)
                                    return tostring(GroupBuilder.db.profile[roleName .. class .. "Maximum"] or "");
                                end,
                                set = function (info, value)
                                    GroupBuilder.db.profile[roleName .. class .. "Maximum"] = value;
                                end,
                            }
                        }
                    }
                end
            end
        end
    end
    return roleTabs;
end

function GroupBuilder:CreateMenu()
    GBConfig = CreateFrame("Frame", "GroupBuilderConfig", UIParent);

    GBConfig.name = "GroupBuilder";

    GBConfig.title = GBConfig:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
    GBConfig.title:SetParent(GBConfig);
    GBConfig.title:SetPoint("TOPLEFT", 16, -16);
    GBConfig.title:SetText(GBConfig.name);

    local classTabs = GroupBuilder:GenerateClassTabs();
    local roleTabs = GroupBuilder:GenerateRoleTabs();

    local advertisementMessageOptions = {
        name = "Advertising Message",
        type = "group",
        args = {
            message = {
                order = 1,
                name = "Advertising Message",
                desc = "Advertising message for LFG",
                type = "input",
                width = "full",
                set = function(info, value) 
                    GroupBuilder.db.profile.message = value;
                end,
                get = function(info) 
                    return GroupBuilder.db.profile.message;
                end,
                validate = function(info, value)
                    return #value <= 255;
                end,
                disabled = function (info)
                    return GroupBuilder.db.profile.constructMessageIsActive;
                end
            },
            enableConstructAdvertisementMessage = {
                order = 2,
                type = "toggle",
                name = "Construct An Advertising Message",
                desc = "Enable or disable current settings to construct an advertising message",
                width = "full",
                set = function(info, value)
                    GroupBuilder.db.profile.constructMessageIsActive = not GroupBuilder.db.profile.constructMessageIsActive;
                end,
                get = function(info)
                    return GroupBuilder.db.profile.constructMessageIsActive;
                end,
            },
            raidTypeGroup = {
                order = 3,
                type = "group",
                inline = true,
                name = "Raid Options",
                args = {
                    raidDropdown = {
                        order = 1,
                        type = "select",
                        name = "Raid Instance",
                        desc = "Select the raid instance you want to advertise for.",
                        values = GroupBuilder.raidInstanceDropdownAcronyms,
                        width = "normal",
                        set = function (info, value)
                            GroupBuilder.db.profile.selectedAdvertisementRaid = value;
                        end,
                        get = function (info)
                            return GroupBuilder.db.profile.selectedAdvertisementRaid;
                        end,
                        disabled = function(info)
                            return not GroupBuilder.db.profile.constructMessageIsActive;
                        end,
                    },
                    raidTypeDropdown = {
                        order = 2,
                        type = "select",
                        name = "Raid Type",
                        desc = "Select the raid type.",
                        values = {
                            ["SR"] = "SR",
                            ["SR (MS/OS)"] = "SR (MS/OS)",
                            ["MS/OS"] = "MS/OS",
                            ["GDKP"] = "GDKP",
                        },
                        width = "normal",
                        set = function(info, value)
                            GroupBuilder.db.profile.selectedRaidType = value;
                        end,
                        get = function(info)
                            return GroupBuilder.db.profile.selectedRaidType;
                        end,
                        disabled = function(info)
                            return not GroupBuilder.db.profile.constructMessageIsActive;
                        end,
                    },
                    secondaryRaidTypeDropdownSR = {
                        order = 3,
                        type = "select",
                        name = "Amount Of SR's",
                        desc = "The amount of SR's you want your SR raid to have.",
                        values = {
                            ["2x"] = "2x",
                            ["3x"] = "3x",
                            ["4x"] = "4x",
                        },
                        width = "normal",
                        set = function(info, value)
                            GroupBuilder.db.profile.selectedSRRaidInfo = value;
                        end,
                        get = function(info)
                            return GroupBuilder.db.profile.selectedSRRaidInfo;
                        end,
                        disabled = function(info)
                            return not GroupBuilder.db.profile.constructMessageIsActive;
                        end,
                        hidden = function(info)
                            return GroupBuilder.db.profile.selectedRaidType ~= "SR" and GroupBuilder.db.profile.selectedRaidType ~= "SR (MS/OS)";
                        end
                    },
                    secondaryRaidTypeDropdownGDKP = {
                        order = 3,
                        type = "select",
                        name = "Amount For Min/Max Bid",
                        desc = "Select the min and max bid amount you want for your GDKP.",
                        values = {
                            ["2kg/6kg"] = "2kg/6kg",
                            ["3kg/7kg"] = "3kg/7kg",
                            ["4kg/8kg"] = "4kg/8kg",
                        },
                        width = "normal",
                        set = function(info, value)
                            GroupBuilder.db.profile.selectedGDKPRaidInfo = value;
                        end,
                        get = function(info)
                            return GroupBuilder.db.profile.selectedGDKPRaidInfo;
                        end,
                        disabled = function(info)
                            return not GroupBuilder.db.profile.constructMessageIsActive;
                        end,
                        hidden = function(info)
                            return GroupBuilder.db.profile.selectedRaidType ~= "GDKP";
                        end
                    },
                    heroicBossCount = {
                        order = 4,
                        type = "input",
                        name = "Amount Of Heroic Bosses",
                        desc = "Select the amount of heroic bosses you expect your raid to kill.",
                        set = function(info, value)
                            GroupBuilder.db.profile.advertisementHeroicBossCount = value;
                        end,
                        get = function(info)
                            return GroupBuilder.db.profile.advertisementHeroicBossCount;
                        end,
                        disabled = function(info)
                            return not GroupBuilder.db.profile.constructMessageIsActive;
                        end,
                    }
                }
            },
            advertisingGroupSize = {
                order = 6,
                type = "group",
                inline = true,
                name = "Add Group Size To Message",
                args = {
                    advertisingMinGroupSize = {
                        order = 1,
                        type = "input",
                        name = "At Least",
                        desc = "Number of players required in the group before adding the group size to the advertisement message. (0 or empty to disable)",
                        width = "normal",
                        disabled = function(info)
                            return not GroupBuilder.db.profile.constructMessageIsActive;
                        end,
                        set = function(info, value)
                            GroupBuilder.db.profile.minPlayersForAdvertisingCount = tonumber(value) or 26;
                        end,
                        get = function(info)
                            return tostring(GroupBuilder.db.profile.minPlayersForAdvertisingCount or "");
                        end,
                    },
                    advertisingGroupSizeMax = {
                        order = 2,
                        type = "select",
                        values = {
                            ["10"] = 10,
                            ["25"] = 25
                        },
                        name = "Out Of",
                        desc = "Total number of players expected in your raid (10/25)",
                        width = "normal",
                        disabled = function(info)
                            return not GroupBuilder.db.profile.constructMessageIsActive;
                        end,
                        set = function(info, value)
                            GroupBuilder.db.profile.outOfMaxPlayers = tonumber(value) or 0;
                        end,
                        get = function(info)
                            return tostring(GroupBuilder.db.profile.outOfMaxPlayers or "");
                        end,
                    },
                },
            },
        }
    };

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
                    GroupBuilder.db.profile.message = value;
                end,
                get = function(info) 
                    return GroupBuilder.db.profile.message;
                end,
                validate = function(info, value)
                    return #value <= 255;
                end,
                disabled = function (info)
                    return GroupBuilder.db.profile.constructMessageIsActive;
                end
            },
            roleAndRaidGroup = {
                order = 2,
                type = "group",
                inline = true,
                name = "Role and Raid Template",
                args = {
                    roleDropdown = {
                        order = 1,
                        type = "select",
                        name = "Select Your Role",
                        desc = "Select your role.",
                        values = {
                            ["ranged_dps"] = "Ranged DPS",
                            ["melee_dps"] = "Melee DPS",
                            ["tank"] = "Tank",
                            ["healer"] = "Healer",
                        },
                        width = "normal",
                        set = function(info, value)
                            GroupBuilder.db.profile.selectedRole = value;
                            GroupBuilder.raidTemplates[GroupBuilder.db.profile.selectedRaidTemplate]();
                        end,
                        get = function(info)
                            return GroupBuilder.db.profile.selectedRole;
                        end,
                    },
                    raidDropdown = {
                        order = 2,
                        type = "select",
                        name = "Select Raid Template",
                        desc = "Select raid template to fill in the group requirements.",
                        values = raidInstanceDropdownValues,
                        width = "normal",
                        set = function(info, value)
                            GroupBuilder.db.profile.selectedRaidTemplate = value;
                            if GroupBuilder.raidTemplates[value] then
                                GroupBuilder.raidTemplates[value]();
                            end
                        end,
                        get = function(info)
                            return GroupBuilder.db.profile.selectedRaidTemplate;
                        end,
                    },
                },
            },
            groupRequirements = {
                order = 5,
                type = "group",
                inline = true,
                name = "Group Requirements",
                args = {
                    maxTotalPlayers = {
                        order = 1,
                        name = "Total Players",
                        desc = "Total amount of players expected to be in your raid.",
                        type = "select",
                        width = "normal",
                        values = {
                            ["10"] = 10,
                            ["25"] = 25
                        },
                        set = function(info, value)
                            GroupBuilder.db.profile.maxTotalPlayers = tonumber(value);
                        end,
                        get = function(info)
                            return tostring(GroupBuilder.db.profile.maxTotalPlayers);
                        end
                    },
                    tanks = {
                        order = 2,
                        name = "Tanks",
                        desc = "Number of tanks",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            GroupBuilder.db.profile.maxTanks = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(GroupBuilder.db.profile.maxTanks or "");
                        end
                    }, 
                    maxHealers = {
                        order = 3,
                        name = "Healers",
                        desc = "Number of healers",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            GroupBuilder.db.profile.maxHealers = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(GroupBuilder.db.profile.maxHealers or "");
                        end
                    },
                    maxDPS = {
                        order = 4,
                        name = "DPS",
                        desc = "Number of DPS",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            GroupBuilder.db.profile.maxDPS = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(GroupBuilder.db.profile.maxDPS or "");
                        end
                    },
                    maxRangedDPS = {
                        order = 5,
                        name = "Max Ranged DPS",
                        desc = "Maximum number of ranged DPS",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            GroupBuilder.db.profile.maxRangedDPS = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(GroupBuilder.db.profile.maxRangedDPS or "");
                        end
                    },
                    maxMeleeDPS = {
                        order = 6,
                        name = "Max Melee DPS",
                        desc = "Maximum number of melee DPS",
                        type = "input",
                        width = "half",
                        set = function(info, value) 
                            GroupBuilder.db.profile.maxMeleeDPS = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(GroupBuilder.db.profile.maxMeleeDPS or "");
                        end
                    },
                    gearscore = {
                        order = 7,
                        name = "Minimum Gearscore",
                        desc = "Minimum gearscore required to join the group.",
                        type = "input",
                        width = "normal",
                        set = function(info, value) 
                            GroupBuilder.db.profile.minGearscore = tonumber(value);
                        end,
                        get = function(info) 
                            return tostring(GroupBuilder.db.profile.minGearscore or "");
                        end
                    }
                },
            },
            classesTabGroup = {
                order = 4,
                type = "group",
                inline = false,
                descStyle = "inline",
                childGroups = "tab",
                name = "Class",
                args = classTabs,
            },
            rolesAndClassesTabGroup = {
                order = 5,
                type = "group",
                inline = false,
                descStyle = "inline",
                childGroups = "tab",
                name = "Role & Class",
                args = roleTabs,
            },

            activateButton = {
                order = 7,
                type = "execute",
                name = function ()
                    if GroupBuilder.db.profile.isPaused then
                        return "Activate Auto Inviting";
                    else
                        return "Pause Auto inviting";
                    end
                end,
                desc = function ()
                    if GroupBuilder.db.profile.isPaused then
                        return "Activate auto inviting";
                    else
                        return "Pause auto inviting";
                    end
                end,
                func = function()
                   GroupBuilder.db.profile.isPaused = not GroupBuilder.db.profile.isPaused; 
                end,
                width = "full",
            },
        }
    }

    -- register options table for the main "GroupBuilder" addon
    LibStub("AceConfig-3.0"):RegisterOptionsTable("GroupBuilder", options);

    -- register options table for the "GroupBuilder_AdvertisingMessage" subcategory
    LibStub("AceConfig-3.0"):RegisterOptionsTable("GroupBuilder_AdvertisingMessage", advertisementMessageOptions);

    -- add addon to the Blizzard options panel
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GroupBuilder", "GroupBuilder");

    -- Add the "GroupBuilder_AdvertisingMessage" subcategory under the "Advertising Message" category
    self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GroupBuilder_AdvertisingMessage", "Advertising Message", "GroupBuilder");
    GBConfig:Hide();
end

function GroupBuilder:IsInTrade()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i)
        if channelName then
            if channelName:find("Trade") then
                return true;
            end
        end
    end
    return false;
end

function GroupBuilder:IsInLookingForGroup()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i)
        if channelName == "LookingForGroup" then
            return true;
        end
    end
    return false;
end

function GroupBuilder:FindLFGChannelIndex()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i);
        if channelName == "LookingForGroup" then
            return id;
        end
    end
    return nil;
end

function GroupBuilder:FindTradeChannelIndex()
    for i = 1, GetNumDisplayChannels() do
        local id, channelName = GetChannelName(i);
        if channelName then
            if channelName:find("Trade") then
                return id;
            end
        end
    end
    return nil;
end

function GroupBuilder:FindTotalMinimumOfMissingClasses()
    local count = 0;
    for i, className in ipairs(GroupBuilder.classes) do
        local minimumOfClass = GroupBuilder.db.profile[className.."Minimum"];
        if minimumOfClass ~= nil and minimumOfClass ~= "" then
            count = count + ( tonumber(minimumOfClass) - GroupBuilder:FindClassCount(className) );
        end
    end
    return count;
end


function GroupBuilder:CreateAdvertisementMessage()
    if not GroupBuilder.db.profile.selectedAdvertisementRaid then 
        return GroupBuilder:Print("Please select an advertisement raid in the Advertising Message options.");
    end
    if not GroupBuilder.db.profile.selectedRaidType then 
        return GroupBuilder:Print("Please select a raid type in the Advertising Message options.");
    end
    local raidName = GroupBuilder.db.profile.selectedAdvertisementRaid;
    local minPlayersForAdvertisingCountIsValid = GroupBuilder.db.profile.minPlayersForAdvertisingCount or tonumber(GroupBuilder.db.profile.minPlayersForAdvertisingCount) ~= 0;
    local messageToSend = "LFM " .. raidName .. "m";

    -- ICC 10
    if GroupBuilder.db.profile.selectedRaidType then
        messageToSend = messageToSend .. " " .. GroupBuilder.db.profile.selectedRaidType;
    end

    -- (10/25)
    if GroupBuilder.db.profile.minPlayersForAdvertisingCount and minPlayersForAdvertisingCountIsValid and GetNumGroupMembers() >= tonumber(GroupBuilder.db.profile.minPlayersForAdvertisingCount) then
        messageToSend = messageToSend .. " (" .. GetNumGroupMembers() .. "/" .. GroupBuilder.db.profile.outOfMaxPlayers .. ")";
    end

    -- GDKP or SR etc
    if GroupBuilder.db.profile.selectedGDKPRaidInfo and GroupBuilder.db.profile.selectedRaidType == "GDKP" then
        messageToSend = messageToSend .. " " .. GroupBuilder.db.profile.selectedGDKPRaidInfo;
    elseif GroupBuilder.db.profile.selectedSRRaidInfo and GroupBuilder.db.profile.selectedRaidType == "SR" or GroupBuilder.db.profile.selectedRaidType == "SR (MS/OS)" then
        messageToSend = messageToSend .. " " .. GroupBuilder.db.profile.selectedSRRaidInfo;
    end

    -- find most missing role
    if GroupBuilder.db.profile.maxTotalPlayers and GroupBuilder.db.profile.maxTotalPlayers ~= "" and tonumber(GroupBuilder.db.profile.maxTotalPlayers) == 10 then
        if GetNumGroupMembers() >= 7 then
            local mostMissingRole, secondMostMissingRole = GroupBuilder:FindMostNeededRoles();
            if mostMissingRole then
                messageToSend = messageToSend .. " NEED MORE " .. mostMissingRole:upper() .. "S";
            end
        end
    elseif GroupBuilder.db.profile.maxTotalPlayers and GroupBuilder.db.profile.maxTotalPlayers ~= "" and tonumber(GroupBuilder.db.profile.maxTotalPlayers) == 25 then
        if GetNumGroupMembers() >= 16 then
            local mostMissingRole, secondMostMissingRole = GroupBuilder:FindMostNeededRoles();
            if mostMissingRole then
                messageToSend = messageToSend .. " NEED MORE " .. mostMissingRole:upper() .. "S";
            end
        end
    end


    if GroupBuilder.db.profile.advertisementHeroicBossCount then
        if not GroupBuilder.db.profile.selectedAdvertisementRaid then
            GroupBuilder:Print("Please select a raid instance in the GroupBuilder Advertising Message settings.");
        else
            messageToSend = messageToSend .. " (" .. GroupBuilder.db.profile.advertisementHeroicBossCount .. " HC)" ;
        end
    end 


    SendChatMessage(messageToSend, "WHISPER", nil, "Robertdogert");
end

function AdvertiseLFG()
    if GroupBuilder.db.profile.constructMessageIsActive then
        return GroupBuilder:CreateAdvertisementMessage();
    end
    if GroupBuilder.db.profile.message == "" then
        return print("Please enter an advertisement message.");
    end
    if GroupBuilder:IsInLookingForGroup() then
        local lookingForGroupChannelID = GroupBuilder:FindLFGChannelIndex();
        SendChatMessage(GroupBuilder.db.profile.message, "CHANNEL", nil, lookingForGroupChannelID);
    else
        ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "LookingForGroup");
        print("Advertisement failed because you're not in the LookingForGroup channel.");
        print("Trying to join LookingForGroup...");
        print("Please type /join LookingForGroup and resend the advertisement.");
        C_Timer.After(7, function ()
            StaticPopup_Show("NOT_IN_LFG");
        end);
    end
end

function AdvertiseTrade()
    if GroupBuilder.db.profile.constructMessageIsActive then
        return GroupBuilder:CreateAdvertisementMessage();
    end
    if not GroupBuilder.db.profile.message then 
        return print("Please enter an advertisement message.");
    end

    if GroupBuilder:IsInTrade() then
        local tradeChannelID = GroupBuilder:FindTradeChannelIndex();
        SendChatMessage(GroupBuilder.db.profile.message, "CHANNEL", nil, tradeChannelID);
    else
        print("Advertisement failed because you're not in the Trade channel.");
        print("Please type /join trade and resend the advertisement.");
        C_Timer.After(7, function ()
            StaticPopup_Show("NOT_IN_TRADE");
        end);
    end
end

function GroupBuilder:CreateMinimapIcon()
    LibDBIcon:Register(GroupBuilder.addonName, {
        icon = "Interface\\GROUPFRAME\\UI-Group-LeaderIcon",
        OnClick = self.Toggle,
        OnTooltipShow = function(tt)
            tt:AddLine(self.addonName .. " |cff808080" .. GetAddOnMetadata(self.addonName, "Version"));
            tt:AddLine("|cffCCCCCCClick|r to open the Raid Representation");
            tt:AddLine("|cffCCCCCCRight Click|r to open options");
            tt:AddLine("|cffCCCCCCDrag|r to move this button");
        end,
        text = GroupBuilder.addonName,
        iconCoords = {0.05, 0.85, 0.15, 0.95},
    });

    C_Timer.After(0.25, function ()
        if self.db.profile.minimapCoords and #self.db.profile.minimapCoords > 0 then
            LibDBIcon:GetMinimapButton(GroupBuilder.addonName):SetPoint(unpack(self.db.profile.minimapCoords));
        end
        LibDBIcon:GetMinimapButton(self.addonName):SetScript("OnDragStop", function (self)
            self:SetScript("OnUpdate", nil);
            self.isMouseDown = false;
            self.icon:UpdateCoord();
            self:UnlockHighlight();

            local point, relativeFrame, relativePoint, x, y = self:GetPoint();
            GroupBuilder.db.profile.minimapCoords = { point, relativeFrame:GetName(), relativePoint, x, y };
        end);
    end);
end

function GroupBuilder:LoadStaticPopups()
    StaticPopupDialogs["NOT_IN_LFG"] = {
        text = "You weren't previously in the LFG channel. Resend your advertisement?",
        button1 = "Send Advertisement",
        button2 = "Cancel",
        timeout = 120,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS,
        OnAccept = AdvertiseLFG,
        OnCancel = function ()
            StaticPopup_Hide("NOT_IN_LFG");
        end
    };
    StaticPopupDialogs["NOT_IN_TRADE"] = {
        text = "You're not in the Trade channel. Please type /join trade and send the advertisement again.",
        button1 = "Send Advertisement",
        button2 = "Cancel",
        timeout = 120,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS,
        OnAccept = AdvertiseTrade,
        OnCancel = function ()
            StaticPopup_Hide("NOT_IN_TRADE");
        end
    };
end



local defaults = {
    profile = {
        maxHealers = "",
        maxDPS = "",
        maxTanks = "",
        maxRangedDPS = "",
        maxMeleeDPS = "",
        message = "",
        minGearscore = "",
        minimapCoords = {},
        raidTable = {},
        raidPlayersThatLeftGroup = {},
        invitedTable = {},
        inviteConstruction = {},
        isPaused = true,
        selectedRaidTemplate = "",
        selectedRole = "",
        selectedRaidType = "",
        selectedSRRaidInfo = "",
        selectedGDKPRaidInfo = "",
        selectedAdvertisementRaid = "",
        minPlayersForAdvertisingCount = 15,
        constructMessageIsActive = false,
        outOfMaxPlayers = "",
    }
};

function GroupBuilder:OnInitialize()
    -- initialize saved variables with defaults
    GroupBuilder.db = LibStub("AceDB-3.0"):New("GroupBuilderDB", defaults, true);

    C_Timer.After(1, function ()
        if GetNumGroupMembers() == 0 then
            GroupBuilder.db.profile.raidTable = {};
            GroupBuilder.db.profile.invitedTable = {};
            GroupBuilder.db.profile.inviteConstruction = {};
            GroupBuilder.db.profile.raidPlayersThatLeftGroup = {};
        end 
    end);
    
    -- handle events
    self:RegisterEvent("CHAT_MSG_WHISPER", "HandleWhispers");
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "HandleGroupRosterUpdate");
    self:RegisterEvent("CHAT_MSG_SYSTEM", "HandleErrorMessages");

    -- load config stuff
    GroupBuilder:LoadStaticPopups();
    GroupBuilder:CreateMinimapIcon();
    GroupBuilder:CreateMenu();
end

local GroupBuilder = LibStub("AceAddon-3.0"):GetAddon("GroupBuilder");

local Config = GroupBuilder.Config;

function GroupBuilder:OnInitialize()
    -- initialize saved variables with defaults
    GroupBuilder.db = LibStub("AceDB-3.0"):New("GroupBuilderDB", defaults, true);
    
    -- handle events
    self:RegisterEvent("CHAT_MSG_WHISPER", "HandleWhispers");
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "HandleGroupRosterUpdate");
    self:RegisterEvent("CHAT_MSG_SYSTEM", "HandleErrorMessages");

    -- load config stuff
    Config:LoadStaticPopups();
    Config:CreateMinimapIcon();
    Config:CreateMenu();
end
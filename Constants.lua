local _, core = ...;
core.addonName = "GroupBuilder";
core.raidTable = {};
core.invitedTable = {};
-- both tables are going to look like this: table = {
   -- ["CharacterName"] = role
-- }
-- when invited, store into "invited" table.
-- when a player joins group, cross reference the invited table and see what role they have
-- if two minutes pass without the player joining the group, remove from table

core.eventHandlerTable = {
	["PLAYER_LOGIN"] = function(self) core.Config:OnInitialize(self) end,
    ["CHAT_MSG_WHISPER"] = function(self, ...) core.GB.HandleWhispers(self, ...) end,
    ["GROUP_ROSTER_UPDATE"] = function (self, ...)
        for i = 1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(i);
            local playerRole = core.invitedTable[name];
            if playerRole and not core.raidTable[name] then
                -- add to raid table
                core.raidTable[name] = core.invitedTable[name];
                if core.invitedTable[name] then
                    -- remove from inv table
                    core.invitedTable[name] = nil; 
                end
            end
        end
    end
};


core.roles = {
    ["healer"] = {
        "resto",
        "rsham",
        "rdruid",
        "rdru",
        "disc",
        "hpal",
        "holy pal",
        "holy paladin",
        "pal",
        "hpal"
    },
    ["tank"] = {
        "prot pal",
        "prot",
        "protection",
        "tank",
        "frost dk",
        "blood dk",
        "frost deathknight",
        "blood deathknight",
    },
    ["melee_dps"] = {
        "rogue",
        "rog",
        "feral",
        "enh",
        "enhancement",
        "enhance",
        "fury warr",
        "dps warr",
        "warr dps",
        "fwar",
    },
    ["ranged_dps"] = {
        "hunter",
        "hunt",
        "mage",
        "ele shaman",
        "elesham",
        "ele sham",
        "warlock",
        "lock",
        "spriest",
        "shadow"
    },
}
-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
---@meta

-- This table defines the argument structure of known WoW events.
-- AIDDEV uses this to validate handler signatures and generate type annotations.

local M = {}

-- Generic events
M["PLAYER_LOGIN"] = {
    args = {},
    kind = "generic",
}

M["PLAYER_ENTERING_WORLD"] = {
    args = { "isLogin", "isReload" },
    kind = "generic",
}

-- Unit events
M["UNIT_HEALTH"] = {
    args = { "unit" },
    kind = "unit",
}

M["UNIT_POWER_UPDATE"] = {
    args = { "unit", "powerType" },
    kind = "unit",
}

M["UNIT_AURA"] = {
    args = { "unit", "info" },
    kind = "unit",
}

M["UNIT_TARGET"] = {
    args = { "unit" },
    kind = "unit",
}

-- Combat log
M["COMBAT_LOG_EVENT_UNFILTERED"] = {
    args = {
        "timestamp",
        "subEvent",
        "hideCaster",
        "sourceGUID",
        "sourceName",
        "sourceFlags",
        "sourceRaidFlags",
        "destGUID",
        "destName",
        "destFlags",
        "destRaidFlags",
        -- event‑specific data follows
    },
    kind = "cleu",
}

-- Chat events
M["CHAT_MSG_SAY"] = {
    args = { "msg", "sender", "language", "channel", "target" },
    kind = "chat",
}

M["CHAT_MSG_RAID_WARNING"] = {
    args = { "msg", "sender", "language", "channel", "target" },
    kind = "chat",
}

M["CHAT_MSG_RAID_BOSS_EMOTE"] = {
    args = { "msg", "sender", "language", "channel", "target" },
    kind = "chat",
}

-- Extend this table as needed for Ascension, Classic, Retail, or custom addons.

return M

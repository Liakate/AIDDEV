-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
---@meta

-- Human-readable reference metadata for UI tooltips.

local References = {
    lua51 = {
        id = "lua51",
        kind = "hard",
        label = "Lua 5.1 language rules",
        summary = "Based on the Lua 5.1 reference manual and runtime semantics.",
    },

    wow_exec = {
        id = "wow_exec",
        kind = "hard",
        label = "WoW addon load & event model",
        summary = "Based on WoW's event-driven addon loading and execution model.",
    },

    wow_ui = {
        id = "wow_ui",
        kind = "hard",
        label = "WoW UI execution rules",
        summary = "Covers protected functions, combat lockdown, and UI script behavior.",
    },

    blizz_patterns = {
        id = "blizz_patterns",
        kind = "soft",
        label = "Common Blizzard UI patterns",
        summary = "Observed FrameXML idioms; common but not guaranteed.",
    },

    community_patterns = {
        id = "community_patterns",
        kind = "soft",
        label = "Common community addon patterns",
        summary = "Widely used idioms such as Ace3; not required by WoW.",
    },
}

return References

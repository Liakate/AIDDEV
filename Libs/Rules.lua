-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
---@meta

-- These are the foundational rules AIDDEV must follow when explaining diagnostics.
-- They ensure every explanation is grounded, defensible, and traceable.

local Rules = {}

-- Hard references: authoritative, mechanical, guaranteed by Lua/WoW.
Rules.HARD_REFERENCES = {
    lua51 = true,       -- Lua 5.1 language semantics
    wow_exec = true,    -- WoW addon load & event model
    wow_ui = true,      -- WoW UI protected/combat rules
}

-- Soft references: common patterns, not guaranteed.
Rules.SOFT_REFERENCES = {
    blizz_patterns = true,      -- Blizzard FrameXML idioms
    community_patterns = true,  -- Ace3 / community idioms
}

-- Forbidden claims: AIDDEV must never imply these.
Rules.FORBIDDEN_CLAIMS = {
    "static analysis",
    "understands author intent",
    "best practices enforcement",
    "security auditing",
    "correct implementation",
}

function Rules.is_hard_reference(ref)
    return Rules.HARD_REFERENCES[ref] == true
end

function Rules.is_soft_reference(ref)
    return Rules.SOFT_REFERENCES[ref] == true
end

function Rules.validate_reference_id(ref)
    if not ref then
        return false, "missing reference"
    end
    if Rules.HARD_REFERENCES[ref] or Rules.SOFT_REFERENCES[ref] then
        return true
    end
    return false, "unknown reference '" .. tostring(ref) .. "'"
end

function Rules.contains_forbidden_claim(text)
    if not text then return false end
    text = text:lower()
    for _, phrase in ipairs(Rules.FORBIDDEN_CLAIMS) do
        if text:find(phrase, 1, true) then
            return true
        end
    end
    return false
end

return Rules

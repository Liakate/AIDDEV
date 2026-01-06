-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Core/MetadataParser.lua
-- @role: Core metadata parser
-- @purpose: Parse file headers and metadata blocks from Lua/XML files.
-- @rules:
--   - Must not modify files.
--   - Must only parse the top-of-file comment block.
--   - Must not depend on UI.
-- @good:
--   - Provides structured metadata for analyzers and tooltips.
-- @bad:
--   - Avoid scanning entire file contents beyond metadata region.

local Addon = _G.AIDDEV
Addon.Core = Addon.Core or {}

local Parser = {}
Addon.Core.MetadataParser = Parser

-- Simple state machine for parsing metadata blocks at the top of a file.
function Parser.Parse(content)
    local meta = {
        path    = nil,
        role    = nil,
        purpose = nil,
        rules   = {},
        good    = {},
        bad     = {},
    }

    local section = nil

    for line in content:gmatch("([^\r\n]*)[\r\n]?") do
        local trimmed = line:match("^%s*(.-)%s*$") or ""
        if trimmed == "" then
            -- stop parsing metadata once we hit first non-comment code line
        elseif trimmed:match("^%-%-") or trimmed:match("^<!%-%-") then
            -- Header path
            local path = trimmed:match("#(%S+)")
            if path and not meta.path then
                meta.path = path
            end

            -- Metadata keys
            local role = trimmed:match("@role:%s*(.+)")
            if role then
                meta.role = role
                section = nil
            end

            local purpose = trimmed:match("@purpose:%s*(.+)")
            if purpose then
                meta.purpose = purpose
                section = nil
            end

            if trimmed:match("@rules:") then
                section = "rules"
            elseif trimmed:match("@good:") then
                section = "good"
            elseif trimmed:match("@bad:") then
                section = "bad"
            elseif section and trimmed:match("^%-%s+%-") then
                local text = trimmed:match("^%-%s+%-%s*(.+)")
                if text and text ~= "" then
                    table.insert(meta[section], text)
                end
            end
        else
            -- first non-comment, non-blank line: stop parsing metadata
            break
        end
    end

    return meta
end

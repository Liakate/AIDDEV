-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Modules/EncodingAnalyzer.lua
-- @role: Analyzer module
-- @purpose: Detect null bytes, invalid encodings, and corrupted files.
-- @rules:
--   - Must not modify files.
--   - Must return structured diagnostics.
-- @good:
--   - Ensures files are readable by WoW.
-- @bad:
--   - Avoid deep content scanning beyond encoding checks.

local Addon = _G.AIDDEV
Addon.Modules = Addon.Modules or {}
local FS = Addon.Core.FileSystem

local M = {}
Addon.Modules.EncodingAnalyzer = M

local function hasNullBytes(s)
    return s:find("\0", 1, true) ~= nil
end

function M.Run(project)
    local results = {}

    for _, rel in ipairs(project.tocFiles) do
        if rel:match("%.lua$") or rel:match("%.xml$") or rel:match("%.toc$") then
            local full = FS.Join(project.root, rel)
            local content = FS.ReadFile(full)

            if content and hasNullBytes(content) then
                table.insert(results, {
                    file     = rel,
                    severity = "FATAL",
                    message  = "File contains null bytes.",
                    hint     = "Convert file to ANSI or UTF-8 without BOM.",
                })
            end
        end
    end

    return results
end

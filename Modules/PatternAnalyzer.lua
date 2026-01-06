-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Modules/PatternAnalyzer.lua
-- @role: Analyzer module
-- @purpose: Detect forbidden or risky Lua patterns.
-- @rules:
--   - Must not modify files.
--   - Must return structured diagnostics.
-- @good:
--   - Identifies dangerous constructs early.
-- @bad:
--   - Avoid over-aggressive pattern matching.

local Addon = _G.AIDDEV
Addon.Modules = Addon.Modules or {}
local FS = Addon.Core.FileSystem

local M = {}
Addon.Modules.PatternAnalyzer = M

local forbidden = {
    { pattern = "loadstring%s*%(", severity = "MAJOR", message = "Use of loadstring detected." },
    { pattern = "RunScript%s*%(", severity = "MAJOR", message = "Use of RunScript detected." },
    { pattern = "setfenv%s*%(", severity = "MINOR", message = "Use of setfenv detected." },
}

function M.Run(project)
    local results = {}

    for _, rel in ipairs(project.tocFiles) do
        if rel:match("%.lua$") then
            local full = FS.Join(project.root, rel)
            local content = FS.ReadFile(full)

            if content then
                for _, rule in ipairs(forbidden) do
                    if content:match(rule.pattern) then
                        table.insert(results, {
                            file     = rel,
                            severity = rule.severity,
                            message  = rule.message,
                        })
                    end
                end
            end
        end
    end

    return results
end

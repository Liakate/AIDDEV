-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Modules/NamespaceAnalyzer.lua
-- @role: Analyzer module
-- @purpose: Validate namespace usage and detect global pollution.
-- @rules:
--   - Must not modify files.
--   - Must return structured diagnostics.
-- @good:
--   - Encourages deterministic namespace usage.
-- @bad:
--   - Avoid false positives on legitimate globals.

local Addon = _G.AIDDEV
Addon.Modules = Addon.Modules or {}
local FS = Addon.Core.FileSystem

local M = {}
Addon.Modules.NamespaceAnalyzer = M

function M.Run(project)
    local results = {}

    for _, rel in ipairs(project.tocFiles) do
        if rel:match("%.lua$") then
            local full = FS.Join(project.root, rel)
            local content = FS.ReadFile(full)

            if content then
                if not content:match("local%s+AddonName,%s*Addon%s*=%s*%.%.%.") then
                    table.insert(results, {
                        file     = rel,
                        severity = "MAJOR",
                        message  = "Missing namespace declaration.",
                        hint     = "Add: local AddonName, Addon = ...",
                    })
                end

                if content:match("_G%.") then
                    table.insert(results, {
                        file     = rel,
                        severity = "MINOR",
                        message  = "Global access via _G detected.",
                        hint     = "Ensure this is intentional.",
                    })
                end
            end
        end
    end

    return results
end

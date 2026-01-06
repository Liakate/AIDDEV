-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Modules/XMLAnalyzer.lua
-- @role: Analyzer module
-- @purpose: Validate XML structure and detect missing root tags.
-- @rules:
--   - Must not modify files.
--   - Must return structured diagnostics.
-- @good:
--   - Ensures XML loads correctly.
-- @bad:
--   - Avoid deep XML parsing beyond structural checks.

local Addon = _G.AIDDEV
Addon.Modules = Addon.Modules or {}
local FS = Addon.Core.FileSystem

local M = {}
Addon.Modules.XMLAnalyzer = M

function M.Run(project)
    local results = {}

    for _, rel in ipairs(project.tocFiles) do
        if rel:match("%.xml$") then
            local full = FS.Join(project.root, rel)
            local content = FS.ReadFile(full)

            if content then
                if not content:match("<Ui") then
                    table.insert(results, {
                        file     = rel,
                        severity = "MAJOR",
                        message  = "Missing <Ui> root element.",
                    })
                end

                if not content:match("</Ui>") then
                    table.insert(results, {
                        file     = rel,
                        severity = "MAJOR",
                        message  = "Missing </Ui> closing tag.",
                    })
                end
            end
        end
    end

    return results
end

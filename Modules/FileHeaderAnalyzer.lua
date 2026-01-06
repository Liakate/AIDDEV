-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Modules/FileHeaderAnalyzer.lua
-- @role: Analyzer module
-- @purpose: Validate file headers and metadata blocks.
-- @rules:
--   - Must not modify files unless auto-header is enabled.
--   - Must return structured diagnostics.
-- @good:
--   - Ensures architectural consistency.
-- @bad:
--   - Avoid scanning file content beyond metadata block.

local Addon = _G.AIDDEV
Addon.Modules = Addon.Modules or {}
local FS = Addon.Core.FileSystem
local Parser = Addon.Core.MetadataParser

local M = {}
Addon.Modules.FileHeaderAnalyzer = M

function M.Run(project)
    local results = {}

    for _, rel in ipairs(project.tocFiles) do
        if rel:match("%.lua$") or rel:match("%.xml$") then
            local full = FS.Join(project.root, rel)
            local content = FS.ReadFile(full)

            if not content then
                table.insert(results, {
                    file     = rel,
                    severity = "MINOR",
                    message  = "Unable to read file for metadata check.",
                })
            else
                local meta = Parser.Parse(content)
                local expected = rel

                if not meta.path then
                    table.insert(results, {
                        file     = rel,
                        severity = "MINOR",
                        message  = "Missing file header.",
                        hint     = "Add: -- #" .. expected,
                    })
                elseif meta.path ~= expected then
                    table.insert(results, {
                        file     = rel,
                        severity = "MAJOR",
                        message  = "Incorrect file header path.",
                        hint     = "Expected: -- #" .. expected,
                    })
                end

                if not meta.role then
                    table.insert(results, {
                        file     = rel,
                        severity = "MINOR",
                        message  = "Missing @role metadata.",
                    })
                end

                if not meta.purpose then
                    table.insert(results, {
                        file     = rel,
                        severity = "MINOR",
                        message  = "Missing @purpose metadata.",
                    })
                end
            end
        end
    end

    return results
end

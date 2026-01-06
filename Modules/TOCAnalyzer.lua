-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Modules/TOCAnalyzer.lua
-- @role: Analyzer module
-- @purpose: Validate TOC structure, missing files, BOM, formatting, and Interface version consistency.
-- @rules:
--   - Must not modify files.
--   - Must return structured diagnostics.
--   - Must validate Interface version using user-defined expectedInterface.
-- @good:
--   - Ensures TOC correctness and server compatibility.
-- @bad:
--   - Avoid assuming a fixed Interface version; always use settings.

local Addon = _G.AIDDEV
Addon.Modules = Addon.Modules or {}
local FS = Addon.Core.FileSystem

local M = {}
Addon.Modules.TOCAnalyzer = M

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function checkBOM(content, tocPath, results)
    local b1, b2, b3 = content:byte(1,3)
    if b1 == 0xEF and b2 == 0xBB and b3 == 0xBF then
        table.insert(results, {
            file     = tocPath,
            severity = "FATAL",
            message  = "TOC contains UTF-8 BOM.",
            hint     = "Convert TOC to ANSI or UTF-8 without BOM.",
        })
    end
end

local function checkLeadingBlank(content, tocPath, results)
    if content:match("^\r?\n") then
        table.insert(results, {
            file     = tocPath,
            severity = "MAJOR",
            message  = "TOC begins with a blank line.",
        })
    end
end

local function checkWhitespaceBeforeHeader(content, tocPath, results)
    if content:match("^%s+##") then
        table.insert(results, {
            file     = tocPath,
            severity = "MAJOR",
            message  = "Whitespace before '## Interface' header.",
        })
    end
end

local function checkMissingFiles(project, results)
    for _, rel in ipairs(project.tocFiles) do
        local full = FS.Join(project.root, rel)
        if not FS.FileExists(full) then
            table.insert(results, {
                file     = project.tocPath,
                severity = "FATAL",
                message  = "File listed in TOC but missing: " .. rel,
            })
        end
    end
end

------------------------------------------------------------
-- Interface Version Consistency
------------------------------------------------------------

local function checkInterfaceVersion(content, tocPath, results)
    local expected = tostring(AIDDEV_Settings.expectedInterface or "")
    local found = content:match("##%s*Interface:%s*(%d+)")

    if not found then
        table.insert(results, {
            file     = tocPath,
            severity = "MAJOR",
            message  = "Missing ## Interface tag.",
        })
        return
    end

    if found ~= expected then
        table.insert(results, {
            file     = tocPath,
            severity = "FATAL",
            message  = "Interface mismatch: found " .. found .. ", expected " .. expected,
            hint     = "Update the TOC to match the server version.",
        })
    end
end

------------------------------------------------------------
-- Main Analyzer Entry
------------------------------------------------------------

function M.Run(project)
    local results = {}
    local tocPath = project.tocPath

    local content, err = FS.ReadFile(tocPath)
    if not content then
        table.insert(results, {
            file     = tocPath,
            severity = "FATAL",
            message  = "TOC not readable: " .. (err or "unknown error"),
        })
        return results
    end

    -- Structural checks
    checkBOM(content, tocPath, results)
    checkLeadingBlank(content, tocPath, results)
    checkWhitespaceBeforeHeader(content, tocPath, results)
    checkMissingFiles(project, results)

    -- Version consistency check
    checkInterfaceVersion(content, tocPath, results)

    return results
end

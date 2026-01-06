-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Modules/SyntaxAnalyzer.lua
-- @role: Analyzer module
-- @purpose: Validate Lua syntax, detect invalid tokens, top-level returns, and varargs misuse.
-- @rules:
--   - Must not modify files.
--   - Must return structured diagnostics.
--   - Must not depend on UI.
-- @good:
--   - Uses loadfile for safe syntax checking.
-- @bad:
--   - Avoid pattern scanning that belongs in PatternAnalyzer.

local Addon = _G.AIDDEV
Addon.Modules = Addon.Modules or {}
local FS = Addon.Core.FileSystem

local M = {}
Addon.Modules.SyntaxAnalyzer = M

local function safeLoad(path)
    local f, err = loadfile(path)
    if not f then return false, err end
    return true, nil
end

local function checkTopLevelVarargs(fullPath, content, results)
    local lineNum = 0
    for line in content:gmatch("([^\r\n]*)[\r\n]?") do
        lineNum = lineNum + 1
        local trimmed = line:match("^%s*(.-)%s*$") or ""
        if trimmed == "..." then
            table.insert(results, {
                file     = fullPath,
                line     = lineNum,
                severity = "FATAL",
                message  = "Top-level '...' token detected.",
                hint     = "Varargs must be inside a function definition.",
            })
        end
    end
end

local function checkTopLevelReturn(fullPath, content, results)
    local lineNum = 0
    for line in content:gmatch("([^\r\n]*)[\r\n]?") do
        lineNum = lineNum + 1
        local trimmed = line:match("^%s*(.-)%s*$") or ""
        if trimmed:match("^return[%s;]") then
            table.insert(results, {
                file     = fullPath,
                line     = lineNum,
                severity = "MAJOR",
                message  = "Top-level 'return' detected.",
                hint     = "Top-level returns stop file execution and should be avoided.",
            })
        end
    end
end

function M.Run(project)
    local results = {}

    for _, rel in ipairs(project.tocFiles) do
        if rel:match("%.lua$") then
            local full = FS.Join(project.root, rel)
            local ok, err = safeLoad(full)

            if not ok then
                table.insert(results, {
                    file     = rel,
                    severity = "FATAL",
                    message  = "Lua failed to load: " .. tostring(err),
                })
            end

            local content = FS.ReadFile(full)
            if content then
                checkTopLevelVarargs(rel, content, results)
                checkTopLevelReturn(rel, content, results)
            end
        end
    end

    return results
end

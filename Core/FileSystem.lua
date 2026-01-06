-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Core/FileSystem.lua
-- @role: Core utility module
-- @purpose: Provide file system helpers (join, read, write, scan) for AIDDEV analyzers.
-- @rules:
--   - Must not depend on UI or SavedVariables.
--   - Must not perform realm-specific logic.
--   - Should centralize all file IO for consistency.
-- @good:
--   - Single point of truth for file access.
-- @bad:
--   - Avoid embedding analyzer logic here.

local AddonName, Addon = ...
Addon = Addon or {}
_G.AIDDEV = Addon

Addon.Core = Addon.Core or {}
Addon.Core.FileSystem = Addon.Core.FileSystem or {}
local FS = Addon.Core.FileSystem

FS.ROOT         = "Interface/AddOns/AIDDEV/"
FS.PROJECT_ROOT = FS.ROOT .. "Project/"

local function join(...)
    local parts = { ... }
    local p = table.concat(parts, "/")
    p = p:gsub("//+", "/")
    return p
end

FS.Join = join

-- NOTE: These IO helpers assume an environment that supports io.open.
-- In pure WoW, you would replace this with external tooling or a custom layer.

function FS.ReadFile(path)
    local f, err = io.open(path, "r")
    if not f then return nil, err end
    local c = f:read("*a")
    f:close()
    return c or "", nil
end

function FS.WriteFile(path, content)
    local f, err = io.open(path, "w")
    if not f then return nil, err end
    f:write(content or "")
    f:close()
    return true, nil
end

function FS.FileExists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
    return false
end

-- Stub for recursive directory scanning; to be implemented by external tooling if needed.
function FS.ScanDirectoryRecursive(root, output)
    -- Implement using lfs or environment-specific APIs.
    -- 'output' should be a table receiving full file paths.
end

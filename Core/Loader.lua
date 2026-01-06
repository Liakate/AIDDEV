-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- Core/Loader.lua
-- Project loader abstraction for AIDDEV.
-- Primary source: AIDDEV_Companion, with local override capability.

local Loader = {}
AIDDEV_Loader = Loader

-- Local override (used only if Companion has no project)
Loader.localProject = nil

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------
local function get_companion()
    return _G.AIDDEV_Companion
end

---------------------------------------------------------------------
-- Project setters/getters
---------------------------------------------------------------------

-- Explicit override from DevTools or manual calls.
-- This is only used when Companion does NOT provide a project.
function Loader:SetCurrentProject(project)
    self.localProject = project
end

-- Preferred source: Companion
-- Fallback: local override
function Loader:GetCurrentProject()
    local companion = get_companion()

    if companion and companion.GetCurrentProject then
        local project = companion:GetCurrentProject()
        if project then
            return project
        end
    end

    return self.localProject
end

---------------------------------------------------------------------
-- Environment metadata
---------------------------------------------------------------------

-- Returns environment metadata from Companion if available.
-- Otherwise returns a safe fallback.
function Loader:GetEnvironment()
    local companion = get_companion()

    if companion and companion.GetEnvironment then
        return companion:GetEnvironment()
    end

    return {
        realm       = "UNKNOWN",
        clientBuild = 0,
        ruleset     = "unknown",
        encoding    = "UTF-8",
        lineEndings = "LF",
    }
end

---------------------------------------------------------------------
-- Local-only project builder (used for tests or manual injection)
---------------------------------------------------------------------
function Loader:BuildProjectFromFiles(fileMap)
    local project = { files = {} }

    for filename, content in pairs(fileMap) do
        project.files[filename] = {
            content = content,
        }
    end

    self.localProject = project
    return project
end

return Loader

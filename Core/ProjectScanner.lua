-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #Core/ProjectScanner.lua
-- @role: Core project indexer
-- @purpose: Discover projects in AIDDEV/Project and build TOC-based file indexes.
-- @rules:
--   - Must not perform analysis itself.
--   - Must not depend on UI.
--   - Should provide stable project indexes for all analyzers.
-- @good:
--   - Single responsibility: discovery and indexing.
-- @bad:
--   - Avoid realm- or addon-specific logic here.

local Addon = _G.AIDDEV
Addon.Core = Addon.Core or {}
local FS   = Addon.Core.FileSystem

local Scanner = {}
Addon.Core.ProjectScanner = Scanner

-- Returns a list of project descriptors:
-- { name = "AddonName", root = "Interface/AddOns/AIDDEV/Project/AddonName/", toc = "..." }
function Scanner.GetProjects()
    local projects = {}

    -- NOTE: This is a placeholder. In a real environment, you’d enumerate FS.PROJECT_ROOT.
    -- For now, you can hardwire targets or integrate with external tooling.
    local candidateNames = { "AID" } -- extend as needed

    for _, name in ipairs(candidateNames) do
        local root = FS.Join(FS.PROJECT_ROOT, name)
        local toc  = FS.Join(root, name .. ".toc")
        if FS.FileExists(toc) then
            table.insert(projects, {
                name = name,
                root = root .. "/",
                toc  = toc,
            })
        end
    end

    return projects
end

local function parseTOC(path)
    local files = {}
    local content, err = FS.ReadFile(path)
    if not content then
        return files, err
    end

    for line in content:gmatch("([^\r\n]*)[\r\n]?") do
        local trimmed = line:match("^%s*(.-)%s*$") or ""
        if trimmed ~= "" and not trimmed:match("^##") and not trimmed:match("^#") then
            table.insert(files, trimmed)
        end
    end

    return files, nil
end

-- Build project index for analyzers
function Scanner.BuildProjectIndex(project)
    local index = {
        name          = project.name,
        root          = project.root,
        tocPath       = project.toc,
        tocFiles      = {},
        treeFiles     = {},
        tocParseError = nil,
        metadata      = {}, -- per-file metadata cache
    }

    local tocFiles, err = parseTOC(project.toc)
    if not tocFiles and err then
        index.tocParseError = err
        tocFiles = {}
    end
    index.tocFiles = tocFiles

    -- For now: TOC-driven tree. Replace with real scanning if needed.
    for _, rel in ipairs(tocFiles) do
        table.insert(index.treeFiles, FS.Join(project.root, rel))
    end

    return index
end

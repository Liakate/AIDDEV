-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- AIDDEV Companion: Simple Project Scanner (Draft 1)
-- This script runs OUTSIDE WoW. It only collects data.
-- It writes a Lua table into AIDDEV/Session/Project.lua for in‑game use.

local lfs = require("lfs") -- LuaFileSystem recommended

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

local function scan_folder(root)
    local project = {
        toc = nil,
        files = {},
    }

    for file in lfs.dir(root) do
        if file ~= "." and file ~= ".." then
            local full = root .. "/" .. file

            local attr = lfs.attributes(full)
            if attr.mode == "file" then
                local ext = file:match("^.+(%..+)$")

                if ext == ".toc" then
                    project.toc = read_file(full)

                elseif ext == ".lua" or ext == ".xml" then
                    project.files[file] = {
                        content = read_file(full)
                    }
                end

            elseif attr.mode == "directory" then
                -- Recursively scan subfolders
                local sub = scan_folder(full)
                for k, v in pairs(sub.files) do
                    project.files[file .. "/" .. k] = v
                end
                if sub.toc and not project.toc then
                    project.toc = sub.toc
                end
            end
        end
    end

    return project
end

-- MAIN EXECUTION
local project_path = arg[1] or "./MyAddon"
local project = scan_folder(project_path)

-- Write session file
local out = io.open("AIDDEV/Session/Project.lua", "w")
out:write("AIDDEV_SessionProject = ")
out:write(require("serpent").block(project, {comment=false}))
out:close()

print("AIDDEV session project exported.")

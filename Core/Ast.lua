-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- Core/Ast.lua
-- Very lightweight AST / source inspection utilities for AIDDEV.
-- This is intentionally minimal and acts as a placeholder for a real parser.

local Ast = {}
AIDDEV_Ast = Ast

-- Build a "project AST".
-- For now, we just echo the project and assume other code can introspect per-file content.
function Ast:BuildProjectAst(project)
    -- In a real implementation, this would produce a structured AST.
    return project
end

---------------------------------------------------------------------
-- Simple handler signature inference
---------------------------------------------------------------------

-- parse a single function definition line
-- Supports patterns like:
--   function addon:OnEvent(self, event, arg1)
--   function addon.OnEvent(self, event, ...)
local function parse_function_def(line)
    local name, params =
        line:match("^%s*function%s+[%w_]+[:%.]([%w_]+)%s*%(([^)]*)%)")
    if not name then return nil end

    local args = {}
    for param in params:gmatch("([%w_]+)") do
        table.insert(args, param)
    end
    return name, args
end

-- Infer handler signatures per file.
-- Returns:
-- {
--   ["file.lua"] = {
--       ["OnEvent"] = { argc = 2, args = { "self", "event" } },
--       ...
--   },
--   ...
-- }
function Ast:InferHandlerSignatures(project)
    local signatures = {}

    for filename, file in pairs(project.files or {}) do
        local content = file.content or ""
        signatures[filename] = signatures[filename] or {}

        for line in content:gmatch("[^\r\n]*\r?\n?") do
            local funcName, args = parse_function_def(line)
            if funcName then
                signatures[filename][funcName] = {
                    argc = #args,
                    args = args,
                }
            end
        end
    end

    return signatures
end

return Ast

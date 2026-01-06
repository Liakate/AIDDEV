-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local guide = require "parser.guide"

local M = {}

function M.string_literal(expr)
    if not expr then return nil end
    if expr.type == "string" then
        return expr[1]
    end
    if expr.type == "boolean" then
        return tostring(expr[1])
    end
    if expr.type == "number" then
        return tostring(expr[1])
    end
    return nil
end

function M.literal_list_from_args(args)
    local out = {}
    if not args then return out end
    for _, v in ipairs(args) do
        local s = M.string_literal(v)
        if s then
            out[#out + 1] = s
        end
    end
    return out
end

return M

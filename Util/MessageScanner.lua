-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local guide = require "parser.guide"
local LiteralTools = require "Util.LiteralTools"

local M = {}

function M.scan_sends(ast)
    local sends = {}

    guide.eachSourceType(ast.ast or ast, "call", function(call)
        local callee = call.node
        if not callee then return end

        if callee.type == "getmethod" then
            if callee.method == "SendCommMessage" then
                local args = call.args or {}
                local prefix = args[1] and LiteralTools.string_literal(args[1])
                local msg = args[2] and LiteralTools.string_literal(args[2])

                table.insert(sends, {
                    node = call,
                    kind = "AceComm",
                    prefix = prefix,
                    message = msg,
                })
            end
        elseif callee.type == "getglobal" or callee.type == "getfield" then
            local name = callee[1]
            if name == "SendAddonMessage" or name == "C_ChatInfo.SendAddonMessage" then
                local args = call.args or {}
                local prefix = args[1] and LiteralTools.string_literal(args[1])
                local msg = args[2] and LiteralTools.string_literal(args[2])

                table.insert(sends, {
                    node = call,
                    kind = "AddonMessage",
                    prefix = prefix,
                    message = msg,
                })
            end
        end
    end)

    return sends
end

function M.scan_handlers(ast)
    local handlers = {}

    guide.eachSourceType(ast.ast or ast, "setmethod", function(node)
        local method = node.method
        if method ~= "OnCommReceived" and method ~= "OnAddonMessage" then
            return
        end

        local func = node.value
        if not func or func.type ~= "function" then return end

        local args = func.args or {}
        local prefixVar = args[1] and args[1][1] or nil
        local msgVar = args[2] and args[2][1] or nil

        local h = {
            node = node,
            kind = method,
            prefixVar = prefixVar,
            msgVar = msgVar,
            comparisons = {},
        }

        table.insert(handlers, h)
    end)

    for _, h in ipairs(handlers) do
        if h.msgVar then
            guide.eachSourceType(h.node, "if", function(ifNode)
                guide.eachSourceType(ifNode, "binary", function(bin)
                    if bin.op ~= "==" and bin.op ~= "~=" then return end
                    local left, right = bin[1], bin[2]
                    local litSide

                    if left.type == "getlocal" and left[1] == h.msgVar and right.type == "string" then
                        litSide = right
                    elseif right.type == "getlocal" and right[1] == h.msgVar and left.type == "string" then
                        litSide = left
                    end

                    if litSide then
                        table.insert(h.comparisons, litSide[1])
                    end
                end)
            end)
        end
    end

    return handlers
end

return M

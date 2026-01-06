-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
---@diagnostic disable: lowercase-global

local guide = require "parser.guide"

local M = {}

function M.each_node(ast, type_name, callback)
    guide.eachSourceType(ast.ast or ast, type_name, callback)
end

function M.get_root(ast)
    return ast.ast or ast
end

function M.get_parent(node, kind)
    local p = node.parent
    while p do
        if not kind or p.type == kind then
            return p
        end
        p = p.parent
    end
    return nil
end

function M.get_symbol_name(node)
    if not node then return nil end

    if node.type == "setlocal" then
        local v = node[1]
        if v and (v.type == "local" or v.type == "name") then
            return v[1]
        end
    end

    if node.type == "local" or node.type == "name" or node.type == "getlocal" then
        return node[1]
    end

    if node.type == "setglobal" or node.type == "getglobal" then
        return node[1]
    end

    if node.type == "setfield" or node.type == "getfield" then
        local base = M.get_symbol_name(node.node)
        local key = node.field
        if base and key then
            return base .. "." .. key
        end
    end

    if node.type == "setmethod" or node.type == "getmethod" then
        local base = M.get_symbol_name(node.node)
        local key = node.method
        if base and key then
            return base .. ":" .. key
        end
    end

    if node.type == "setindex" or node.type == "getindex" then
        local base = M.get_symbol_name(node.node)
        if base then
            return base
        end
    end

    return nil
end

function M.add_doc(ast, targetNode, kind, text, group)
    group = group or {}
    local docs = ast.docs or ast._docs
    if not docs then
        docs = {}
        ast.docs = docs
    end

    local doc = {
        type = "doc." .. kind,
        [1] = text,
        start = targetNode.start,
        finish = targetNode.finish,
        group = group,
    }

    docs[#docs + 1] = doc
end

return M

-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local guide = require "parser.guide"
local AstTools = require "Util.AstTools"

local M = {}

local function add_handler(hub, eventName, handlerNode)
    if not eventName or not handlerNode then return end
    hub.handlers[eventName] = hub.handlers[eventName] or {}
    table.insert(hub.handlers[eventName], handlerNode)
end

local function scan_frame_hubs(ast, hubs)
    local frames = {}

    AstTools.each_node(ast, "setlocal", function(node)
        local value = node.value
        if not value or value.type ~= "call" then return end
        local callee = value.node
        if not callee or callee.type ~= "getglobal" then return end
        if callee[1] ~= "CreateFrame" then return end

        local name = AstTools.get_symbol_name(node)
        if not name then return end

        local hub = {
            name = name,
            node = node,
            handlers = {},
            type = "frame",
        }
        frames[name] = hub
        table.insert(hubs, hub)
    end)

    AstTools.each_node(ast, "call", function(call)
        local callee = call.node
        if not callee or callee.type ~= "getmethod" then return end

        local obj = callee.node
        if not obj then return end
        local objName = AstTools.get_symbol_name(obj)
        if not objName or not frames[objName] then return end

        local methodName = callee.method
        local args = call.args or {}

        if methodName == "RegisterEvent" or methodName == "RegisterUnitEvent" then
            local firstArg = args[1]
            if firstArg and firstArg.type == "string" then
                add_handler(frames[objName], firstArg[1], call)
            end
        end

        if methodName == "SetScript" then
            local scriptType = args[1]
            local funcArg = args[2]
            if scriptType and scriptType.type == "string" and scriptType[1] == "OnEvent" then
                add_handler(frames[objName], "OnEvent", funcArg or call)
            end
        end
    end)
end

local function scan_table_hubs(ast, hubs)
    local hubByName = {}

    local function get_or_create_hub(name, node)
        local h = hubByName[name]
        if not h then
            h = {
                name = name,
                node = node,
                handlers = {},
                type = "table",
            }
            hubByName[name] = h
            table.insert(hubs, h)
        end
        return h
    end

    AstTools.each_node(ast, "setfield", function(node)
        local baseName = AstTools.get_symbol_name(node.node)
        if not baseName then return end
        local field = node.field
        if not field then return end
        local value = node.value
        if not value then return end

        if field:match("^[A-Z0-9_]+$") then
            local hub = get_or_create_hub(baseName, node)
            add_handler(hub, field, value)
        end
    end)

    AstTools.each_node(ast, "setmethod", function(node)
        local baseName = AstTools.get_symbol_name(node.node)
        if not baseName then return end
        local method = node.method
        if not method then return end

        if method:match("^[A-Z0-9_]+$") then
            local hub = get_or_create_hub(baseName, node)
            add_handler(hub, method, node)
        end
    end)
end

local function scan_aceevent_hubs(ast, hubs)
    local hubByName = {}

    local function get_or_create_hub(name, node)
        local h = hubByName[name]
        if not h then
            h = {
                name = name,
                node = node,
                handlers = {},
                type = "aceevent",
            }
            hubByName[name] = h
            table.insert(hubs, h)
        end
        return h
    end

    AstTools.each_node(ast, "call", function(call)
        local callee = call.node
        if not callee or callee.type ~= "getmethod" then return end
        local obj = callee.node
        local methodName = callee.method
        if methodName ~= "RegisterEvent" then return end

        local baseName = AstTools.get_symbol_name(obj)
        if not baseName then return end

        local args = call.args or {}
        local eventArg = args[1]
        local handlerArg = args[2]

        if not eventArg or eventArg.type ~= "string" then return end

        local hub = get_or_create_hub(baseName, call)
        add_handler(hub, eventArg[1], handlerArg or call)
    end)
end

function M.scan(ast)
    local hubs = {}
    scan_frame_hubs(ast, hubs)
    scan_table_hubs(ast, hubs)
    scan_aceevent_hubs(ast, hubs)
    return hubs
end

return M

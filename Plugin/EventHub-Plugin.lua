-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local EventPrototypes = require "Definitions.EventPrototypes"
local EventScanner = require "Util.EventScanner"
local AstTools = require "Util.AstTools"

local plugin = {}

local function build_func_sig(className, eventName, proto)
    local args = proto.args or {}
    local parts = {}
    parts[#parts + 1] = "self: " .. className
    for _, argName in ipairs(args) do
        parts[#parts + 1] = argName .. ": any"
    end
    return eventName .. " fun(" .. table.concat(parts, ", ") .. ")"
end

local function add_eventhub_class(ast, hub)
    local className = hub.name or "EventHub"
    local group = {}

    AstTools.add_doc(ast, hub.node, "class", className .. ": EventHub", group)

    for eventName in pairs(hub.handlers) do
        local proto = EventPrototypes[eventName]
        local sig
        if proto then
            sig = build_func_sig(className, eventName, proto)
        else
            sig = eventName .. " fun(self: " .. className .. ", ...: any)"
        end
        AstTools.add_doc(ast, hub.node, "field", sig, group)
    end
end

function plugin:OnTransformAst(uri, ast)
    local hubs = EventScanner.scan(ast)
    for _, hub in ipairs(hubs) do
        add_eventhub_class(ast, hub)
    end
end

if not QUIET then
    print("Loaded AIDDEV EventHub plugin")
end

return plugin

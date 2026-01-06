-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local CustomDiagnostics = require "Custom-Diagnostics"
local EventPrototypes = require "Definitions.EventPrototypes"
local EventScanner = require "Util.EventScanner"
local DiagnosticValidator = require "Libs.DiagnosticValidator"

local diagName = "aiddev-event-handler"

local M = {}

local function get_func_from_handler_node(node)
    if node.type == "function" then
        return node
    end
    if node.value and node.value.type == "function" then
        return node.value
    end
    return nil
end

local function check_handler(uri, ast, hub, eventName, handlerNode, publish)
    local proto = EventPrototypes[eventName]
    if not proto then return end

    local fn = get_func_from_handler_node(handlerNode)
    if not fn then return end

    local args = fn.args or {}
    local expected = (#proto.args or 0) + 1
    local actual = #args

    if actual ~= expected then
        local payload = {
            code = diagName,
            message = ("Handler for event '%s' has %d parameters, expected %d (including self)"):format(
                eventName, actual, expected
            ),
            start = fn.start,
            finish = fn.finish,

            aiddev = {
                reference = "lua51",
                error_class = "AIDDEV_BAD_EVENT_HANDLER_SIGNATURE",
            },
        }

        local ok, err = DiagnosticValidator.validate_payload(payload)
        if not ok and DEVELOP then
            if log and log.error then
                log.error("AIDDEV event-handler metadata error: " .. tostring(err))
            else
                print("AIDDEV event-handler metadata error: " .. tostring(err))
            end
            payload.aiddev.incomplete_metadata = true
        end

        publish(payload)
    end
end

local function check_hub(uri, ast, hub, publish)
    for eventName, handlers in pairs(hub.handlers) do
        for _, node in ipairs(handlers) do
            check_handler(uri, ast, hub, eventName, node, publish)
        end
    end
end

function M.check(uri, ast, publish)
    local hubs = EventScanner.scan(ast)
    for _, hub in ipairs(hubs) do
        check_hub(uri, ast, hub, publish)
    end
end

CustomDiagnostics:New(diagName, M.check, "Warning", "Any", "AIDDEV")

return M

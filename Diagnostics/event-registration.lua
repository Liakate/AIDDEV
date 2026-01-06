-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local CustomDiagnostics = require "Custom-Diagnostics"
local EventPrototypes = require "Definitions.EventPrototypes"
local EventScanner = require "Util.EventScanner"
local DiagnosticValidator = require "Libs.DiagnosticValidator"

local diagName = "aiddev-event-registration"

local M = {}

local function check_hub(uri, ast, hub, publish)
    for eventName, handlers in pairs(hub.handlers) do
        local proto = EventPrototypes[eventName]
        if not proto then
            for _, node in ipairs(handlers) do
                local payload = {
                    code = diagName,
                    message = ("Unknown or unsupported event '%s'"):format(eventName),
                    start = node.start,
                    finish = node.finish,

                    aiddev = {
                        reference = "wow_exec",
                        error_class = "AIDDEV_UNKNOWN_EVENT",
                    },
                }

                local ok, err = DiagnosticValidator.validate_payload(payload)
                if not ok and DEVELOP then
                    if log and log.error then
                        log.error("AIDDEV event-registration metadata error: " .. tostring(err))
                    else
                        print("AIDDEV event-registration metadata error: " .. tostring(err))
                    end
                    payload.aiddev.incomplete_metadata = true
                end

                publish(payload)
            end
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

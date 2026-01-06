-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local eventHubPlugin = require "Plugin.EventHub-Plugin"
local messagePlugin = require "Plugin.MessageProtocol-Plugin"
local DiagnosticValidator = require "Libs.DiagnosticValidator"

-- Wrap the publish function so every diagnostic is validated
local function make_validating_publish(realPublish)
    return function(payload)
        local ok, err = DiagnosticValidator.validate_payload(payload)
        if not ok and DEVELOP then
            if log and log.error then
                log.error("AIDDEV diagnostic metadata error: " .. tostring(err))
            else
                print("AIDDEV diagnostic metadata error: " .. tostring(err))
            end
            payload.aiddev = payload.aiddev or {}
            payload.aiddev.incomplete_metadata = true
        end

        realPublish(payload)
    end
end

-- LuaLS calls this for AST transforms
function OnTransformAst(uri, ast)
    eventHubPlugin:OnTransformAst(uri, ast)
    messagePlugin:OnTransformAst(uri, ast)
    return ast
end

-- Load diagnostics so they register with LuaLS
require "Diagnostics.event-registration"
require "Diagnostics.event-handler"
require "Diagnostics.message-protocol"

return {
    make_validating_publish = make_validating_publish,
}

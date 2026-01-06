-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local CustomDiagnostics = require "Custom-Diagnostics"
local MessageScanner = require "Util.MessageScanner"
local DiagnosticValidator = require "Libs.DiagnosticValidator"

local diagName = "aiddev-message-protocol"

local M = {}

function M.check(uri, ast, publish)
    local sends = MessageScanner.scan_sends(ast)
    local handlers = MessageScanner.scan_handlers(ast)

    local sentLiterals = {}
    for _, s in ipairs(sends) do
        if s.message then
            sentLiterals[s.message] = sentLiterals[s.message] or {}
            table.insert(sentLiterals[s.message], s)
        end
    end

    local handledLiterals = {}
    for _, h in ipairs(handlers) do
        for _, msg in ipairs(h.comparisons) do
            handledLiterals[msg] = handledLiterals[msg] or {}
            table.insert(handledLiterals[msg], h)
        end
    end

    for msg, list in pairs(sentLiterals) do
        if not handledLiterals[msg] then
            for _, s in ipairs(list) do
                local payload = {
                    code = diagName,
                    message = ("Message '%s' is sent but never tested in any handler"):format(msg),
                    start = s.node.start,
                    finish = s.node.finish,

                    aiddev = {
                        reference = "wow_exec",
                        error_class = "AIDDEV_MESSAGE_SENT_BUT_NOT_HANDLED",
                    },
                }

                local ok, err = DiagnosticValidator.validate_payload(payload)
                if not ok and DEVELOP then
                    print("AIDDEV message-protocol metadata error: " .. tostring(err))
                    payload.aiddev.incomplete_metadata = true
                end

                publish(payload)
            end
        end
    end

    for msg, list in pairs(handledLiterals) do
        if not sentLiterals[msg] then
            for _, h in ipairs(list) do
                local payload = {
                    code = diagName,
                    message = ("Message '%s' is handled but never sent anywhere"):format(msg),
                    start = h.node.start,
                    finish = h.node.finish,

                    aiddev = {
                        reference = "wow_exec",
                        error_class = "AIDDEV_MESSAGE_HANDLED_BUT_NOT_SENT",
                    },
                }

                local ok, err = DiagnosticValidator.validate_payload(payload)
                if not ok and DEVELOP then
                    print("AIDDEV message-protocol metadata error: " .. tostring(err))
                    payload.aiddev.incomplete_metadata = true
                end

                publish(payload)
            end
        end
    end
end

CustomDiagnostics:New(diagName, M.check, "Information", "Any", "AIDDEV")

return M

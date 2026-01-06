-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local mod = {}

local protoDiagnostic = require "proto.diagnostic"
local protoDefine = require "proto.define"

-- Register AIDDEV diagnostics into LuaLS
function mod:New(name, func, severity, fileStatus, group)
    severity = severity or "Warning"
    fileStatus = fileStatus or "Opened"
    group = group or "AIDDEV"

    protoDiagnostic.register { name } {
        group = group,
        severity = severity,
        status = fileStatus,
    }

    protoDiagnostic._diagAndErrNames[name] = true
    protoDefine.DiagnosticDefaultSeverity[name] = severity
    protoDefine.DiagnosticDefaultNeededFileStatus[name] = fileStatus

    package.loaded["core.diagnostics." .. name] = func
end

return mod

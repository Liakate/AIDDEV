-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local Rules = require "Libs.Rules"
local References = require "Libs.References"
local ErrorClasses = require "Libs.ErrorClasses"

local Validator = {}

function Validator.validate_payload(payload)
    local aiddev = payload.aiddev
    if not aiddev then
        return false, "missing aiddev metadata"
    end

    local ref = aiddev.reference
    local okRef, refErr = Rules.validate_reference_id(ref)
    if not okRef then
        return false, refErr
    end

    local cls = aiddev.error_class
    if not cls then
        return false, "missing error_class"
    end
    if not ErrorClasses[cls] then
        return false, "unknown error_class '" .. tostring(cls) .. "'"
    end

    return true
end

return Validator

-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local compile = compile

local function test(script)
    return compile(script)
end

-- Known event, correct handler
test[[
    local f = CreateFrame("Frame")
    f:RegisterEvent("UNIT_HEALTH")
    function f:UNIT_HEALTH(unit)
    end
]]

-- Unknown event (should trigger AIDDEV_UNKNOWN_EVENT)
test[[
    local f = CreateFrame("Frame")
    f:RegisterEvent("FAKE_EVENT")
]]

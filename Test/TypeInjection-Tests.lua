-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local compile = compile

local function test(script)
    return compile(script)
end

-- EventHub class injection test
test[[
    local f = CreateFrame("Frame")
    f:RegisterEvent("UNIT_HEALTH")
    function f:UNIT_HEALTH(unit)
    end
]]

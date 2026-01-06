-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local compile = compile

local function test(script)
    return compile(script)
end

-- Message sent and handled
test[[
    local AceComm = {}
    function AceComm:SendCommMessage(prefix, msg, channel) end

    local addon = {}

    function addon:OnCommReceived(prefix, msg)
        if msg == "HELLO" then
        end
    end

    AceComm:SendCommMessage("X", "HELLO", "RAID")
]]

-- Message handled but never sent
test[[
    local addon = {}

    function addon:OnCommReceived(prefix, msg)
        if msg == "WORLD" then
        end
    end
]]

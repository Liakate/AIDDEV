-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- Core/RuntimeHooks.lua
-- Runtime hook layer for AIDDEV: wraps functions and forwards call info.

local Behavior = nil  -- lazy resolve to avoid load-order issues

local Hooks = {}
AIDDEV_RuntimeHooks = Hooks

Hooks._wrapped = {}   -- [original] = wrapper
Hooks._targets = {}   -- { { owner=, key=, meta= }, ... }

local function get_behavior()
    Behavior = Behavior or AIDDEV_RuntimeBehavior
    return Behavior
end

-- Generic wrapper factory
local function make_wrapper(owner, key, original, meta)
    local behavior = get_behavior()
    return function(...)
        local args = { ... }
        local ok, ret1, ret2, ret3, ret4 = pcall(function()
            if behavior and behavior.RecordCall then
                behavior:RecordCall(owner, key, original, meta, args)
            end
            return original(unpack(args))
        end)

        if not ok then
            if behavior and behavior.RecordError then
                behavior:RecordError(owner, key, original, meta, ret1)
            end
            error(ret1)
        end

        return ret1, ret2, ret3, ret4
    end
end

-- Public API: register a function to be wrapped later
function Hooks:RegisterTarget(owner, key, meta)
    meta = meta or {}
    table.insert(self._targets, {
        owner = owner,
        key   = key,
        meta  = meta,
    })
end

-- Apply wrapping to all registered targets
function Hooks:Apply()
    for _, t in ipairs(self._targets) do
        local owner, key, meta = t.owner, t.key, t.meta
        if owner and key and type(owner[key]) == "function" then
            local original = owner[key]
            if not self._wrapped[original] then
                local wrapper = make_wrapper(owner, key, original, meta)
                self._wrapped[original] = wrapper
                owner[key] = wrapper
            end
        end
    end
end

-- Convenience: hook a frame's OnEvent script
function Hooks:HookFrameEvents(frame, meta)
    meta = meta or {}
    meta.kind = meta.kind or "event-handler"

    local original = frame:GetScript("OnEvent")
    if original and not self._wrapped[original] then
        local wrapper = make_wrapper(frame, "OnEvent", original, meta)
        self._wrapped[original] = wrapper
        frame:SetScript("OnEvent", wrapper)
    end
end

-- Convenience: hook a message handler on an object
function Hooks:HookMessageHandler(owner, methodName, meta)
    meta = meta or {}
    meta.kind = meta.kind or "message-handler"
    self:RegisterTarget(owner, methodName, meta)
end

return Hooks

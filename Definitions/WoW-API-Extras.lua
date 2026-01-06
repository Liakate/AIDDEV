-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
---@meta

-- Minimal WoW API stubs for LuaLS.
-- These prevent false positives and allow AIDDEV to reason about frames, events, and messaging.

---@class Frame
local Frame = {}
function Frame:RegisterEvent(eventName) end
function Frame:RegisterUnitEvent(eventName, unit, ...) end
function Frame:SetScript(scriptType, func) end

---@return Frame
function CreateFrame(frameType, name, parent, template) end

---@class AceComm
local AceComm = {}
function AceComm:SendCommMessage(prefix, message, channel, target, priority, callbackFn, callbackArg) end

---@class AceEvent
local AceEvent = {}
function AceEvent:RegisterEvent(event, method) end

C_ChatInfo = C_ChatInfo or {}
function C_ChatInfo.SendAddonMessage(prefix, message, channel, target) end

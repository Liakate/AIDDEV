-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- Core/UiColors.lua
-- Color helpers for severity-coded UI output.

local UiColors = {}
AIDDEV_UiColors = UiColors

local COLORS = {
    high   = "|cffff0000", -- red
    medium = "|cffffa500", -- orange
    low    = "|cffffff00", -- yellow
    info   = "|cff00ff00", -- green
    reset  = "|r",
}

function UiColors:Severity(severity, text)
    local c = COLORS[severity] or COLORS.info
    return c .. (text or "") .. COLORS.reset
end

return UiColors

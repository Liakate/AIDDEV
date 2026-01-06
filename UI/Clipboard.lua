-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- UI/Clipboard.lua
-- Simple clipboard popup for exporting snapshots or text blocks.

local Clipboard = {}
AIDDEV_Clipboard = Clipboard

function Clipboard:Show(text, title)
    local frame = AIDDEVClipboardFrame
    if not frame then return end

    frame.Title:SetText(title or "AIDDEV Clipboard")
    frame.contentText:SetText(text or "")
    frame:Show()
end

-- Convenience wrapper
function AIDDEV_ShowClipboard(text, title)
    AIDDEV_Clipboard:Show(text, title)
end

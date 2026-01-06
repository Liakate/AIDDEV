-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local Behavior = AIDDEV_RuntimeBehavior
local UiColors = AIDDEV_UiColors

local Live = {}
AIDDEV_RuntimeLiveMonitor = Live

local updateAccum = 0

function Live:Refresh()
    local frame = AIDDEVRuntimeLiveMonitor
    if not frame then return end

    local calls = Behavior:GetAll() or {}
    local text = UiColors:Severity("info", "Live runtime calls:") .. "\n\n"

    for id, rec in pairs(calls) do
        local sev = (rec.errors > 0) and "high" or "low"
        text = text .. UiColors:Severity(sev,
            string.format("%s -> calls=%d, errors=%d", id, rec.count, rec.errors)
        ) .. "\n"
    end

    if not frame.contentText then
        local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        frame.contentText = fs
        frame.Scroll:SetScrollChild(fs)
    end
    frame.contentText:SetText(text)
end

function AIDDEV_RuntimeLiveMonitor_OnLoad(frame)
    SLASH_AIDDEVLIVE1 = "/aiddevlive"
    SlashCmdList["AIDDEVLIVE"] = function(msg)
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
            Live:Refresh()
        end
    end
end

function AIDDEV_RuntimeLiveMonitor_OnUpdate(frame, elapsed)
    updateAccum = updateAccum + elapsed
    if updateAccum > 1.0 then  -- update every second
        updateAccum = 0
        Live:Refresh()
    end
end

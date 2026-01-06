-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- UI/RuntimeDiagnostics.lua
-- Full runtime diagnostics panel with snapshot, diff, per-function diff, etc.

local Behavior = AIDDEV_RuntimeBehavior
local Compare  = AIDDEV_RuntimeCompare
local Anomaly  = AIDDEV_RuntimeAnomaly
local Diff     = AIDDEV_RuntimeDiff
local UiColors = AIDDEV_UiColors

local RuntimeUI = {}
AIDDEV_RuntimeDiagnosticsUI = RuntimeUI

local lastSnapshot = nil
local currentId = nil

---------------------------------------------------------------------
-- Dropdown initialization
---------------------------------------------------------------------
local function initDropdown(self, level)
    local calls = Behavior:GetAll() or {}

    for id in pairs(calls) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = id
        info.func = function()
            currentId = id
            RuntimeUI:Refresh()
        end
        UIDropDownMenu_AddButton(info)
    end
end

---------------------------------------------------------------------
-- UI Refresh
---------------------------------------------------------------------
function RuntimeUI:Refresh()
    local frame = AIDDEVRuntimeDiagnosticsFrame
    if not frame then return end

    Compare:Run()
    local findings = Anomaly:GetAll()
    local calls    = Behavior:GetAll() or {}

    -- Pick first function if none selected
    if not currentId then
        for id in pairs(calls) do
            currentId = id
            break
        end
    end

    -- Build findings text
    local text = UiColors:Severity("info", "Runtime Behavior:") .. "\n\n"

    for id, rec in pairs(calls) do
        local sev = (rec.errors > 0) and "high" or "low"
        local prefix = (id == currentId) and "> " or "  "
        text = text .. prefix .. UiColors:Severity(sev,
            string.format("%s (calls=%d, errors=%d)", id, rec.count, rec.errors)
        ) .. "\n"
    end

    text = text .. "\n" .. UiColors:Severity("info", "Findings:") .. "\n\n"

    for _, f in ipairs(findings) do
        local sevText = UiColors:Severity(f.severity or "info", f.severity or "?")
        text = text .. string.format("[%s][%s] %s\n", sevText, f.kind or "?", f.message or "?")
    end

    -- Apply to scroll frame
    if not frame.findingsText then
        local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        frame.findingsText = fs
        frame.FindingsScroll:SetScrollChild(fs)
    end

    frame.findingsText:SetText(text)
end

---------------------------------------------------------------------
-- Button handlers
---------------------------------------------------------------------

function AIDDEV_RT_Snapshot()
    lastSnapshot = Behavior:ExportSnapshot()
    print("|cff00ff00AIDDEV:|r Snapshot captured")
end

function AIDDEV_RT_ClearSnapshot()
    lastSnapshot = nil
    print("|cff00ff00AIDDEV:|r Snapshot cleared")
end

function AIDDEV_RT_Diff()
    if not lastSnapshot then
        print("|cffff0000AIDDEV:|r No snapshot available")
        return
    end

    local now = Behavior:ExportSnapshot()
    local changes = Diff:CompareSnapshots(lastSnapshot, now)
    RuntimeUI:ShowDiff(changes, "Snapshot Diff")
end

function AIDDEV_RT_SaveSnapshot()
    if not lastSnapshot then
        print("|cffff0000AIDDEV:|r No snapshot to save")
        return
    end

    local serialized = Behavior:SerializeSnapshot(lastSnapshot)
    AIDDEV_ShowClipboard(serialized, "Runtime Snapshot")
end

function AIDDEV_RT_ComparePrev()
    local prev = AIDDEV_RuntimeSaved and AIDDEV_RuntimeSaved.previousSession
    if not prev then
        print("|cffff0000AIDDEV:|r No previous session snapshot found")
        return
    end

    local now = Behavior:ExportSnapshot()
    local changes = Diff:CompareSnapshots(prev, now)
    RuntimeUI:ShowDiff(changes, "Previous Session Diff")
end

function AIDDEV_RT_FunctionDiff()
    if not currentId then
        print("|cffff0000AIDDEV:|r No function selected")
        return
    end

    RuntimeUI:ShowFunctionDiff(currentId)
end

---------------------------------------------------------------------
-- Diff view
---------------------------------------------------------------------
function RuntimeUI:ShowDiff(changes, title)
    local frame = AIDDEVRuntimeDiagnosticsFrame
    local text = UiColors:Severity("info", title) .. "\n\n"

    if #changes == 0 then
        text = text .. UiColors:Severity("low", "No changes detected.")
    else
        for _, c in ipairs(changes) do
            local sev = "low"
            if c.kind == "changed-stats" then sev = "medium" end
            if c.kind == "new-function" or c.kind == "removed-function" then sev = "high" end

            text = text .. UiColors:Severity(sev, "- " .. c.message) .. "\n"
        end
    end

    if not frame.diffText then
        local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        frame.diffText = fs
        frame.DiffScroll:SetScrollChild(fs)
    end

    frame.diffText:SetText(text)
end

---------------------------------------------------------------------
-- Per-function diff
---------------------------------------------------------------------
function RuntimeUI:ShowFunctionDiff(id)
    if not lastSnapshot then
        print("|cffff0000AIDDEV:|r No snapshot available")
        return
    end

    local prev = lastSnapshot
    local now  = Behavior:ExportSnapshot()

    local before = prev[id]
    local after  = now[id]

    local frame = AIDDEVRuntimeDiagnosticsFrame
    local text = UiColors:Severity("info", "Diff for: " .. id) .. "\n\n"

    if not before and not after then
        text = text .. UiColors:Severity("low", "Function not present in either snapshot.")
    elseif not before then
        text = text .. UiColors:Severity("high", "Function is NEW in current session.")
    elseif not after then
        text = text .. UiColors:Severity("high", "Function was REMOVED since snapshot.")
    else
        text = text .. string.format("Calls: %d → %d\nErrors: %d → %d\n",
            before.count, after.count, before.errors, after.errors)

        text = text .. "\nArg Patterns:\n"
        for argc, count in pairs(before.argCounts) do
            local afterCount = after.argCounts[argc] or 0
            local sev = (count ~= afterCount) and "medium" or "low"
            text = text .. UiColors:Severity(sev,
                string.format("  %d args: %d → %d", argc, count, afterCount)
            ) .. "\n"
        end
    end

    if not frame.diffText then
        local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        frame.diffText = fs
        frame.DiffScroll:SetScrollChild(fs)
    end

    frame.diffText:SetText(text)
end

---------------------------------------------------------------------
-- OnLoad
---------------------------------------------------------------------
function AIDDEV_RuntimeDiagnostics_OnLoad(frame)
    UIDropDownMenu_Initialize(frame.FunctionDropdown, initDropdown)
    RuntimeUI:Refresh()
end

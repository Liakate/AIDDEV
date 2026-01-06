-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #UI/DevPanel.lua
-- @role: UI module
-- @purpose: Provide the main AIDDEV interface for selecting and running tests.
-- @rules:
--   - Must not perform analysis directly.
--   - Must not modify project files.
--   - Must use relative layout only.
-- @good:
--   - Clean, dynamic UI with no XY offsets.
-- @bad:
--   - Avoid embedding analyzer logic here.

local Addon = _G.AIDDEV
Addon.UI = Addon.UI or {}
local UI = Addon.UI

function UI.ShowPanel()
    if UI.Panel then
        UI.Panel:Show()
        return
    end

    ------------------------------------------------------------
    -- Main Frame
    ------------------------------------------------------------
    local f = CreateFrame("Frame", "AIDDEV_MainPanel", UIParent, "BackdropTemplate")
    f:SetSize(700, 500)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.85)
    UI.Panel = f

    ------------------------------------------------------------
    -- Banner
    ------------------------------------------------------------
    local banner = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    banner:SetPoint("TOP", f, "TOP")
    banner:SetText("|cffffcc00AIDDEV|r")

    ------------------------------------------------------------
    -- Button Row Container
    ------------------------------------------------------------
    local buttonRow = CreateFrame("Frame", nil, f)
    buttonRow:SetPoint("TOP", banner, "BOTTOM")
    buttonRow:SetPoint("LEFT", f, "LEFT")
    buttonRow:SetPoint("RIGHT", f, "RIGHT")
    buttonRow:SetHeight(40)

    ------------------------------------------------------------
    -- Explanation Text (initial)
    ------------------------------------------------------------
    local explain = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    explain:SetPoint("TOP", buttonRow, "BOTTOM")
    explain:SetText("Select a test above to see what it does.")

    ------------------------------------------------------------
    -- Dynamic Start Test Button + Test Explanation
    ------------------------------------------------------------
    local startButton = nil
    local testExplain = nil

    ------------------------------------------------------------
    -- Button Factory
    ------------------------------------------------------------
    local function CreateTopButton(label, analyzerName, description)
        local btn = CreateFrame("Button", nil, buttonRow, "UIPanelButtonTemplate")
        btn:SetText(label)
        btn:SetSize(140, 24)

        btn:SetScript("OnClick", function()
            explain:SetText("")

            if startButton then startButton:Hide() end
            if testExplain then testExplain:Hide() end

            startButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
            startButton:SetText("Start Test")
            startButton:SetSize(160, 26)
            startButton:SetPoint("TOP", buttonRow, "BOTTOM")

            startButton:SetScript("OnClick", function()
                local results = Addon.RunSingle(analyzerName)
                UI.ShowCopyWindow(results)
            end)

            testExplain = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            testExplain:SetPoint("TOP", startButton, "BOTTOM")
            testExplain:SetText(description)
        end)

        return btn
    end

    ------------------------------------------------------------
    -- Create Buttons
    ------------------------------------------------------------
    local buttons = {
        CreateTopButton("Syntax",   "SyntaxAnalyzer",   "Checks Lua syntax, invalid tokens, top-level returns, and varargs."),
        CreateTopButton("TOC",      "TOCAnalyzer",      "Validates TOC structure, missing files, BOM, and formatting."),
        CreateTopButton("Encoding", "EncodingAnalyzer", "Detects null bytes, invalid encodings, and corrupted files."),
        CreateTopButton("Headers",  "FileHeaderAnalyzer", "Validates file headers and metadata blocks."),
    }

    ------------------------------------------------------------
    -- Auto-center button row
    ------------------------------------------------------------
    local previous
    for i, btn in ipairs(buttons) do
        if i == 1 then
            btn:SetPoint("TOP", buttonRow, "TOP")
        else
            btn:SetPoint("LEFT", previous, "RIGHT")
        end
        previous = btn
    end

    f:Show()
end

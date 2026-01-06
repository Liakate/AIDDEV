-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- #UI/CopyWindow.lua
-- @role: UI module
-- @purpose: Provide a scrollable, copy-friendly window for analyzer output.
-- @rules:
--   - Must not run analyzers directly.
--   - Must not modify project files.
--   - Must support syntax highlighting and metadata tooltips.
-- @good:
--   - Clean, relative layout with no XY offsets.
-- @bad:
--   - Avoid embedding analysis logic here.

local Addon = _G.AIDDEV
Addon.UI = Addon.UI or {}
local UI = Addon.UI

------------------------------------------------------------
-- Syntax Highlighting
------------------------------------------------------------
local function HighlightLua(text)
    -- Comments
    text = text:gsub("(%-%-.-)\n", "|cff7f7f7f%1|r\n")

    -- Strings
    text = text:gsub("([\"'])(.-)%1", "|cffce9178%1%2%1|r")

    -- Keywords
    local keywords = {
        "function", "end", "local", "return", "if", "then", "elseif", "else",
        "for", "while", "repeat", "until", "not", "and", "or", "in", "do"
    }
    for _, kw in ipairs(keywords) do
        text = text:gsub("(%f[%a])("..kw..")(%f[^%a])", "%1|cff569cd6%2|r%3")
    end

    -- Numbers
    text = text:gsub("(%f[%d])(%d+)(%f[^%d])", "|cffb5cea8%2|r")

    -- Metadata keys
    text = text:gsub("(@%w+:)", "|cff4ec9b0%1|r")

    -- File header tags
    text = text:gsub("#([%w%/%._%-]+)", "|Hheader:%1|h|cffffff00#%1|r|h")

    return text
end

------------------------------------------------------------
-- Tooltip for metadata headers
------------------------------------------------------------
local function ShowHeaderTooltip(link)
    local meta = Addon.Core.MetadataCache and Addon.Core.MetadataCache[link]
    if not meta then return end

    GameTooltip:SetOwner(UI.CopyWindow, "ANCHOR_CURSOR")
    GameTooltip:AddLine("File: " .. meta.path)

    if meta.role then
        GameTooltip:AddLine("Role: " .. meta.role)
    end

    if meta.purpose then
        GameTooltip:AddLine("Purpose: " .. meta.purpose)
    end

    if meta.rules and #meta.rules > 0 then
        GameTooltip:AddLine("Rules:")
        for _, r in ipairs(meta.rules) do
            GameTooltip:AddLine("  • " .. r, 1, 1, 1)
        end
    end

    if meta.good and #meta.good > 0 then
        GameTooltip:AddLine("Good practice:")
        for _, g in ipairs(meta.good) do
            GameTooltip:AddLine("  • " .. g, 0.6, 1, 0.6)
        end
    end

    if meta.bad and #meta.bad > 0 then
        GameTooltip:AddLine("Bad practice:")
        for _, b in ipairs(meta.bad) do
            GameTooltip:AddLine("  • " .. b, 1, 0.6, 0.6)
        end
    end

    GameTooltip:Show()
end

------------------------------------------------------------
-- Create Copy Window
------------------------------------------------------------
function UI.CreateCopyWindow()
    if UI.CopyWindow then return end

    local f = CreateFrame("Frame", "AIDDEV_CopyWindow", UIParent, "BackdropTemplate")
    f:SetSize(600, 400)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.85)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetResizable(true)
    f:SetMinResize(300, 150)
    table.insert(UISpecialFrames, "AIDDEV_CopyWindow")

    UI.CopyWindow = f

    ------------------------------------------------------------
    -- Title
    ------------------------------------------------------------
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP")
    title:SetText("AIDDEV – Test Output")
    f.title = title

    ------------------------------------------------------------
    -- Close Button
    ------------------------------------------------------------
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT")
    f.closeButton = close

    ------------------------------------------------------------
    -- Scroll Frame
    ------------------------------------------------------------
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOP", title, "BOTTOM")
    scroll:SetPoint("BOTTOM", f, "BOTTOM")
    scroll:SetPoint("LEFT", f, "LEFT")
    scroll:SetPoint("RIGHT", f, "RIGHT")
    f.scrollFrame = scroll

    scroll.ScrollBar:Hide()

    ------------------------------------------------------------
    -- Edit Box
    ------------------------------------------------------------
    local editBox = CreateFrame("EditBox", nil, scroll)
    editBox:SetMultiLine(true)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetAutoFocus(false)
    editBox:SetWidth(550)
    editBox:SetScript("OnEscapePressed", function() f:Hide() end)

    scroll:SetScrollChild(editBox)
    f.editBox = editBox

    ------------------------------------------------------------
    -- Resize / Move
    ------------------------------------------------------------
    f:SetScript("OnMouseDown", function(frame, button)
        if button == "LeftButton" then
            frame:StartMoving()
        elseif button == "RightButton" then
            frame:StartSizing()
        end
    end)

    f:SetScript("OnMouseUp", function(frame)
        frame:StopMovingOrSizing()
    end)

    f:SetScript("OnHide", function(frame)
        frame:StopMovingOrSizing()
    end)

    ------------------------------------------------------------
    -- Auto-resize edit box
    ------------------------------------------------------------
    scroll:SetScript("OnSizeChanged", function(sf)
        editBox:SetWidth(sf:GetWidth())
    end)

    ------------------------------------------------------------
    -- Auto-scroll to bottom
    ------------------------------------------------------------
    editBox:SetScript("OnTextChanged", function(_, userInput)
        if userInput then return end
        scroll:SetVerticalScroll(scroll:GetVerticalScrollRange())
    end)

    ------------------------------------------------------------
    -- Metadata tooltip
    ------------------------------------------------------------
    editBox:SetScript("OnHyperlinkEnter", function(_, link)
        ShowHeaderTooltip(link)
    end)

    editBox:SetScript("OnHyperlinkLeave", function()
        GameTooltip:Hide()
    end)
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------
function UI.ShowCopyWindow(text)
    UI.CreateCopyWindow()
    local f = UI.CopyWindow
    f.editBox:SetText(HighlightLua(text or ""))
    f.editBox:HighlightText()
    f:Show()
end

-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- UI/ProjectBrowser.lua
-- Displays project files and their contents.

local Loader = AIDDEV_Loader

local Browser = {}
AIDDEV_ProjectBrowser = Browser

local selectedFile = nil

function Browser:Refresh()
    local frame = AIDDEVProjectBrowserFrame
    if not frame then return end

    local project = Loader:GetCurrentProject()
    if not project then
        self:SetFileListText("No project loaded.")
        self:SetContentText("")
        return
    end

    local fileList = {}
    for filename in pairs(project.files) do
        table.insert(fileList, filename)
    end
    table.sort(fileList)

    local listText = ""
    for _, filename in ipairs(fileList) do
        if filename == selectedFile then
            listText = listText .. "|cff00ff00> " .. filename .. "|r\n"
        else
            listText = listText .. filename .. "\n"
        end
    end

    self:SetFileListText(listText)

    if selectedFile then
        self:SetContentText(project.files[selectedFile].content or "")
    else
        self:SetContentText("")
    end
end

function Browser:SetFileListText(text)
    local frame = AIDDEVProjectBrowserFrame
    if not frame.fileListText then
        local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        frame.fileListText = fs
        frame.FileScroll:SetScrollChild(fs)
    end
    frame.fileListText:SetText(text)
end

function Browser:SetContentText(text)
    local frame = AIDDEVProjectBrowserFrame
    if not frame.contentText then
        local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        frame.contentText = fs
        frame.ContentScroll:SetScrollChild(fs)
    end
    frame.contentText:SetText(text)
end

function Browser:SelectFile(filename)
    selectedFile = filename
    self:Refresh()
end

function AIDDEV_ProjectBrowser_OnLoad(frame)
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)

    AIDDEV_ProjectBrowser:Refresh()
end

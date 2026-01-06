local SlashDiagnostics = {}

function SlashDiagnostics:Build(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetAllPoints()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Slash Diagnostics")

    local body = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    body:SetJustifyH("LEFT")
    f.body = body

    self.frame = f
    self:Refresh()
    return f
end

function SlashDiagnostics:Refresh()
    if SlashCmdList and SlashCmdList["AIDDEV"] then
        self.frame.body:SetText("|cff00ff00/aiddev is registered and available.|r")
    else
        self.frame.body:SetText("|cffffaa00/aiddev is NOT registered.\n\nPossible causes:\n- Slash registered in XML OnLoad\n- Lifecycle initialization skipped\n- UI never instantiated")
    end
end

return SlashDiagnostics

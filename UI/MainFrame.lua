-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- UI/MainFrame.lua

local Main = {}
AIDDEV_MainUI = Main

function Main:Show()
    if not AIDDEVMainFrame then return end
    AIDDEVMainFrame:Show()
    self:UpdateEnvironmentBanner()
    self:SelectTab("static")
end

function Main:Hide()
    if not AIDDEVMainFrame then return end
    AIDDEVMainFrame:Hide()
end

function Main:Toggle()
    if AIDDEVMainFrame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function Main:SelectTab(tabId)
    AIDDEVMainFrame.StaticPanel:Hide()
    AIDDEVMainFrame.RuntimePanel:Hide()

    if tabId == "static" then
        AIDDEVMainFrame.StaticPanel:Show()
    elseif tabId == "runtime" then
        AIDDEVMainFrame.RuntimePanel:Show()
        if AIDDEV_RuntimeCompare and AIDDEV_RuntimeDiagnosticsUI then
            AIDDEV_RuntimeCompare:Run()
            AIDDEV_RuntimeDiagnosticsUI:Refresh()
        end
    end

    PanelTemplates_SetTab(AIDDEVMainFrame, tabId == "static" and 1 or 2)
end

function Main:UpdateEnvironmentBanner()
    local env = AIDDEV_Loader:GetEnvironment()
    local banner = AIDDEVMainFrame.EnvBanner
    if not banner then return end

    banner:SetText(string.format(
        "Environment: Realm=%s  |  Ruleset=%s  |  Build=%s",
        env.realm or "?", env.ruleset or "?", tostring(env.clientBuild or "?")
    ))
end

function AIDDEV_Main_RunDevTools()
    if AIDDEV_DevTools and AIDDEV_DevTools.RunAll then
        AIDDEV_DevTools:RunAll()
        AIDDEV_DevTools_ToggleFrame()
    else
        print("|cffff0000AIDDEV: DevTools not found.|r")
    end
end

function AIDDEV_Main_OnLoad(frame)
    PanelTemplates_SetNumTabs(frame, 2)
    PanelTemplates_SetTab(frame, 1)

    SLASH_AIDDEV1 = "/aiddev"
    SlashCmdList["AIDDEV"] = function(msg)
        AIDDEV_MainUI:Toggle()
    end

    AIDDEV_MainUI:UpdateEnvironmentBanner()
end

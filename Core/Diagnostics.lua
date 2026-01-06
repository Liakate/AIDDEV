-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- Core/Diagnostics.lua
-- Minimal placeholder for static diagnostics system.
-- In your real code, this would contain rule engines, error taxonomies, etc.

local Diagnostics = {}
AIDDEV_Diagnostics = Diagnostics

Diagnostics.issues = {}

function Diagnostics:AddIssue(issue)
    table.insert(self.issues, issue)
end

function Diagnostics:GetIssues()
    return self.issues
end

function Diagnostics:Reset()
    self.issues = {}
end

return Diagnostics

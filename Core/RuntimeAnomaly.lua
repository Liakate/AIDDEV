-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- Core/RuntimeAnomaly.lua
-- Stable, filtered, UI-friendly view of runtime findings.

local Compare = AIDDEV_RuntimeCompare

local Anomaly = {}
AIDDEV_RuntimeAnomaly = Anomaly

local SEVERITY_LEVEL = {
    low    = 1,
    medium = 2,
    high   = 3,
}

function Anomaly:GetAll()
    return Compare:GetFindings() or {}
end

function Anomaly:GetBySeverity(minSeverity)
    local minLevel = SEVERITY_LEVEL[minSeverity] or 1
    local out = {}

    for _, f in ipairs(Compare:GetFindings() or {}) do
        local level = SEVERITY_LEVEL[f.severity] or 1
        if level >= minLevel then
            table.insert(out, f)
        end
    end

    return out
end

function Anomaly:GetByKind(kind)
    local out = {}
    for _, f in ipairs(Compare:GetFindings() or {}) do
        if f.kind == kind then
            table.insert(out, f)
        end
    end
    return out
end

function Anomaly:GetGroupedByFunction()
    local groups = {}
    for _, f in ipairs(Compare:GetFindings() or {}) do
        local id = f.id or "unknown"
        groups[id] = groups[id] or {}
        table.insert(groups[id], f)
    end
    return groups
end

return Anomaly

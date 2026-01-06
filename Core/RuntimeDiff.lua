-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- Core/RuntimeDiff.lua
-- Compares two runtime snapshots.

local Diff = {}
AIDDEV_RuntimeDiff = Diff

function Diff:CompareSnapshots(before, after)
    local changes = {}

    -- Added or changed
    for id, now in pairs(after or {}) do
        local prev = before and before[id]
        if not prev then
            table.insert(changes, {
                id      = id,
                kind    = "new-function",
                message = string.format("New monitored function: %s (calls=%d)", id, now.count),
            })
        else
            if now.count ~= prev.count or now.errors ~= prev.errors then
                table.insert(changes, {
                    id      = id,
                    kind    = "changed-stats",
                    message = string.format(
                        "Function %s: calls %d→%d, errors %d→%d",
                        id, prev.count, now.count, prev.errors, now.errors
                    ),
                })
            end
        end
    end

    -- Removed
    for id, prev in pairs(before or {}) do
        if not (after and after[id]) then
            table.insert(changes, {
                id      = id,
                kind    = "removed-function",
                message = string.format("Function removed: %s (was calls=%d)", id, prev.count),
            })
        end
    end

    return changes
end

return Diff

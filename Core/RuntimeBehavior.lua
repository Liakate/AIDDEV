-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- Core/RuntimeBehavior.lua
-- Records runtime behavior of hooked functions.

local Behavior = {}
AIDDEV_RuntimeBehavior = Behavior

Behavior.calls = {}   -- [id] = { count, errors, argCounts, lastError, meta, ... }

local function make_id(owner, key, meta)
    local ownerName = meta and meta.ownerName or tostring(owner)
    local kind      = meta and meta.kind      or "generic"
    return string.format("%s::%s::%s", kind, ownerName, key)
end

function Behavior:RecordCall(owner, key, fn, meta, args)
    local id = make_id(owner, key, meta)
    local rec = self.calls[id]
    if not rec then
        rec = {
            id        = id,
            owner     = owner,
            key       = key,
            kind      = meta and meta.kind,
            source    = meta and meta.source,
            filename  = meta and meta.filename,
            funcName  = meta and meta.funcName,
            meta      = meta,
            count     = 0,
            errors    = 0,
            argCounts = {},
            lastArgs  = nil,
            lastCallTime = GetTime and GetTime() or 0,
        }
        self.calls[id] = rec
    end

    rec.count = rec.count + 1
    local argc = #args
    rec.argCounts[argc] = (rec.argCounts[argc] or 0) + 1
    rec.lastArgs = args
    rec.lastCallTime = GetTime and GetTime() or rec.lastCallTime
end

function Behavior:RecordError(owner, key, fn, meta, err)
    local id = make_id(owner, key, meta)
    local rec = self.calls[id]
    if not rec then
        rec = {
            id        = id,
            owner     = owner,
            key       = key,
            kind      = meta and meta.kind,
            source    = meta and meta.source,
            filename  = meta and meta.filename,
            funcName  = meta and meta.funcName,
            meta      = meta,
            count     = 0,
            errors    = 0,
            argCounts = {},
        }
        self.calls[id] = rec
    end

    rec.errors = rec.errors + 1
    rec.lastError = tostring(err)
end

function Behavior:GetAll()
    return self.calls
end

function Behavior:Reset()
    self.calls = {}
end

-- Deep copy of current calls table
function Behavior:ExportSnapshot()
    local copy = {}
    for id, rec in pairs(self.calls) do
        local c = {}
        for k, v in pairs(rec) do
            if type(v) == "table" then
                local t = {}
                for k2, v2 in pairs(v) do t[k2] = v2 end
                c[k] = t
            else
                c[k] = v
            end
        end
        copy[id] = c
    end
    return copy
end

-- Serialize a snapshot into Lua text for clipboard export
function Behavior:SerializeSnapshot(snapshot)
    snapshot = snapshot or self:ExportSnapshot()
    local out = {}

    table.insert(out, "AIDDEV_RUNTIME_SNAPSHOT = {")
    for id, rec in pairs(snapshot) do
        table.insert(out, string.format("  [%q] = {", id))
        table.insert(out, string.format("    count = %d,", rec.count or 0))
        table.insert(out, string.format("    errors = %d,", rec.errors or 0))
        table.insert(out, "    argCounts = {")
        for argc, cnt in pairs(rec.argCounts or {}) do
            table.insert(out, string.format("      [%d] = %d,", argc, cnt))
        end
        table.insert(out, "    },")
        table.insert(out, "  },")
    end
    table.insert(out, "}")
    return table.concat(out, "\n")
end

return Behavior

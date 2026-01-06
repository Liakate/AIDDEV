-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- Core/RuntimeCompare.lua
-- Compares static AST expectations with runtime behavior.

local Loader   = AIDDEV_Loader
local Ast      = AIDDEV_Ast
local Behavior = AIDDEV_RuntimeBehavior

local Compare = {}
AIDDEV_RuntimeCompare = Compare

Compare.findings = {}

local function describe_arg_counts(argCounts)
    local parts = {}
    for argc, count in pairs(argCounts) do
        table.insert(parts, string.format("%d args (%d calls)", argc, count))
    end
    table.sort(parts)
    return table.concat(parts, ", ")
end

local function add_finding(list, kind, severity, id, message, extra)
    table.insert(list, {
        kind     = kind,
        severity = severity,
        id       = id,
        message  = message,
        extra    = extra,
    })
end

local function infer_expected_argc_from_ast(rec, signatures)
    local meta = rec.meta or {}
    local filename = meta.filename
    local funcName = meta.funcName or rec.key

    if not filename or not funcName then return nil end
    local fileSigs = signatures[filename]
    if not fileSigs then return nil end
    local sig = fileSigs[funcName]
    if not sig then return nil end

    return sig.argc, sig.args
end

function Compare:Run()
    self.findings = {}

    local project = Loader:GetCurrentProject()
    if not project then return nil, "No project loaded" end

    local signatures = Ast:InferHandlerSignatures(project)
    local calls = Behavior:GetAll()

    for id, rec in pairs(calls) do
        -- 1) Runtime errors
        if rec.errors > 0 then
            add_finding(self.findings, "runtime-error", "high", id,
                string.format("Function %s has %d runtime errors. Last: %s",
                    id, rec.errors, rec.lastError or "?"),
                rec)
        end

        -- 2) Signature mismatch
        local observedDesc = describe_arg_counts(rec.argCounts)
        local expectedArgc, expectedArgs = infer_expected_argc_from_ast(rec, signatures)

        if expectedArgc then
            if not rec.argCounts[expectedArgc] then
                add_finding(self.findings, "signature-mismatch", "medium", id,
                    string.format("Expected %d args (%s), observed: %s",
                        expectedArgc, table.concat(expectedArgs or {}, ", "),
                        observedDesc),
                    rec)
            end
        else
            -- 3) Pure runtime anomaly
            local distinct = 0
            for _ in pairs(rec.argCounts) do distinct = distinct + 1 end
            if distinct > 1 then
                add_finding(self.findings, "arg-pattern-anomaly", "low", id,
                    "Function called with varying argument counts: " .. observedDesc,
                    rec)
            end
        end
    end

    return self.findings
end

function Compare:GetFindings()
    return self.findings
end

return Compare

-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local JsonExport = {}

-- Convert a single diagnostic payload into a UI-friendly JSON entry.
function JsonExport.to_ui_entry(uri, payload, severity)
    local range = {
        start = {
            line = payload.start_line or 0,
            character = payload.start_char or 0,
        },
        ["end"] = {
            line = payload.finish_line or payload.start_line or 0,
            character = payload.finish_char or payload.start_char or 0,
        },
    }

    return {
        file = uri,
        code = payload.code,
        message = payload.message,
        severity = severity or payload.severity or "Warning",
        range = range,
        aiddev = payload.aiddev or {},
    }
end

-- Convert a list of diagnostics for a file into a JSON-serializable array.
function JsonExport.to_ui_file_block(uri, diagnostics, severity_map)
    local out = {}
    for _, d in ipairs(diagnostics) do
        local sev = severity_map and severity_map[d.code] or d.severity
        out[#out + 1] = JsonExport.to_ui_entry(uri, d, sev)
    end
    return out
end

return JsonExport

-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
local plugin = {}

function plugin:OnTransformAst(uri, ast)
    -- Reserved for future AST transforms
end

if not QUIET then
    print("Loaded AIDDEV MessageProtocol plugin")
end

return plugin

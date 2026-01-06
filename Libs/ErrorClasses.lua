-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
---@meta

-- AIDDEV's diagnostic taxonomy.
-- Each error class includes mechanical explanation, why it fails, and mitigation.

local ErrorClasses = {
    AIDDEV_UNKNOWN_EVENT = {
        id = "AIDDEV_UNKNOWN_EVENT",
        mechanical = "An event name is used that is not recognized in the event prototype database.",
        why = "Registering a non-existent event is a logic bug and usually indicates a typo or version mismatch.",
        mitigation = "Verify the event name against WoW's event list or update your event prototypes.",
    },

    AIDDEV_BAD_EVENT_HANDLER_SIGNATURE = {
        id = "AIDDEV_BAD_EVENT_HANDLER_SIGNATURE",
        mechanical = "A handler’s parameter list does not match the expected event argument shape (including self).",
        why = "Lua will still call the handler, but parameters may be nil or shifted, causing subtle logic bugs.",
        mitigation = "Align handler parameters with the event prototype, including self as the first parameter.",
    },

    AIDDEV_MESSAGE_SENT_BUT_NOT_HANDLED = {
        id = "AIDDEV_MESSAGE_SENT_BUT_NOT_HANDLED",
        mechanical = "A literal message string is sent but never checked in any known message handler.",
        why = "Peers may receive messages that are never acted upon, indicating dead or incomplete protocol logic.",
        mitigation = "Implement a handler for this message or remove the send if it is obsolete.",
    },

    AIDDEV_MESSAGE_HANDLED_BUT_NOT_SENT = {
        id = "AIDDEV_MESSAGE_HANDLED_BUT_NOT_SENT",
        mechanical = "A message handler checks for a literal string that is never sent anywhere.",
        why = "This condition will never be true in practice, suggesting dead code or a missing send path.",
        mitigation = "Add the corresponding send call, or remove/adjust the handler if the message is no longer used.",
    },
}

return ErrorClasses

public class CaseTriggerHandler {

    public static void handleTrigger(TriggerContext context) {
        if (context.isBefore) {
            if (context.isInsert) {
                handleBeforeInsert(context.newRecords);
            }
            if (context.isUpdate) {
                handleBeforeUpdate(context.oldMapRecords, context.newRecords);
            }
        }
    }

    private static void handleBeforeInsert(List<Case> newCases) {
        if (newCases != null && !newCases.isEmpty()) {
            CaseDuplicateCheck.checkForDuplicateCase(null, newCases);
        }
    }

    private static void handleBeforeUpdate(Map<Id, Case> oldMapCases, List<Case> newCases) {
        if (oldMapCases != null && !oldMapCases.isEmpty() && newCases != null && !newCases.isEmpty()) {
            CaseDuplicateCheck.checkForDuplicateCase(oldMapCases, newCases);
        }
    }
}

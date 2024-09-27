trigger CaseTrigger on Case (before insert, before update) {

    TriggerContext context = new TriggerContext(Trigger.isBefore, Trigger.isInsert, Trigger.isUpdate, Trigger.new, Trigger.oldMap);

    CaseTriggerHandler.handleTrigger(context);
}
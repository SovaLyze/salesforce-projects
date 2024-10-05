trigger UpdateParentSumTrigger on ChildObject__c (after insert, after update, after delete, after undelete) {
    ChildObjectTriggerHandler.handleTrigger(Trigger.new, Trigger.old, Trigger.operationType);
}
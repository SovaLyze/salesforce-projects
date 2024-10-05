public class ChildObjectTriggerHandler {
    public static void handleTrigger(List<ChildObject__c> newRecords, List<ChildObject__c> oldRecords, TriggerOperation operationType) {
        if (operationType == TriggerOperation.AFTER_INSERT || operationType == TriggerOperation.AFTER_UPDATE || operationType == TriggerOperation.AFTER_DELETE || operationType == TriggerOperation.AFTER_UNDELETE) {
            Set<Id> parentIds = new Set<Id>();

            System.debug('newRecords >> ' + newRecords);

            for (ChildObject__c childRecord : newRecords) {
                parentIds.add(childRecord.ParentObject__c);
            }

            System.debug('parentIds >> ' + parentIds);

            if (!parentIds.isEmpty()) {
                updateParentSum(parentIds);
                updateParentAverage(parentIds);
                checkUniqueNames(parentIds);
            }
        }
    }

    @TestVisible
    private static void updateParentSum(Set<Id> parentIds) {
        List<ParentObject__c> parentRecords = [SELECT Id, TotalAmount__c, (SELECT Id, Amount__c FROM ChildObjects__r) FROM ParentObject__c WHERE Id IN :parentIds];

        for (ParentObject__c parentRecord : parentRecords) {
            Decimal sum = 0;

            System.debug('parentRecord >>' + parentRecord);

            for (ChildObject__c childRecord : parentRecord.ChildObjects__r) {
                sum += childRecord.Amount__c;
            }

            parentRecord.TotalAmount__c = sum;
        }

        update parentRecords;
    }

    @TestVisible
    private static void updateParentAverage(Set<Id> parentIds) {
        List<ParentObject__c> parentRecords = [SELECT Id, AverageAmount__c, (SELECT Id, Amount__c FROM ChildObjects__r) FROM ParentObject__c WHERE Id IN :parentIds];

        for (ParentObject__c parentRecord : parentRecords) {
            Decimal sum = 0;

            for (ChildObject__c childRecord : parentRecord.ChildObjects__r) {
                sum += childRecord.Amount__c;
            }

            // TODO: Реалізуйте обчислення середнього значення та оновлення поля AverageAmount__c на батьківському записі
            parentRecord.AverageAmount__c = sum / parentRecord.ChildObjects__r.size();

            System.debug('parentRecord.AverageAmount__c >>' + parentRecord.AverageAmount__c);

            // TODO: Оновіть батьківський запис
            update parentRecords;
        }
    }

    @TestVisible
    private static void checkUniqueNames(Set<Id> parentIds) {
        List<ParentObject__c> parentRecords = [SELECT Id, DuplicateNames__c, (SELECT Id, Name FROM ChildObjects__r) FROM ParentObject__c WHERE Id IN :parentIds];

        for (ParentObject__c parentRecord : parentRecords) {
            Set<String> existingNames = new Set<String>();
            Set<String> uniqueNames = new Set<String>();

            for (ChildObject__c childRecord : parentRecord.ChildObjects__r) {

                if (existingNames.contains(childRecord.Name)) {
                    parentRecord.DuplicateNames__c = (parentRecord.DuplicateNames__c != null ? parentRecord.DuplicateNames__c + ';' : '') + childRecord.Name;
                } else {
                    if (uniqueNames.contains(childRecord.Name)) {
                        parentRecord.DuplicateNames__c = (parentRecord.DuplicateNames__c != null ? parentRecord.DuplicateNames__c + ';' : '') + childRecord.Name;
                    } else {
                        uniqueNames.add(childRecord.Name);
                        existingNames.add(childRecord.Name);
                    }
                }
                

                System.debug('existingNames >>' + existingNames);
            }

            if (parentRecord.DuplicateNames__c != null) {
                update parentRecord;
            }
        }
    }
}
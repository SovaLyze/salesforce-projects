public with sharing class CaseDuplicateCheck {
    public static void checkForDuplicateCase(Map<Id, Case> oldMapCase, List<Case> newListCase) {
        Map<String, Case> newCaseMap = new Map<String, Case>();

        for (Case newCase : newListCase) {
            if (isDuplicateCaseCheckNeeded(oldMapCase, newCase)) {
                if(newCaseMap.containsKey(newCase.Subject)) {
                    newCase.Subject.addError('There can only be one case with subjet of: ' + newCase.Subject);
                } else {
                    newCaseMap.put(newCase.Subject, newCase);
                }
            }
        }

        if(!newCaseMap.isEmpty()) {

            List<Case> listOfCaseFromDB = [SELECT Id, Subject FROM Case WHERE Status != 'Closed' AND Subject IN : newCaseMap.keySet() WITH USER_MODE];
            
            for (Case caseFromDB : listOfCaseFromDB) {
                Case newCase = newCaseMap.get(caseFromDB.Subject);

                if (newCase != null && newCase.Id != caseFromDB.Id) {
                    newCase.Subject.addError('A Case with the same Subject alredy exists. Case Id: ' + caseFromDB.Id);
                }
            }
        }
    }

    private static Boolean isDuplicateCaseCheckNeeded(Map<Id, Case> oldMapCase, Case newCase) {
       
        if (String.isNotBlank(newCase.Subject) && newCase.Status != 'Closed') {
            return 
                (oldMapCase == null || oldMapCase.isEmpty()) ||
                oldMapCase.get(newCase.Id).Subject != newCase.Subject;
            
        }

        return false;
    }
}
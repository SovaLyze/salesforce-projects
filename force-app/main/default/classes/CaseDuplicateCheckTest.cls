@isTest
public class CaseDuplicateCheckTest {

    @testSetup
    static void setupTestData() {
        List<Case> cases = new List<Case>();
        cases.add(new Case(Subject = 'Test Case 1', Status = 'New'));
        cases.add(new Case(Subject = 'Test Case 2', Status = 'Working'));
        cases.add(new Case(Subject = 'Test Case 3', Status = 'Closed'));

        insert cases;
    }

    @isTest
    static void testCheckForDuplicateCase_Insert() {
        List<Case> newCases = new List<Case>();
        newCases.add(new Case(Subject = 'Test Case 1', Status = 'New'));
        newCases.add(new Case(Subject = 'Test Case 4', Status = 'New'));
    
        Test.startTest();
        
        Database.SaveResult[] results = Database.insert(newCases, false);
        
        Test.stopTest();
    
        System.assert(!results[0].isSuccess(), 'Expected error on duplicate subject for first case');
        
        System.assert(results[1].isSuccess(), 'Expected second case to insert successfully');
    }

    @isTest
    static void testCheckForDuplicateCase_Update() {
        List<Case> existingCases = [SELECT Id, Subject, Status FROM Case WHERE Subject = 'Test Case 2'];
        
        Case caseToUpdate = existingCases[0];
        caseToUpdate.Subject = 'Test Case 1';

        Map<Id, Case> oldMap = new Map<Id, Case>(existingCases);

        Test.startTest();
        try {
            CaseDuplicateCheck.checkForDuplicateCase(oldMap, new List<Case>{ caseToUpdate });
            update caseToUpdate;
            System.assert(false, 'Should have thrown an exception');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('A Case with the same Subject alredy exists.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testCheckForDuplicateCase_NoDuplicates() {
        List<Case> newCases = new List<Case>();
        newCases.add(new Case(Subject = 'Unique Case 1', Status = 'New'));
        newCases.add(new Case(Subject = 'Unique Case 2', Status = 'New'));

        Test.startTest();
        Database.SaveResult[] results = Database.insert(newCases, false);
        Test.stopTest();

        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess(), 'Insert failed when it should have succeeded.');
        }
    }
}

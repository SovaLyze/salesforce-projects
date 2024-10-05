/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ChildObjectTriggerHandlerTest {

    @isTest
    static void testUpdateParentSum() {
        
        ParentObject__c parent = new ParentObject__c();
        parent.Name = 'Test Parent';
        insert parent;

        ChildObject__c recordChild1 = new ChildObject__c();
        recordChild1.ParentObject__c = parent.Id;
        recordChild1.Amount__c = 100;

        ChildObject__c recordChild2 = new ChildObject__c();
        recordChild2.ParentObject__c = parent.Id;
        recordChild2.Amount__c = 200;

        insert new List<ChildObject__c>{recordChild1, recordChild2};

        Test.startTest();
            ChildObjectTriggerHandler.updateParentSum(new Set<Id>{parent.Id});
        Test.stopTest();
        
        ParentObject__c updateParent = [SELECT Id, TotalAmount__c FROM ParentObject__c WHERE Id =: parent.Id];
        System.assertEquals(300, updateParent.TotalAmount__c, 'TotalAmount__c should be the sum of child amounts');
    }

    @isTest
    static void testUpdateParentAverage() {
        
        ParentObject__c parent = new ParentObject__c();
        parent.Name = 'Test Parent';
        insert parent;

        ChildObject__c recordChild1 = new ChildObject__c();
        recordChild1.ParentObject__c = parent.Id;
        recordChild1.Amount__c = 100;

        ChildObject__c recordChild2 = new ChildObject__c();
        recordChild2.ParentObject__c = parent.Id;
        recordChild2.Amount__c = 200;

        insert new List<ChildObject__c>{recordChild1, recordChild2};

        Test.startTest();
            ChildObjectTriggerHandler.updateParentAverage(new Set<Id>{parent.Id});
        Test.stopTest();
        
        ParentObject__c updateParent = [SELECT Id, AverageAmount__c FROM ParentObject__c WHERE Id =: parent.Id];
        System.assertEquals(150, updateParent.AverageAmount__c, 'AverageAmount__c should be the average of child amounts');
    }

    @isTest
    static void testCheckUniqueNames() {

        ParentObject__c parent = new ParentObject__c();
        parent.Name = 'Test Parent';
        insert parent;

        ChildObject__c child1 = new ChildObject__c();
        child1.ParentObject__c = parent.Id;
        child1.Name = 'UniqueName';
        
        ChildObject__c child2 = new ChildObject__c();
        child2.ParentObject__c = parent.Id;
        child2.Name = 'DuplicateName';

        ChildObject__c child3 = new ChildObject__c();
        child3.ParentObject__c = parent.Id;
        child3.Name = 'DuplicateName';

        insert new List<ChildObject__c>{child1, child2, child3};

        Test.startTest();
            ChildObjectTriggerHandler.checkUniqueNames(new Set<Id>{parent.Id});
        Test.stopTest();

        ParentObject__c updatedParent = [SELECT Id, DuplicateNames__c FROM ParentObject__c WHERE Id = :parent.Id];
        System.assertEquals('DuplicateName', updatedParent.DuplicateNames__c, 'DuplicateNames__c should contain the duplicate name');
    }
}
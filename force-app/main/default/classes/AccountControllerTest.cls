@IsTest
public class AccountControllerTest {

    // Utility method to create test data
    private static void createTestData() {
        // Select specific Users to assign as Owners (ensure these queries return only one user each)
        User owner1 = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        User owner2 = [SELECT Id FROM User WHERE IsActive = true AND Id != :owner1.Id LIMIT 1]; // Ensure different owner
        
        // Create Accounts with "Financial Services" industry
        Account acc1 = new Account(Name='Financial Services Company 1', Industry='Financial Services', OwnerId=owner1.Id, Phone='1234567890', Website='http://company1.com', AnnualRevenue=5000000);
        Account acc2 = new Account(Name='Financial Services Company 2', Industry='Financial Services', OwnerId=owner2.Id, Phone='0987654321', Website='http://company2.com', AnnualRevenue=8000000);
        Account acc3 = new Account(Name='Financial Experts', Industry='Financial Services', OwnerId=owner1.Id, Phone='1122334455', Website='http://experts.com', AnnualRevenue=1500000);
        
        // Create Account with a different industry (should not be fetched)
        Account acc4 = new Account(Name='Non Financial Company', Industry='Technology', OwnerId=owner2.Id, Phone='2233445566', Website='http://techcompany.com', AnnualRevenue=3000000);
        
        insert new List<Account>{ acc1, acc2, acc3, acc4 };
    }

    @IsTest
    static void testGetFinancialServicesAccounts_withSearchTerm() {
        // Setup test data
        createTestData();
        
        Test.startTest();
        // Call the method with a search term
        List<AccountController.AccountWrapper> accounts = AccountController.getFinancialServicesAccounts('Financial Experts', 'Name', 'asc');

        Test.stopTest();
        
        // Assert the result should return one account
        System.assertEquals(1, accounts.size(), 'Only one account should match the search term.');
        System.assertEquals('Financial Experts', accounts[0].Name, 'The returned account name should be "Financial Experts".');
    }

    @IsTest
    static void testGetFinancialServicesAccounts_withoutSearchTerm() {
        // Setup test data
        createTestData();

        Test.startTest();
        // Call the method without a search term
        List<AccountController.AccountWrapper> accounts = AccountController.getFinancialServicesAccounts(null, 'Name', 'asc');

        Test.stopTest();
        
        // Assert the result should return three accounts (only Financial Services accounts)
        System.assertEquals(3, accounts.size(), 'Three accounts should be returned with Industry "Financial Services".');
        System.assertEquals('Financial Experts', accounts[0].Name, 'The first account should be sorted by name.');
    }

    @IsTest
    static void testGetFinancialServicesAccounts_sortByOwner() {
        // Setup test data
        createTestData();

        Test.startTest();
        // Call the method to sort by Owner Name in descending order
        List<AccountController.AccountWrapper> accounts = AccountController.getFinancialServicesAccounts(null, 'OwnerName', 'desc');

        Test.stopTest();
        
        // Assert that the accounts are returned in descending order by Owner Name
        System.assert(accounts.size() > 0, 'At least one account should be returned.');
        System.assertEquals('Financial Services Company 1', accounts[0].Name, 'First account should belong to Owner 1 in descending order.');
    }

    @IsTest
    static void testGetFinancialServicesAccounts_emptyResults() {
        // No setup data in this test to simulate no matching records

        Test.startTest();
        // Call the method with a search term that should not match any records
        List<AccountController.AccountWrapper> accounts = AccountController.getFinancialServicesAccounts('Nonexistent Account', 'Name', 'asc');

        Test.stopTest();
        
        // Assert that no accounts are returned
        System.assertEquals(0, accounts.size(), 'No accounts should be returned for a non-matching search term.');
    }

    @IsTest
    static void testGetFinancialServicesAccounts_withNullSortField() {
        // Setup test data
        createTestData();

        Test.startTest();
        // Call the method with null sortBy and default sorting
        List<AccountController.AccountWrapper> accounts = AccountController.getFinancialServicesAccounts(null, null, 'asc');

        Test.stopTest();
        
        // Assert the result should return three accounts, sorted by default
        System.assertEquals(3, accounts.size(), 'Three accounts should be returned.');
    }
}

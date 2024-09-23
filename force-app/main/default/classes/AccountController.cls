public with sharing class AccountController {

    private static final String INDUSTRY_FINANCIAL_SERVICES = 'Financial Services';

    private static String customAccountProfileId;
    private static String systemAdminProfileId;

    static {
        customAccountProfileId = [SELECT Id FROM Profile WHERE Name = 'Custom Account Profile' LIMIT 1].Id;
        systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getFinancialServicesAccounts(String searchTerm, String sortBy, String sortDirection) {

        if (!isUserAllowedToAccess()) {
            throw new AuraHandledException('Access denied: You do not have permission to view financial services accounts.');
        }

        String query = 'SELECT Id, Name, Owner.Name, Phone, Website, AnnualRevenue FROM Account WHERE Industry = \'' + INDUSTRY_FINANCIAL_SERVICES + '\'';
        
        if (searchTerm != null && searchTerm != '') {
            query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }
        
        // Sorting logic
        if (sortBy != null) {
            if (sortBy == 'OwnerName') {
                query += ' ORDER BY Owner.Name ' + sortDirection; // Sorting by Owner.Name
            } else {
                query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            }
        }
        
        List<Account> accounts = Database.query(query);
        
        // Wrap the results to include Owner.Name
        List<AccountWrapper> wrappedAccounts = new List<AccountWrapper>();
        for (Account acc : accounts) {
            wrappedAccounts.add(new AccountWrapper(acc));
        }
        
        return wrappedAccounts;
    }

    private static Boolean isUserAllowedToAccess() {
        String currentProfileId = UserInfo.getProfileId();
        return currentProfileId == customAccountProfileId || currentProfileId == systemAdminProfileId;
    }

    // Wrapper class to include Owner.Name field
    public class AccountWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String OwnerName;
        @AuraEnabled public String Phone;
        @AuraEnabled public String Website;
        @AuraEnabled public Decimal AnnualRevenue;

        public AccountWrapper(Account account) {
            this.Id = account.Id;
            this.Name = account.Name;
            this.OwnerName = account.Owner.Name; // Get the owner's name
            this.Phone = account.Phone;
            this.Website = account.Website;
            this.AnnualRevenue = account.AnnualRevenue;
        }
    }
}

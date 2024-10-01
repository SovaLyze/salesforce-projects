public with sharing class CustomerService {

    public class AuthorizationException extends Exception {}
    
    @AuraEnabled(cacheable=true)
    public static List<CustomerDataWrapper> getCustomerData(){

        List<CustomerDataWrapper> cacheData = getCachedCustomerData();
        if (cacheData != null) {
            return cacheData;
        }

        validateObjectAccess();

        List<Customer__c> customers = fetchCustomers();
        List<CustomerDataWrapper> customerDataList = mapCustomerData(customers);

        Cache.OrgPartition cachePartition = Cache.Org.getPartition('CustomerPartition');
        cachePartition.put('CustomerDataCache', customerDataList, 3600);

        return customerDataList;
    }

    private static List<CustomerDataWrapper> getCachedCustomerData() {
        Cache.OrgPartition cachePartition = Cache.Org.getPartition('CustomerPartition');

        return (List<CustomerDataWrapper>) cachePartition.get('CustomerDataCache');
    }

    private static void validateObjectAccess() {
        if (!Schema.sObjectType.Customer__c.isAccessible()) {
            throw new AuthorizationException('Insufficient permissions to access Customer records.');
        }

        if (!Schema.sObjectType.Bank_Employee__c.isAccessible()) {
            throw new AuthorizationException('Insufficient permissions to access Banker records.');
        }
    }

    private static List<Customer__c> fetchCustomers() {
        return [
            SELECT Name, Account_Balance__c, Phone__c,
                Bank_Employee_ID__r.Name, Bank_Employee_ID__r.Phone__c, Bank_Employee_ID__r.Role__c
            FROM Customer__c
            WHERE (NAME != null)
            WITH SECURITY_ENFORCED
        ];
    }

    private static List<CustomerDataWrapper> mapCustomerData(List<Customer__c> customers) {
        customers = Security.stripInaccessible(AccessType.READABLE, customers).getRecords();

        List<CustomerDataWrapper> customerDataList = new List<CustomerDataWrapper>();

        Boolean isBankerNameAccessible = Schema.sObjectType.Bank_Employee__c.fields.Name.isAccessible();
        Boolean isBankerPhoneAccessible = Schema.sObjectType.Bank_Employee__c.fields.Phone__c.isAccessible();
        Boolean isBankerRoleAccessible = Schema.sObjectType.Bank_Employee__c.fields.Role__c.isAccessible();

        for (Customer__c customer : customers) {
            String bankerName = (customer.Bank_Employee_ID__r != null && isBankerNameAccessible) ? customer.Bank_Employee_ID__r.Name : null;
            String bankerPhone = (customer.Bank_Employee_ID__r != null && isBankerPhoneAccessible) ? customer.Bank_Employee_ID__r.Phone__c : null;
            String bankerRole = (customer.Bank_Employee_ID__r != null && isBankerRoleAccessible) ? customer.Bank_Employee_ID__r.Role__c : null;

            customerDataList.add(new CustomerDataWrapper(
                Schema.sObjectType.Customer__c.fields.Name.isAccessible() ? customer.Name : null,
                Schema.sObjectType.Customer__c.fields.Account_Balance__c.isAccessible() ? customer.Account_Balance__c : null,
                Schema.sObjectType.Customer__c.fields.Phone__c.isAccessible() ? customer.Phone__c : null,
                bankerName,
                bankerPhone,
                bankerRole
            ));
        }

        return customerDataList;

    }

    public class CustomerDataWrapper {
        @AuraEnabled public String customerName;
        @AuraEnabled public Decimal accountBalance;
        @AuraEnabled public String customerPhone;
        @AuraEnabled public String bankerName;
        @AuraEnabled public String bankerPhone;
        @AuraEnabled public String bankerRole;

        public CustomerDataWrapper(String customerName, Decimal accountBalance, String customerPhone, String bankerName, String bankerPhone, String bankerRole) {
            this.customerName = customerName;
            this.accountBalance = accountBalance;
            this.customerPhone = customerPhone;
            this.bankerName = bankerName;
            this.bankerPhone = bankerPhone;
            this.bankerRole = bankerRole;
        }
        
    }

}
@isTest
public class CWPUserInformationControllerTest{
    @TestSetup
    public static void dataSetup(){
        Contact con = new Contact();
        con.LastName = 'test';
        con.firstname = 'test2';
        insert con;
        
        Opportunity oppObj1 = New Opportunity();
        oppObj1.name = 'Test1';
        oppObj1.Requested_Shipping_Method__c = 'Priority Overnight';
        oppObj1.Primary_Contact__c = con.id;
        oppObj1.closeDate = system.today();
        oppobj1.Due_Date__c =  system.today().addDays(80);
        oppobj1.StageName = 'Ask for sale (7)';
        oppobj1.Signature_Required__c = true;
        oppobj1.Saturday_Delivery__c = true;
        oppobj1.of_Babies__c = 'Twins';
        oppobj1.PickUp_or_Ship_Kit__c = 'Ship';
        oppobj1.Requested_Shipping_Date__c = null;
        Insert oppObj1;
        
        OpportunityContactRole conRoleObj = New OpportunityContactRole();
        conRoleObj.IsPrimary = true;
        conRoleObj.contactId = con.id;
        conRoleObj.Role = 'Mother';
        conRoleObj.OpportunityId = oppobj1.id;
        Insert conRoleObj;
    } 
    @isTest
    public static void test1(){
        Contact con = [Select Id,Name,User_Name__c,Activation_Date__c,Last_Login_Date__c,Temporary_Password__c,Temporary_Password_Expiration__c,
                       Active__c,SCSS_Contact_Id__c From Contact Limit 1];
        PageReference pageRef = Page.CWPUserInformationPage;
        pageRef.getParameters().put('id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        CWPUserInformationController cwpController = new CWPUserInformationController(sc);
        cwpController.inactiveLoginBtn();
        List<Contact> conList = cwpController.getCWPUserInformation();
        
    }
}
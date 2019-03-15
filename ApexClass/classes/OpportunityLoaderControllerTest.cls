@isTest
public class OpportunityLoaderControllerTest{
    @isTest
    public static void unitTest(){
        /*Opportunity opp1 = new Opportunity(Name ='Test',stagename = 'won (9)',closedate = system.today(),Due_Date__c =  system.today().addDays(2));
        insert opp1;*/
        Opportunity opp1 = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        Insert opp1 ;
        
        Contact con = new contact();
        con.firstname = 'test6';
        con.lastName = 'Test';
        insert con;
        
        OpportunityContactRole conRoleObj = New OpportunityContactRole();
        conRoleObj.IsPrimary = true;
        conRoleObj.contactId = con.id;
        conRoleObj.OpportunityId = opp1.id;
        conRoleObj.Role = 'Mother';
        Insert conRoleObj;
        
        Contact con1 = new contact();
        con1.firstname = 'Test45';
        con1.lastName = 'Test';
        insert con1;
        
        OpportunityContactRole conRoleObj1 = New OpportunityContactRole();
        conRoleObj1.IsPrimary = false;
        conRoleObj1.contactId = con1.id;
        conRoleObj1.OpportunityId = opp1.id;
        conRoleObj1.Role = 'Mother';
        Insert conRoleObj1;
        system.debug(conRoleObj1);
        
       
        PageReference pageRef = Page.OpportunityDetail;
        Test.setCurrentPage(pageRef);

        //pageRef.getParameters().put('Id', String.valueOf(opp.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(opp1);
        opportunityLoaderController oppLoaderObj = new opportunityLoaderController(sc);
        opportunityLoaderController.setContactRole(opp1.id);
    }
}
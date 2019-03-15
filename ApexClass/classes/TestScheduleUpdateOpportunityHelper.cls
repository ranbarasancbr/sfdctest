@isTest
public class TestScheduleUpdateOpportunityHelper{
    @isTest
    public static void unitTest(){
        //list<opportunity> oppList = New List<opportunity>();
        Facility__c faciObj = New Facility__c();
        Insert faciObj;
        Provider__c provObj = New Provider__c();
        Insert provObj;
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'PickUp',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        oppobj.LeadSource = 'Phone';
        oppobj.Primary_Source__c = 'Article/News Story';
        oppobj.Delivering_Hospital__c = faciObj.Id;
        Insert oppobj;
       
        
        Opportunity_Provider__c oppProviderObj = new Opportunity_Provider__c();
        oppProviderObj.Provider__c = provObj.Id;
        oppProviderObj.Opportunity__c = oppobj.id;
        oppProviderObj.Primary_Provider__c = true;
        oppProviderObj.Facility__c = faciObj.id;
        insert oppProviderObj;
        
        Contact con = new contact();
        con.FirstName = 'Jhon';
        con.lastName = 'Test';
        insert con;
        
        OpportunityContactRole conRoleObj = New OpportunityContactRole();
        conRoleObj.IsPrimary = true;
        conRoleObj.contactId = con.id;
        conRoleObj.Role = 'Mother';
        conRoleObj.OpportunityId = oppobj.id;
        Insert conRoleObj;
        
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
        
    }
    @isTest
    public static void unitTest2(){
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'PickUp',closeDate = system.today(),status__C = 'Enrolled');
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
    @isTest
    public static void unitTest3(){
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'PickUp',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        
        oppobj.Primary_Source__c = 'Article/News Story';
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
    @isTest
    public static void unitTest4(){
        Facility__c faciObj = New Facility__c();
        Insert faciObj;
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'PickUp',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        oppobj.LeadSource = 'Phone';
        oppobj.Delivering_Hospital__c = faciObj.Id;
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
    @isTest
    public static void unitTest5(){
        Facility__c faciObj = New Facility__c();
        Insert faciObj;
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'N/A',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        oppobj.LeadSource = 'Phone';
        oppobj.Delivering_Hospital__c = faciObj.Id;
        oppobj.Primary_Source__c = 'Article/News Story';
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
    @isTest
    public static void unitTest6(){
        Facility__c faciObj = New Facility__c();
        Insert faciObj;
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        oppobj.LeadSource = 'Phone';
        oppobj.Delivering_Hospital__c = faciObj.Id;
        oppobj.Primary_Source__c = 'Article/News Story';
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
    @isTest
    public static void unitTest7(){
        Facility__c faciObj = New Facility__c();
        Insert faciObj;
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        oppobj.LeadSource = 'Phone';
        oppobj.Delivering_Hospital__c = faciObj.Id;
        oppobj.Primary_Source__c = 'Article/News Story';
        oppobj.Ship_To_Phone__c = '558878454';
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
    @isTest
    public static void unitTest8(){
        Facility__c faciObj = New Facility__c();
        Insert faciObj;
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        oppobj.LeadSource = 'Phone';
        oppobj.Delivering_Hospital__c = faciObj.Id;
        oppobj.Primary_Source__c = 'Article/News Story';
        oppobj.Ship_To_Phone__c = '558878454';
        oppobj.Shipping_Method__c = 'Second day';
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
    @isTest
    public static void unitTest9(){
        Facility__c faciObj = New Facility__c();
        Insert faciObj;
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        oppobj.LeadSource = 'Phone';
        oppobj.Delivering_Hospital__c = faciObj.Id;
        oppobj.Primary_Source__c = 'Article/News Story';
        oppobj.Ship_To_Phone__c = '558878454';
        oppobj.Shipping_Method__c = 'Second day';
        oppobj.Requested_Shipping_Date__c = system.today();
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
    @isTest
    public static void unitTest10(){
        Facility__c faciObj = New Facility__c();
        Insert faciObj;
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        oppobj.LeadSource = 'Phone';
        oppobj.Delivering_Hospital__c = faciObj.Id;
        oppobj.Primary_Source__c = 'Article/News Story';
        oppobj.Ship_To_Phone__c = '558878454';
        oppobj.Shipping_Method__c = 'Second day';
        oppobj.Requested_Shipping_Date__c = system.today();
        oppobj.Ship_To_Name__c = 'test';
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
    @isTest
    public static void unitTest11(){
        Facility__c faciObj = New Facility__c();
        Insert faciObj;
        
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        oppobj.LeadSource = 'Phone';
        oppobj.Delivering_Hospital__c = faciObj.Id;
        oppobj.Primary_Source__c = 'Article/News Story';
        oppobj.Ship_To_Phone__c = '558878454';
        oppobj.Shipping_Method__c = 'Second day';
        oppobj.Requested_Shipping_Date__c = system.today();
        oppobj.Ship_To_Name__c = 'test';
        oppobj.Ship_To_Street1__c = '1024 E Lemon St';
        oppobj.Ship_To_City__c = 'Tempe';
        oppobj.Ship_To_Zip_Code__c = '85281';
        oppobj.Ship_To_Country__c = 'United States';
        Insert oppobj;
        ScheduleUpdateOpportunityHelper.validateOpportunity(oppobj );
    }
}
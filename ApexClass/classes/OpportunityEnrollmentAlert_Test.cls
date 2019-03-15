@isTest
public class OpportunityEnrollmentAlert_Test{
    public static Account acc;
    public static list<Contact> contList;
    public static void setUpData(){
        
        acc = new Account();
        acc.Name = 'Testing Account';
        //Insert Account
        insert acc;
        contList= new List<Contact>();
        contList.add(new Contact(FirstName = 'Test1Contact',LastName = 'oneTest',Email = 'Test1Contact@oneTest.com',AccountId = acc.id));
        contList.add(new Contact(FirstName = 'Test2Contact',LastName = 'twoTest',Email = 'Test2Contact@twoTest.com',AccountId = acc.id));
        contList.add(new Contact(FirstName = 'Test3Contact',LastName = 'threeTest',Email = 'Test3Contact@threeTest.com',AccountId = acc.id));
        contList.add(new Contact(FirstName = 'Test4Contact',LastName = 'fourTest',Email = 'Test4Contact@fourTest.com',AccountId = acc.id));
        contList.add(new Contact(FirstName = 'Test5Contact',LastName = 'fiveTest',Email = 'Test5Contact@fiveTest.com',AccountId = acc.id));
        //Insert contact list
        insert contList;
    }
    public static testmethod void TestMethod1(){
        setUpData();
        test.startTest();
        //Test Records for condition Enrollment date is < current date && Storage date = Null && DueDate = CurrentDate+14 AND any of there fields are false Section_1_Received__c or Section_2_Received__c or Section_3_Received__c or Section_4_Received__c OR  Section_5_Received__c
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(Name = 'testOpp1',StageName = 'Overcoming Objections (6)',CloseDate = system.today(),AccountId = acc.id,Status__c = 'Open',Primary_Contact__c = contList[0].id,Section_1_Received__c = False,Section_2_Received__c = True,Section_3_Received__c = True,Section_4_Received__c = True,Section_5_Received__c = True,Primary_Source__c='I\'m a Current Client',of_Babies__c = 'Single',of_CB__c='1',of_CT__c='0',Payment_Method__c = 'Credit Card',Due_Date__c = system.Today().addDays(14),Enrollment_Date__c = system.today().addDays(-3),Storage_Date__c = null));
        oppList.add(new Opportunity(Name = 'testOpp2',StageName = 'Overcoming Objections (6)',CloseDate = system.today(),AccountId = acc.id,Status__c = 'Open',Primary_Contact__c = contList[1].id,Section_1_Received__c = true,Section_2_Received__c = false,Section_3_Received__c = True,Section_4_Received__c = True,Section_5_Received__c = True,Primary_Source__c='I\'m a Current Client',of_Babies__c = 'Single',of_CB__c='1',of_CT__c='0',Payment_Method__c = 'Credit Card',Due_Date__c =system.Today().addDays(14)  ,Enrollment_Date__c = system.today().addDays(-3),Storage_Date__c = null));
        oppList.add(new Opportunity(Name = 'testOpp3',StageName = 'Overcoming Objections (6)',CloseDate = system.today(),AccountId = acc.id,Status__c = 'Open',Primary_Contact__c = contList[2].id,Section_1_Received__c = true,Section_2_Received__c = True,Section_3_Received__c = false,Section_4_Received__c = True,Section_5_Received__c = True,Primary_Source__c='I\'m a Current Client',of_Babies__c = 'Single',of_CB__c='1',of_CT__c='0',Payment_Method__c = 'Credit Card',Due_Date__c = system.Today().addDays(14) ,Enrollment_Date__c = system.today().addDays(-3),Storage_Date__c = null));
        oppList.add(new Opportunity(Name = 'testOpp4',StageName = 'Overcoming Objections (6)',CloseDate = system.today(),AccountId = acc.id,Status__c = 'Open',Primary_Contact__c = contList[3].id,Section_1_Received__c = true,Section_2_Received__c = True,Section_3_Received__c = True,Section_4_Received__c = false,Section_5_Received__c = True,Primary_Source__c='I\'m a Current Client',of_Babies__c = 'Single',of_CB__c='1',of_CT__c='0',Payment_Method__c = 'Credit Card',Due_Date__c = system.Today().addDays(14) ,Enrollment_Date__c = system.today().addDays(-3),Storage_Date__c = null));
        oppList.add(new Opportunity(Name = 'testOpp5',StageName = 'Overcoming Objections (6)',CloseDate = system.today(),AccountId = acc.id,Status__c = 'Open',Primary_Contact__c = contList[4].id,Section_1_Received__c = TRUE,Section_2_Received__c = True,Section_3_Received__c = True,Section_4_Received__c = True,Section_5_Received__c = false ,Primary_Source__c='I\'m a Current Client',of_Babies__c = 'Single',of_CB__c='1',of_CT__c='0',Payment_Method__c = 'Credit Card',Due_Date__c =system.Today().addDays(14)  ,Enrollment_Date__c = system.today().addDays(-3) ,Storage_Date__c = null));
		//INsert opportunities
        insert oppList;
        
        List<OpportunityContactRole> oCRList = new List<OpportunityContactRole>();
        oCRList.add(new OpportunityContactRole(ContactId  =contList[0].id ,OpportunityId  = oppList[0].id,IsPrimary = TRUE,Role = 'Mother'));
        oCRList.add(new OpportunityContactRole(ContactId  =contList[1].id ,OpportunityId  = oppList[1].id,IsPrimary = TRUE,Role = 'Mother'));
        oCRList.add(new OpportunityContactRole(ContactId  =contList[2].id ,OpportunityId  = oppList[2].id,IsPrimary = TRUE,Role = 'Mother'));
        oCRList.add(new OpportunityContactRole(ContactId  =contList[3].id ,OpportunityId  = oppList[3].id,IsPrimary = TRUE,Role = 'Mother'));
        oCRList.add(new OpportunityContactRole(ContactId  =contList[4].id ,OpportunityId  = oppList[4].id,IsPrimary = TRUE,Role = 'Mother'));
        //Insert OpportunityContactRole
        insert oCRList;
        
        //Update opplist so primary contact field of opp will be updated
        update oppList;
        OpportunityEnrollmentAlert oEA = new OpportunityEnrollmentAlert();
        id batchId = Database.executeBatch(oEA);
       Test.stopTest();
}
    public static testmethod void TestMethod2(){
        setUpData();
        test.startTest();
        	Opportunity opp = new Opportunity(Name = 'testOpp5',StageName = 'Overcoming Objections (6)',CloseDate = system.today(),AccountId = acc.id,Status__c = 'Open',Primary_Contact__c = contList[4].id,Section_1_Received__c = TRUE,Section_2_Received__c = True,Section_3_Received__c = True,Section_4_Received__c = True,Section_5_Received__c = false ,Primary_Source__c='I\'m a Current Client',of_Babies__c = 'Single',of_CB__c='1',of_CT__c='0',Payment_Method__c = 'Credit Card',Due_Date__c =system.Today().addDays(14)  ,Enrollment_Date__c = system.today().addDays(-3) ,Storage_Date__c = null);
        //Insert Opportunity
        insert opp;
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId  =contList[4].id ,OpportunityId  = opp.id,IsPrimary = TRUE,Role = 'Mother');
        //Insert OpportunityOcntact Role
        insert ocr;
        
        update opp;
         OpportunityEnrollmentAlert oEA1 = new OpportunityEnrollmentAlert();
        oEA1.reSendEmails.put(contList[4].id,contList[4].Email);//adding value to reSendEmails map to coverage final method
        Database.executeBatch(oEA1);
        
        ScheduleOpportunityEnrollmentAlert obj = new ScheduleOpportunityEnrollmentAlert();
        obj.execute(null);
        Test.stopTest();
    }
}
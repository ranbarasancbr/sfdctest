/*************************************************************************************************************************
* Component Name: NewOpportunityControllerTest
* Description: Test class for NewOpportunityController
* DevelopedBy: TEKsystems
*****************************************************************************************************************************/
@isTest
public class NewOpportunityControllerTest{
    @TestSetup static void testData(){
        
        Account acc = new Account();
        acc.firstname = 'Test 12';
        acc.Lastname = 'test';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        insert acc;
        
    }
    //TestMethod to check When a contactrole with open opportunity status is present with current contact
    @isTest
    public static void unitTest1(){
        Account acc = [Select id from Account];
        Test.startTest();
        Opportunity oppObj1 = New Opportunity();
        oppObj1.name = 'Test1';
        oppObj1.AccountId = acc.Id;
        //oppObj1.Requested_Shipping_Method__c = 'Priority Overnight';
        oppObj1.Primary_Account__c = acc.id;
        oppObj1.closeDate = system.today();
        oppobj1.Due_Date__c =  system.Today().addDays(80);
        oppobj1.StageName = 'Ask for sale (7)';
        oppobj1.Signature_Required__c = true;
        oppobj1.Saturday_Delivery__c = true;
        oppobj1.of_Babies__c = 'Twins';
        oppobj1.PickUp_or_Ship_Kit__c = 'Ship';
        oppobj1.Requested_Shipping_Date__c = null;
        Insert oppObj1;
        OpportunityContact__c ocr = new OpportunityContact__c();
        ocr.PersonAccount__c = acc.Id;
        ocr.Opportunity__c = oppObj1.Id;
        insert ocr;
        PageReference pageRef = Page.NewOpportunity;
        NewOpportunityController.checkOpportunityOnContact(acc.id);
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('accid',acc.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        NewOpportunityController newOppObj = New NewOpportunityController(sc);
        ApexPages.currentPage().getParameters().put('accId',acc.id);
        newOppObj.saveOpportunity();
        String stringVal =  NewOpportunityController.checkOpportunityOnContact(acc.id);
        system.debug('unitTest1 stringVal--------'+stringVal);
        system.assertEquals('OpenOrEnrollOpp',stringVal);
        Test.stopTest();
    }
    //UnitTest to check there are no opportunities related to current person account
    @isTest
    public static void unitTest2(){
        Account acc = [Select id from Account];
        Test.startTest();
        PageReference pageRef = Page.NewOpportunity;
        NewOpportunityController.checkOpportunityOnContact(acc.id);
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('accid',acc.id);

        //ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        //NewOpportunityController newOppObj = New NewOpportunityController(sc);
        //newOppObj.saveOpportunity(); 
        String stringVal  = NewOpportunityController.checkOpportunityOnContact(acc.Id);
        system.debug('unitTest2 stringVal--------'+stringVal);
        system.assertEquals('CreateOpp',stringVal);
        Test.stopTest();
    }
    //UnitTest to check there is a stored opportunity and open or Enrolled opportuntiy related to current person account.
    @isTest
     public static void unitTest3(){
        Account acc = [Select id from Account];
        List<opportunity> OppList = new List<opportunity>();
        OppList.add(new Opportunity(name = 'Test1',of_Babies__c = 'Single',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(42),Ship_To_Street1__c = 'Texas mst',Ship_To_City__c = 'Texas',Ship_To_State__c = 'Texas',Ship_To_Zip_Code__c = '73301',Ship_To_Phone__c = '9900990099',Requested_Shipping_Date__c = system.today(),Ship_To_Name__c = 'testName',Description = 'StoredOpp'));
        OppList.add(new Opportunity(name = 'Test1',of_Babies__c = 'Single',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(42),Ship_To_Street1__c = 'Texas mst',Ship_To_City__c = 'Texas',Ship_To_State__c = 'Texas',Ship_To_Zip_Code__c = '73301',Ship_To_Phone__c = '9900990099',Requested_Shipping_Date__c = system.today(),Ship_To_Name__c = 'testName',Description = 'Open'));
        Test.startTest();
        insert OppList;

        List<OpportunityContact__c> ocrList = new List<OpportunityContact__c>();
        ocrList.add(new OpportunityContact__c(Role__c = 'Mother', PersonAccount__c =acc.id ,Opportunity__c =OppList[0].id ));
        ocrList.add(new OpportunityContact__c(Role__c = 'Father', PersonAccount__c =acc.id ,Opportunity__c =OppList[1].id ));
        insert ocrList;
        OppList[0].status__C = 'Stored';
        update OppList;
        PageReference pageRef = Page.NewOpportunity;
        NewOpportunityController.checkOpportunityOnContact(acc.id);
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('accid',acc.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        NewOpportunityController newOppObj = New NewOpportunityController(sc);
        newOppObj.saveOpportunity();
        String stringVal =  NewOpportunityController.checkOpportunityOnContact(acc.id);
        system.debug('unitTest1 stringVal--------'+stringVal);
        system.assertEquals('CanNotCreateOpp',stringVal);
        Test.stopTest();
    }
    //Unit test to check only stored opportunity is related to current person account.
    @isTest
      public static void unitTest4(){
        Account acc = [Select id from Account];
        List<opportunity> OppList = new List<opportunity>();
        OppList.add(new Opportunity(name = 'Test1',of_Babies__c = 'Single',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(42),Ship_To_Street1__c = 'Texas mst',Ship_To_City__c = 'Texas',Ship_To_State__c = 'Texas',Ship_To_Zip_Code__c = '73301',Ship_To_Phone__c = '9900990099',Requested_Shipping_Date__c = system.today(),Ship_To_Name__c = 'testName',Description = 'StoredOpp'));
        Test.startTest();
        insert OppList;

        List<OpportunityContact__c> ocrList = new List<OpportunityContact__c>();
        ocrList.add(new OpportunityContact__c(Role__c = 'Father', PersonAccount__c =acc.id ,Opportunity__c =OppList[0].id ));
        ocrList.add(new OpportunityContact__c(Role__c = 'Mother', PersonAccount__c =acc.id ,Opportunity__c =OppList[0].id ));
        insert ocrList;
        OppList[0].status__C = 'Stored';
        update OppList;
        PageReference pageRef = Page.NewOpportunity;
        NewOpportunityController.checkOpportunityOnContact(acc.id);
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('fromPage','classic');
        pageRef.getParameters().put('accid',acc.id);
        pageRef.getParameters().put('primarySource','I\'m a Current Client');
       // ApexPages.StandardController sc = new ApexPages.StandardController(acc);
       // NewOpportunityController newOppObj = New NewOpportunityController(sc);
       // newOppObj.saveOpportunity();
        String stringVal =  NewOpportunityController.checkOpportunityOnContact(acc.id);
        system.debug('unitTest1 stringVal--------'+stringVal);
        system.assertEquals('CurrentClientOpp',stringVal);
        Test.stopTest();
    }
}
/********************************************************************************************
 * Component Name: ScheduleUpdateOpportunityBatchTest
 * Description	: TestCoverage for UpdateOpportunityBatch and ScheduleUpdateOpportunityBatch
 * Developed By	: TEKsystems
 * ******************************************************************************************/
@istest
public with sharing class ScheduleUpdateOpportunityBatchTest {
    //testmethod for test coverage of ScheduleUpdateOpportunityBatch
    static testmethod void testSample() {
        Test.startTest();
        ScheduleUpdateOpportunityBatch obj = new ScheduleUpdateOpportunityBatch();
        obj.execute(null);
        Test.stopTest();
    }
     //testmethod for test coverage of UpdateOpportunityBatch
    static testmethod  void unitTest(){
        //Create Opportunity
        Opportunity oppobj = New Opportunity(name = 'Test1',of_Babies__c = 'Single',Requested_Shipping_Method__c = 'Priority Overnight',StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(2));
        //Insert Opportunity
        Insert oppobj;
        oppobj.Name = 'Test Smith';
        //Update Opportunity
        update oppobj;
        Test.startTest();
            UpdateOpportunityBatch obj = new UpdateOpportunityBatch();
            DataBase.executeBatch(obj); 
        Test.stopTest();
    }

}
@isTest
public class ReferalOpportunityControllerTest{
   
    @isTest
    public static void test1(){
        Account acc  = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.Due_Date__c = system.today().addDays(2);
        //opp.StageName = 'Overcoming Objections (6)';
        opp.StageName = 'Won (9)';
        opp.Status__c = 'Stored'; 
        insert opp;
        
        Contact con = new Contact();
        con.firstname = 'Test 12';
        con.Lastname = 'test';
        insert con;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp.Id;
        ocr.Role = 'Decision Maker';

        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = true;
        insert ocr;
        
        Account acc2  = new Account();
        acc2.Name = 'test';
        insert acc2;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'test';
        opp2.AccountId = acc2.Id;
        opp2.CloseDate = system.today();
        opp2.Due_Date__c = system.today().addDays(5);
        opp2.StageName = 'Overcoming Objections (6)';
        opp2.Referred_By_Opportunity__c  = opp.Id; 
        opp2.Status__c = 'Stored';
        insert opp2;
        
        system.debug('Opportunity'+opp2);
        
        Contact con2 = new Contact();
        con2.firstname = 'Test5';
        con2.Lastname = 'test22';
        insert con2;
        
        system.debug('Contact 2'+con2);
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.ContactId = con2.Id;
        ocr2.OpportunityId = opp2.Id;
        ocr2.Role = 'Decision Maker';
        ocr2.isPrimary = true;
        insert ocr2;
        
        system.debug('OCR >>>>'+ocr2);
         ApexPages.StandardController sc = new ApexPages.StandardController(con2);
         ReferalOpportunityController controller = new ReferalOpportunityController(sc);
         controller.oppId = opp.Id;
         controller.getReferalData();
    }
}
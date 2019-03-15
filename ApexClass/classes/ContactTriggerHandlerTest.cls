/*
* This is a test class for ContactTriggerHandler
* Created By: Tek Systems
*/
@isTest
public class ContactTriggerHandlerTest {
    static testmethod void TestOpportunity() {
        test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        System.assertEquals(acc.Name, 'Test Account');
        Set<id> contids = new Set<id>();
        
        Contact con = new Contact();
        con.FirstName = 'Paul';
        con.LastName  = 'Test';
        con.AccountId = acc.id;
        con.MailingStreet = '298 S. Ringo Street';
        //con.MailingCity = 'San Bruno';
        //con.MailingState = 'AR';
        con.MailingPostalCode = '94066';
        con.Mailingcountry = 'United States';
        con.MQL_Score__c = 1224;
        insert con;  
        contids.add(con.id);
        System.assertEquals(con.mailingcountry, 'United States');

        Opportunity opp = new Opportunity();
        opp.Name='Sample test'; 
        opp.AccountId = acc.id;
        opp.StageName = 'Closed Lost (10)';
        //opp.Primary_Source__c='I\'m a Current Client';
        opp.Primary_Source__c='I\'m a Current Client';
        opp.CloseDate = system.today();
        opp.PickUp_or_Ship_Kit__c='PickUp';
        opp.Status__c = 'Closed_Lost';
        insert opp;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Sam';
        con1.LastName  = 'Smith';
        con1.AccountId = acc.id;
        con1.MailingStreet = '298 S. Ringo Street';
        //con1.MailingCity = 'San Bruno';
        //con.MailingState = 'AR';
        con1.MailingPostalCode = '94066';
        con1.MailingCountry = 'United States';
        con1.MQL_Score__c = 1224;
        insert con1;  
        contids.add(con1.id);
        System.assertEquals(con1.MailingCountry, 'United States'); 
       
        
        List<Opportunity> opplist = new List<Opportunity>();
        opplist.add(opp);
        System.assertEquals(opp.Name, 'Sample test');
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        //ocr.Role = 'Decision Maker';
        ocr.Role = 'Mother';
        insert ocr;
        
        System.assertEquals(ocr.Role, 'Mother');
        con.MailingPostalCode = '94552'; 
        update con;

        ContactTriggerHandler.ContactMQLNullAfterInsert(contids);
        //ContactTriggerHandler.ContactAfterInsert(contids);
        //ContactTriggerHandler.createOpportunityContactRole(opplist);
         Test.Stoptest();
         
    }
    
}
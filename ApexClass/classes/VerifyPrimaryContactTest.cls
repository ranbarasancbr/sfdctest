/********************************************************************************************
 * Component Name: VerifyPrimaryContactTest
 * Description	: Test Class for VerifyPrimaryContact
 * Developed By	: TEKsystems
 * ******************************************************************************************/
@isTest
public class VerifyPrimaryContactTest {
    static testmethod void TestOpportunity() {
        test.startTest();
        //Create Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        //Create Contact
        Contact con = new Contact();
        con.FirstName = 'Paul';
        con.LastName  = 'Test';
        con.AccountId = acc.id;
        con.MailingStreet = '298 S. Ringo Street';
        con.MailingCity = 'Texas';
        con.MailingState = 'Texas';
        con.MailingPostalCode = '73301'; 
        con.MailingCountry = 'United States'; 
        insert con;    
        
        //Create Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc.id;
        opp.StageName = 'Qualification';
        opp.CloseDate = system.today();
        insert opp;
        
        //Create OpportunityContactRole 
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        ApexPages.currentPage().getParameters().put('id',Opp.Id);
        VerifyPrimaryContact ac = new VerifyPrimaryContact();
        ac.updatePrimaryContact();
    }
}
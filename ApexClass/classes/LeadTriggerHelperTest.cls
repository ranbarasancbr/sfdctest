@isTest
public class LeadTriggerHelperTest {
	   static testMethod void addOpportunityContactTest(){  
        //OpportunityContact__c oppcontacts = new OpportunityContact__c();
        List<Lead> leadslist = new List<Lead>();
        Lead leads = new Lead();
        leads.FirstName = 'Brian';
        leads.LastName = 'Lara';
        leads.Email = 'blara@cordblood.com';    
        leads.LeadSource = 'CSS Referral';
        leads.Due_Date__c = system.today();
        leads.Status = 'Qualified';
        insert leads;
        Account a1 = [SELECT Id from Account WHERE NAME = 'Brian Lara'];
        List<OpportunityContact__c> OppContactsList = [SELECT Id, PersonAccount__c FROM OpportunityContact__c WHERE PersonAccount__c = :a1.Id];
        system.assertEquals(OppContactsList.size(),1);
    }	
}
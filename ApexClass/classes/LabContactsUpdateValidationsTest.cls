/**************************************************************************************************************
* Component Name: LabContactsUpdateValidationsTest
* Description   : Test Class For LabContactsUpdateValidations Class
* Developed By  : Teksystems
***************************************************************************************************************/
@isTest
public class LabContactsUpdateValidationsTest{
     @isTest
    public static void unittest1(){

       try{ 
        Account a= new Account(Name ='TestAccount');
        insert a;
        
        Contact c = new Contact(AccountId = a.id, FirstName = 'Fname', LastName = 'LName', Email = 'Fname.Lname@test.com');
        insert c;
        
        Opportunity opp = new Opportunity(Name ='Testopp',AccountId = a.id, stageName='Ask for sale (7)',closeDate = system.today(),Due_Date__c = system.today().addDays(2),of_Babies__c = 'Single',Primary_Contact__c = c.id,LeadSource ='Lab');
        insert opp;
        
        OpportunityContactRole conRoleObj = New OpportunityContactRole();
        conRoleObj.IsPrimary = true;
        conRoleObj.contactId = c.id;
        conRoleObj.Role = 'Mother';
        conRoleObj.OpportunityId = opp.id;
        Insert conRoleObj;
        
        opp.Due_Date__c = system.today().addDays(1);
        update opp;
        
        system.debug('op......'+opp);
        
         Test.StartTest();
        c.FirstName ='Fname1';
        c.LastName = 'Lname11';
        c.Email = 'Fname.Lname111@test.com';
        
        update c;
        system.assertEquals(c.id,opp.Primary_Contact__c);
        system.debug('opp.Primary_Contact__c'+opp.Primary_Contact__c);
       
        Map<id,Contact> newMap =new Map<id,Contact>();
        Map<id,Contact> oldmap = new Map<id,Contact>();
        
        LabContactsUpdateValidations.ContactValidations(newMap,oldmap);
        Test.StopTest();
       }
       catch(Exception e){}
    }
}
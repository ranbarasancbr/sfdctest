@isTest
public class OpportunityTaskCreateTest{

    public static testmethod void testBatch(){
        test.StartTest();
        
       Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Kurt';
        con.LastName  = 'Cobain';
        con.AccountId = acc.id;
        con.MailingStreet = '298 S. Ringo Street';
        con.MailingCity = 'Hanover';
        con.MailingState = 'Texas';
        con.MailingPostalCode = '73301';
        con.MailingCountry = 'United States';
        
        insert con;  
        system.debug('acc...........'+acc);
        Opportunity ops = new Opportunity();
        ops.Name='Sample test'; 
        ops.AccountId = acc.id;
        ops.Storage_Date__c=system.today().AddMonths(-57).addDays(-4);
        ops.Status__c = 'Stored';
        ops.Program_Enrolled_in__c='Newborn Possibilities Program - Designated Treatment Protocol';
       
        ops.StageName = 'Overcoming Objections (6)';
        ops.Due_Date__c = system.today().addDays(20);
        ops.Primary_Source__c='I\'m a Current Client';
        ops.CloseDate = system.today();
        ops.of_Babies__c = 'Single';
      
        ops.Adoption_Type__c = 'Open';
        
        ops.of_CB__c='1';
        ops.of_CT__c='0';
        
        List<opportunity> opplist = new List<Opportunity>();
        opplist.add(ops);
        insert opplist;
        
        ScheduleOpportunityTaskCreate oppbatch = new ScheduleOpportunityTaskCreate();
       String cronstr = '0 30 00 * * ?';
       id jobid = System.schedule('Test opportunity Stage1'+system.now(), cronStr, oppbatch);
        Test.Stoptest();
    }
      public static testmethod void testBatch1(){
        test.StartTest();
        
       Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Kurt';
        con.LastName  = 'Cobain';
        con.AccountId = acc.id;
        con.MailingStreet = '298 S. Ringo Street';
        con.MailingCity = 'Hanover';
        con.MailingState = 'Texas';
        con.MailingPostalCode = '73301';
        con.MailingCountry = 'United States';
        
        insert con;  
        
        system.debug('acc...........'+acc);
        Opportunity ops = new Opportunity();
        ops.Name='Sample test'; 
        ops.AccountId = acc.id;
        ops.Storage_Date__c=system.today().AddMonths(-57).addDays(-4);
        ops.Status__c = 'Stored';
        ops.Program_Enrolled_in__c='Newborn Possibilities Program - Designated Treatment Protocol';
       
        ops.StageName = 'Overcoming Objections (6)';
        ops.Due_Date__c = system.today().addDays(20);
        ops.Primary_Source__c='I\'m a Current Client';
        ops.CloseDate = system.today();
        ops.of_Babies__c = 'Single';
      
        ops.Adoption_Type__c = 'Open';
        
        ops.of_CB__c='1';
        ops.of_CT__c='0';
        
        List<opportunity> opplist = new List<Opportunity>();
        opplist.add(ops);
        insert opplist;
        List<opportunity> optylist = [Select id,ownerId,Storage_Date__c from Opportunity where id=:opplist[0].id];
        List<Task> taskList = new List<Task>();
         Task t = new Task();
                t.Subject = 'Call';
                t.WhatId=optylist[0].ID;    
                t.OwnerId = optylist[0].ownerId;
                t.Status ='Open';
                t.ActivityDate= optylist[0].Storage_Date__c.Date().addMonths(60).addDays(-30);
                t.Priority='High';
                t.Description='Approaching end of NPP free storage period. Contact client to discuss conversion to family banking.';
                
               // Add all tasks to a list  
                taskList.add(t);
                insert taskList;
        
        ScheduleOpportunityTaskCreate oppbatch = new ScheduleOpportunityTaskCreate();
       String cronstr = '0 30 00 * * ?';
       id jobid = System.schedule('Test opportunity Stage1'+system.now(), cronStr, oppbatch);
        Test.Stoptest();
      }
    
}
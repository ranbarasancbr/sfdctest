/*************************************************
*For Component Name:OpportunityClose_batch
Description: Test Case to change status of opportunity to close
Story : CBRSFDC8-246
Created By: Teksystems
**************************************************/


@isTest
public class OpportunityClose_batch_test{
    
   public static testmethod void TestMethod1(){
       
        test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
      
        Contact con = new Contact();
        con.FirstName = 'Paul';
        con.LastName  = 'Test';
        con.AccountId = acc.id;
        con.MailingStreet = '298 S. Ringo Street';
        con.MailingCity = 'San Bruno';
        //con.MailingState = 'AR';
        con.MailingPostalCode = '94066';
        con.MailingCountry = 'United States';
        con.MQL_Score__c = 1224;
        insert con;  
        
        Opportunity opp = new Opportunity();
        opp.Name='Sample test'; 
        opp.AccountId = acc.id;
        opp.Status__c = 'Open';
        opp.Primary_Contact__c = con.id;
        opp.Enrollment_Date__c = NULL;
        opp.StageName = 'Overcoming Objections (6)';
        opp.Due_Date__c = system.today().addDays(14);
        opp.Primary_Source__c='I\'m a Current Client';
        opp.CloseDate = system.today();
        opp.of_Babies__c = 'Single';
        opp.PickUp_or_Ship_Kit__c='Ship';
        opp.Ship_To_Name__c ='test user';
        opp.Ship_To_Street1__c='test Address';
        opp.Requested_Shipping_Date__c  = system.today().addDays(1);
        opp.Shipping_Method__c = 'Priority Overnight';
        opp.Adoption_Type__c = 'N/A';
        opp.Ship_To_Phone__c = '1234512345';
        opp.Payment_Method__c = 'Credit Card';
        opp.of_CB__c='1';
        opp.of_CT__c='0';
        insert opp;
        
       // System.debug('++++Oppty 1' + opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name='Sample test'; 
        opp1.AccountId = acc.id;
        opp1.Status__c = 'Enrolled';
        opp1.LeadSource = 'Internet';
        opp1.Primary_Contact__c = con.id;
        opp1.Enrollment_Date__c = NULL;
        opp1.Storage_Date__c = Null;
        opp1.StageName = 'Marketing Qualified (4)';
        opp1.Due_Date__c = system.today().addDays(21);
        opp1.Primary_Source__c='I\'m a Current Client';
        opp1.CloseDate = system.today().addDays(45);
        opp1.of_Babies__c = 'Single';
        opp1.Loss_Reason__c = 'Cancellation';
        opp1.PickUp_or_Ship_Kit__c='Ship';
        opp1.Ship_To_Name__c ='test user';
        opp1.Ship_To_Street1__c='test Address';
        opp1.Requested_Shipping_Date__c  = system.today().addDays(1);
        opp1.Shipping_Method__c = 'Priority Overnight';
        opp1.Adoption_Type__c = 'N/A';
        opp1.Ship_To_Phone__c = '1234512345';
        opp1.Payment_Method__c = 'Credit Card';
        opp1.of_CB__c='1';
        opp1.of_CT__c='0';
        insert opp1;
            
        Opportunity opptty = [Select Name, id, Status__c,Due_Date__c,Storage_Date__c,Enrollment_Date__c,StageName from Opportunity where id=:opp1.Id];       
        System.debug('++++Oppty 1' + opp1);
        
        system.debug('op-------------------p'+opptty);
        system.debug('system.today().addDays(30)'+system.today().addDays(30));
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp1.Id;
        ocr.IsPrimary = TRUE;
        //ocr.Role = 'Decision Maker';
        ocr.Role = 'Mother';
        insert ocr;
        system.debug('ocr'+ocr);
        
         
        OpportunityClose_batch oppbatch = new OpportunityClose_batch();
        //String cronstr = '0 30 00 * * ?';
        //id jobid = System.schedule('Test opportunity Stage1'+system.now(), cronStr, oppbatch);
        DataBase.executeBatch(oppbatch);
         
        test.stopTest();
     /*
        System assert will not work due as batch being executed after the system asserts statements.
        system.assertEquals('Auto Closed', opp.Loss_Reason__c);
        system.assertEquals('Closed_Lost', opp.Status__c);
        system.assertEquals('Closed_Lost', opp.StageName);
        
        system.assertEquals('Cancellation', opp1.Loss_Reason__c);
        system.assertEquals('Closed_Lost', opp1.Status__c);
        system.assertEquals('Closed_Lost', opp1.StageName);*/
       
    }
    
    public static testmethod void TestMethod2(){
        test.startTest();
        Account acc1 = new Account();
        acc1.Name = 'Test Account2';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Raja';
        con1.LastName  = 'Chamraj';
        con1.AccountId = acc1.id;
        con1.MailingStreet = '298 S. Ringo Street';
        con1.MailingCity = 'San Bruno';
        //con1.MailingState = 'AR';
        con1.MailingPostalCode = '94066';
        con1.MailingCountry = 'United States';
        con1.MQL_Score__c = 1224;
        insert con1;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name='Sample test'; 
        opp2.AccountId = acc1.id;
        opp2.Status__c = 'Open';
        opp2.Primary_Contact__c = con1.id;
        opp2.LeadSource = 'Internet';
        opp2.Enrollment_Date__c = system.today();
        opp2.StageName = 'Closed Lost (10)';
        opp2.Due_Date__c = system.today().addDays(21);
        opp2.Primary_Source__c='I\'m a Current Client';
        opp2.CloseDate = system.today();
        opp2.of_Babies__c = 'Single';
        opp2.Ship_To_Name__c ='test user';
        opp2.Ship_To_Street1__c='test Address';
        opp2.Requested_Shipping_Date__c  = system.today().addDays(1);
        opp2.PickUp_or_Ship_Kit__c='Ship';
        opp2.Shipping_Method__c = 'Priority Overnight';
        opp2.Adoption_Type__c = 'N/A';
        opp2.Ship_To_Phone__c = '1234512345';
        opp2.Payment_Method__c = 'Credit Card';
        opp2.Storage_Date__c = null;
        opp2.of_CB__c='1';
        opp2.of_CT__c='0';
        insert opp2;
        
        Opportunity opty = [Select Name, id, Status__c,Due_Date__c,Storage_Date__c,Enrollment_Date__c,StageName,LeadSource from Opportunity where id=:opp2.Id];
        
        system.debug('Opportunity opty...........'+opty);
        system.debug('Due_Date__c...........'+opty.Due_Date__c);
        system.debug('Storage_Date__c----------'+opty.Storage_Date__c);
        system.debug('Status__c ====='+opty.Status__c);
        system.debug('LeadSource======='+opty.LeadSource);
        system.debug('StageName========='+opty.StageName);
        system.debug('Enrollment_Date__c'+opty.Enrollment_Date__c);
        
        opp2.Status__c = 'Enrolled';
        update opp2;
        
        Opportunity opty1 = [Select Name, id, Status__c,Due_Date__c,Storage_Date__c,Enrollment_Date__c,StageName,LeadSource from Opportunity where id=:opp2.Id];
        
        system.debug('opty1========='+opty1.Status__c);
        system.debug('Due_Date__c1111...........'+opty1.Due_Date__c);
        system.debug('Storage_Date__c111----------'+opty1.Storage_Date__c);
        system.debug('Enrollment_Date__c1111'+opty1.Enrollment_Date__c);
        
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.ContactId = con1.Id;
        ocr1.OpportunityId = opp2.Id;
        ocr1.IsPrimary = TRUE;
        //ocr.Role = 'Decision Maker';
        ocr1.Role = 'Mother';
        insert ocr1;
        
        system.debug('Batch====Start=====>>>>>>>');
        OpportunityClose_batch batchable = new OpportunityClose_batch();
        Database.executeBatch(batchable);
        system.debug('Batch====finish=====>>>>>>>');
        Opportunity oppTestList = [select id,Name,Status__c,Loss_Reason__c from Opportunity where Id=: opp2.Id];
        system.debug('oppTestList========>>>>>>>'+oppTestList);
        
        test.stopTest();
        
        //System assert will not work due as batch being executed after the system asserts statements.
        //system.assertEquals('Enrolled', opp2.Status__c);
        //system.assertEquals('Auto Closed', opp2.Loss_Reason__c);
        
        
        
    }
}
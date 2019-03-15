@isTest
public class OpportunityContactHelperTest {
    private static testMethod void unitTest(){
        // Create Contact
        Contact con = new Contact();
        con.FirstName = 'Susan';
        con.LastName = 'Taylor';
        Test.startTest();
        Insert con;
        
        // Create Opportunity
        Opportunity op1 = new Opportunity();
        op1.name = 'Opportunity Contact Update Test';
        op1.CloseDate =  system.today().addDays(24);
        op1.StageName = 'Overcoming Objections (6)';
        op1.PickUp_or_Ship_Kit__c = 'Ship';
        
        op1.Ship_To_Phone__c = '9999999999';
        op1.Requested_Shipping_Date__c = system.today();
        op1.Ship_To_Name__c = 'Test';
        op1.Ship_To_Street1__c = 'Test Address';
        op1.Ship_To_State__c = 'Arizona';
        op1.Ship_To_Zip_Code__c = '85281';
        op1.Ship_To_Phone__c = '9999999999';
        op1.Primary_Source__c = 'Advertising (Magazine, Internet)';
        op1.Shipping_Method__c = 'Priority Overnight';
        op1.LeadSource = 'Chat';
        insert op1;
        
        Provider__c provObj = New Provider__c();
        provObj.Master_Provider_Id__c = 'testMP';
        Insert provObj;
        
        Facility__c faciObj = New Facility__c();
        faciObj.Facility_Name__c = 'testfacility';
        Insert faciObj;
        
        Provider_Facility__c pfObj = new Provider_Facility__c();
        pfObj.Master_Provider_Facility_ID__c = 'TestPF';
        pfObj.Facility__c = faciObj.id;
        pfObj.Provider__c = provObj.id;
        
        insert pfObj;
        
        Opportunity_Provider__c oppProviderObj = new Opportunity_Provider__c();
        oppProviderObj.Provider__c = provObj.Id;
        oppProviderObj.Opportunity__c = op1.id;
        oppProviderObj.Primary_Provider__c = true;
        oppProviderObj.Facility__c = faciObj.id;
        oppProviderObj.Provider_Facility__c = pfObj.id;
        
        Insert oppProviderObj;
        
        //Now update the OCR for the primary contact
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = op1.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Mother';
        insert ocr;
        
        op1.Status__c = 'Stored';
        op1.Primary_Contact__c = con.id;
        update op1;
        Test.stopTest();
        Contact c =[select id,Client_Flag__c from contact where Id =:con.id];
system.debug('c.Client_Flag__c'+c.Client_Flag__c);
        System.assertEquals(c.Client_Flag__c,True);
        
    }
        
        private static testMethod void unitTest1(){
            
        Contact con1 = new Contact();
        con1.FirstName = 'Susany';
        con1.LastName = 'Taylorr';
        Test.startTest();
        Insert con1;
            
        // Create Opportunity
        Opportunity op2 = new Opportunity();
        op2.name = 'Opportunity Contact Update Test';
        op2.CloseDate =  system.today().addDays(24);
        op2.StageName = 'Overcoming Objections (6)';
        op2.PickUp_or_Ship_Kit__c = 'Ship';
        op2.Ship_To_Phone__c = '9999999999';
        
        op2.Ship_To_Street1__c = 'Test Address';
        op2.Ship_To_State__c = 'Arizona';
        op2.Ship_To_Zip_Code__c = '85281';
        
        op2.Primary_Source__c = 'Advertising (Magazine, Internet)';
        op2.Shipping_Method__c = 'Priority Overnight';
        op2.LeadSource = 'Chat';
        insert op2;
        
        //Now update the OCR for the primary contact
        
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.ContactId = con1.Id;
        ocr1.OpportunityId = op2.Id;
        ocr1.IsPrimary = TRUE;
        ocr1.Role = 'Mother';
        insert ocr1;
        

        op2.Status__c = 'Closed_Lost';
        op2.Storage_Date__c = system.today().addDays(5);
        op2.Loss_Reason__c = 'Terminated';
        op2.Primary_Contact__c = con1.id;
        update op2;

        op2.Status__c = 'Closed_Lost';
        update op2;
        opportunity opp =[select id,Status__c,Storage_Date__c,Loss_Reason__c from Opportunity where id =:op2.id];
Test.stopTest();
        Contact c =[select id,Client_Flag__c from contact where Id =:con1.id];
        system.debug('opportunity closed client flag check');
        system.debug('opp.Status__c'+opp.Status__c);
        system.debug('opp.Storage_Date__c'+opp.Storage_Date__c);
        system.debug('opp.Loss_Reason__c'+opp.Loss_Reason__c);
        system.debug('c.Client_Flag__c'+c.Client_Flag__c);
        System.assertEquals(c.Client_Flag__c,False);
        }
}
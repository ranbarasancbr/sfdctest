@isTest
public class UpdateOnlineEnrollmentsTest {
    public static Provider__c prov;
    public static  Facility__c fc;
    public static Facility__c fc1;
    public static void setupdata(){
        
        prov = new Provider__c();
        prov.Master_Provider_Id__c = '88990011';
        //prov.Name = 'Sample Provider 1';
        prov.City__c = 'Bangalore';
        
        insert prov;
        
        fc = new Facility__c();
        fc.Facility_Name__c = 'Sample Facility 1'; 
        fc.Master_Facility_Id__c = '11223344';
        fc.City__c = 'Zurich';
        
        insert fc;
        
        fc1 = new Facility__c();
        fc1.Facility_Name__c = 'Sample Facility 2'; 
        fc1.Master_Facility_Id__c = '33221144';
        
        insert fc1;
        
        
    }
    static testMethod void UpdateOnline(){
        setupdata();
               
       Online_Enrollment__c oe = new Online_Enrollment__c();
         oe.Cardholder_Name__c ='Test';
         oe.Primary_First_Name__c = 'Sam';
         oe.Primary_Last_Name__c = 'Smith';
         oe.Primary_Home_Phone__c = '1234567901';
         oe.Birth_Date_of_Primary__c = Date.today();
         oe.Primary_Address__c = 'St Marks road';
         oe.Primary_City__c = 'Hanover';
         oe.Primary_State__c = 'California';
         oe.Primary_Country__c = 'United States';
         oe.Primary_Zipcode__c = '73301';
         oe.PrimaryID__c= '10010010';
         oe.Primary_Email__c = 'samsmith@example.com';
         oe.Primary_Role__c='Mother';
         oe.Primary_Mobile_Phone__c = '1234567890';
         oe.Secondary_First_Name__c= 'Sam';
         oe.Secondary_Last_Name__c = 'Smith';
         oe.Secondary_Role__c='Father';
         oe.of_CB__c = '1';
         oe.of_CT__c = '1';
         oe.Due_Date__c = System.today();
         oe.Adoption_Type__c = 'Open';
         oe.Provider_First_Name__c = 'Tom';
         oe.Provider_Last_Name__c = 'Raider';
         oe.Provider_State__c = 'LA';
         oe.Provider_City__c = 'Chicago';
         oe.Provider_Address__c = 'Times Square';
         //oe.Provider_Facility_ID__c = '10001001010';
         oe.Hospital_Id__c = '11223344';
         oe.Hospital_Address__c = 'St Anees Road';
         oe.Hospital_City__c = 'Southhamptom';
         oe.Hospital_Name__c ='Forbes';
         oe.Hospital_State__c = 'London';  
         oe.Provider_City__c = 'Japan';
         oe.Provider_Address__c='St Johns';
         oe.Provider_ID__c='88990011';
         oe.Provider_Facility_ID__c = '33445566';
         
         insert oe;
        
        Account acc= [Select id,name,Online_Enrollment__c from account where Online_Enrollment__c =: oe.id limit 1];
         if(acc != NULL) 
            System.assertEquals(acc.Online_Enrollment__c, oe.Id);
         
         Contact con = [Select id,FirstName from contact where FirstName=: oe.Primary_First_Name__c limit 1];
         if(con !=NULL)
         System.assertEquals(con.FirstName,oe.Primary_First_Name__c);
                 
         Opportunity opp = [Select id,AccountId,name from Opportunity where AccountID =: acc.Id limit 1];
         if(opp !=NULL)
         System.assertEquals(acc.id,opp.AccountId );
         
         prov = [Select id,Master_Provider_Id__c,Name from Provider__c where Master_Provider_Id__c =:  oe.Provider_ID__c limit 1];
         if(prov !=NULL)
         System.assertEquals(prov.Master_Provider_Id__c, oe.Provider_ID__c);
        
         fc = [Select id,Master_Facility_Id__c,name from Facility__c where Master_Facility_Id__c =:  oe.Hospital_Id__c limit 1];
         if(fc !=NULL)
         System.assertEquals(fc.Master_Facility_Id__c, oe.Hospital_Id__c);
        
         oe.Primary_First_Name__c = 'Tommy';
         update oe;
        
         System.assertEquals(oe.Primary_First_Name__c, 'Tommy');
        
        Set<id> ocset = new Set<id>();
         ocset.add(oe.id);
        UpdateOnlineEnrollments.updateOppPrimaryInfoOnOnlineEnroll(ocset);
        
    }
    static testMethod void UpdateOLEOnOppUpdateTest(){
        setupdata();
         Test.StartTest();  
         Online_Enrollment__c oe = new Online_Enrollment__c();
         oe.Primary_First_Name__c = 'Sam';
         oe.Primary_Last_Name__c = 'Smith';
         oe.Primary_Home_Phone__c = '1234567901';
         oe.Birth_Date_of_Primary__c = Date.today();
         oe.Primary_Address__c = 'St Marks road';
         oe.Primary_City__c = 'Hanover';
         oe.Primary_State__c = 'California';
         oe.Primary_Country__c = 'United States';
         oe.Primary_Zipcode__c = '73301';
         oe.PrimaryID__c= '10010010';
         oe.Primary_Email__c = 'samsmith@example.com';
         oe.Primary_Role__c='Mother';
         oe.Primary_Mobile_Phone__c = '1234567890';
         oe.of_CB__c = '1';
         oe.of_CT__c = '1';
         oe.Due_Date__c = System.today();
         oe.Adoption_Type__c = 'Open';
         oe.Hospital_Id__c = '11223344';
         oe.Hospital_Address__c = 'St Anees Road';
         oe.Hospital_City__c = 'Southhamptom';
         oe.Hospital_Name__c ='Forbes';
         oe.Hospital_State__c = 'London';  
         oe.of_Babies__c = 'Single';
        
         insert oe;
         
         Opportunity opp = [select id,Online_Enrollment__c,Status__c,Adoption_Type__c,of_Babies__c,of_CB__c,of_CT__c,Delivering_Hospital__c,Due_Date__c From Opportunity Where Online_Enrollment__c =: oe.id];
         opp.Adoption_Type__c = 'Surrogate';
         opp.of_CB__c = '2';
         opp.of_CT__c = '2';
         opp.Delivering_Hospital__c = fc1.id;
         opp.of_Babies__c = 'Twins';
         opp.Due_Date__c = system.today().addDays(1);
         update opp;
         
         Online_Enrollment__c ole = [select id,of_Babies__c,of_CB__c,of_CT__c,Adoption_Type__c,Hospital_Id__c,Provider_ID__c,Opportunity_Id__c,Due_Date__c from Online_Enrollment__c where Id =: oe.id];
         system.assertEquals(ole.Adoption_Type__c,opp.Adoption_Type__c);
         system.assertEquals(ole.of_CB__c,opp.of_CB__c);
         system.assertEquals(ole.of_CT__c,opp.of_CT__c);
         system.assertEquals(ole.of_Babies__c,opp.of_Babies__c);
         system.assertEquals(ole.Hospital_Id__c,'33221144');
         system.assertNotEquals(ole.Due_Date__c,opp.Due_Date__c);
         Test.StopTest();
    }
    

}
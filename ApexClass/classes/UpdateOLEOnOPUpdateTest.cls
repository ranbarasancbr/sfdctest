/**************************************************************************************************************************************
* Component Name  : UpdateOLEOnOPUpdateTest
* Description     : Test class for UpdateOLEOnOPUpdate                     
* Developed By    : Teksystems
****************************************************************************************************************************************/
@isTest
public class UpdateOLEOnOPUpdateTest{
    public static List<Provider__c> providerList;
    public static Provider__c p1;
    public static Provider__c p2;
    public static List<Facility__c> facilityList;
    public static Facility__c f1;
    public static Facility__c f2;
    public static List<Provider_Facility__c> providerfacilityList;
    public static Provider_Facility__c pf1;
    public static Provider_Facility__c pf2;
       
    public static void setupData(){
       
         providerList = new List<Provider__c>();
         p1 = new Provider__c(Master_Provider_Id__c = 'TestMP1',Provider_First_Name__c = 'TestProviderFN1',Provider_Last_Name__c = 'TestProviderLN1');
         p2 = new Provider__c(Master_Provider_Id__c = 'TestMP2',Provider_First_Name__c = 'TestProviderFN2',Provider_Last_Name__c = 'TestProviderLN2');
        
        providerList.add(p1);
        providerList.add(p2);
       
        insert providerList;
 
         facilityList = new List<Facility__c>();
         f1 = new Facility__c(Master_Facility_Id__c = 'TestMF1',Facility_Name__c='facilityname1');
         f2 = new Facility__c(Master_Facility_Id__c = 'TestMF2',Facility_Name__c='facilityname2');
        
        facilityList.add(f1);
        facilityList.add(f2);
       
        insert facilityList;

         providerfacilityList = new List<Provider_Facility__c>();
         pf1 = new Provider_Facility__c(Facility__c = f1.id,Provider__c = p1.id ,Master_Provider_Facility_ID__c = 'TestMPF1');
         pf2 = new Provider_Facility__c(Facility__c = f2.id,Provider__c = p2.id,Master_Provider_Facility_ID__c = 'TestMPF2');
        
        providerfacilityList.add(pf1);
        providerfacilityList.add(pf2);
        
        insert providerfacilityList;
    }
    static testMethod void updateOLEOfOPTest(){
        setupdata();
        Test.StartTest();
         Online_Enrollment__c oe = new Online_Enrollment__c();
         oe.Cardholder_Name__c ='Test';
         oe.Primary_First_Name__c = 'Sam';
         oe.Primary_Last_Name__c = 'Smith';
         oe.Primary_Home_Phone__c = '1234567901';
         oe.Birth_Date_of_Primary__c = Date.today();
         oe.Primary_Address__c = 'St Marks road';
         oe.Primary_City__c = 'Texas';
         oe.Primary_State__c = 'Texas';
         oe.Primary_Country__c = 'United States';
         oe.Primary_Zipcode__c = '73301';
         oe.PrimaryID__c= 'TestMP2';
         oe.Primary_Email__c = 'samsmith@example.com';
         oe.Primary_Role__c='Mother';
         oe.of_CB__c = '1';
         oe.of_CT__c = '1';
         oe.Due_Date__c = System.today();
         oe.Adoption_Type__c = 'Open';
         oe.Provider_ID__c ='TestMP2';
         oe.Provider_Facility_ID__c = 'TestMPF2';
         oe.Hospital_Id__c = 'TestMF2';
         insert oe;
          
          //Query on Opportunity 
         Opportunity opp = [select id,Online_Enrollment__c from opportunity where Online_Enrollment__c =: oe.id];
         system.debug('opp----'+opp.Online_Enrollment__c);
         //Query on opportunity provider with opp.id
         Opportunity_Provider__c op= [select id,Opportunity__c,Provider__c,Facility__c,Primary_Provider__c,Provider_Facility__c from Opportunity_Provider__c where Opportunity__c =:opp.id];
         
         //Update Opportunity provider's primary contact
         op.Provider__c = p1.id;
         op.Provider_Facility__c = pf1.id;
         op.Facility__c = f1.id;
         
         update op;
         
         Online_Enrollment__c ole = [select id,Provider_ID__c from Online_Enrollment__c where ID =:oe.id];
         //check weather provider id is updated on OLE
         system.assertEquals(ole.Provider_ID__c,'TestMP1');
        Test.StopTest();
    }
}
/********************************************************************************************************************************************************
* Component Name: OLEUpdateFromContactTest
* Description   : Test Class for OLEUpdateFromContact
* Developed By  : TEK Systems
****************************************************************************************************************************************************/
@isTest
public class OLEUpdateFromContactTest{
    public static Provider__c p1;
    public static Facility__c f1;
    public static Provider_Facility__c pf1;
    /*public static void setupdata(){
           p1 = new Provider__c(Master_Provider_Id__c = 'TestMP1',Provider_First_Name__c = 'TestProviderFN1',Provider_Last_Name__c = 'TestProviderLN1');
           insert p1;
           f1 = new Facility__c(Master_Facility_Id__c = 'TestMF1',Facility_Name__c='facilityname1');
           insert f1;
           pf1 = new Provider_Facility__c(Facility__c = f1.id,Provider__c = p1.id ,Master_Provider_Facility_ID__c = 'TestMPF1');
           insert pf1;
           
    }*/
    @isTest
    static void TestOLEUpdate(){
        //setupdata();
        Test.StartTest();
        //Create online enrollment record. Affter insert of OLE account ,contact and opportunity records are created.
        Online_Enrollment__c oe = new Online_Enrollment__c();
         oe.Primary_First_Name__c = 'Sam';
         oe.Primary_Last_Name__c = 'Smith';
         oe.Primary_Home_Phone__c = '1234567901';
         oe.Birth_Date_of_Primary__c = Date.today();
         oe.Primary_Address__c = 'St Marks road';
         oe.Primary_City__c = 'Texas';
         oe.Primary_State__c = 'Texas';
         oe.Primary_Country__c = 'United States';
         oe.Primary_Zipcode__c = '73301';
         oe.Primary_Email__c = 'samsmith@example.com';
         oe.Primary_Role__c='Mother';
         oe.of_CB__c = '1';
         oe.of_CT__c = '1';
         oe.Due_Date__c = System.today();
         oe.Adoption_Type__c = 'Open';
         oe.Ship_to_first_name__c = 'Shipnametest';
         oe.Ship_to_Last_Name__c = 'lastnametest';
         oe.Source_Code__c = 'Scode';
         oe.Promo_Code__c = 'Pcode';
         oe.Last_4_Digits__c = '1221';
         oe.Ship_Kit_Flag__c = true;
         oe.Primary_ID_Type__c = 'Passport #';
         oe.PrimaryID__c = '1234554454677';
         insert oe;
         
         //Query on contact to get primary contact if ID_Type__c is not null on contact then that contact is primary contact.
        contact con = [select id,ID_Type__c,Birthdate,Online_Enrollment__c,Opportunity_Status__c,ID_Information__c,Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode from contact where Online_Enrollment__c =:oe.id];
         
         con.ID_Type__c = 'Other Government Issued Id #';
         con.Birthdate = Date.Today().addDays(-10);
         con.ID_Information__c = '9868765643333';
         con.Phone = '9966636353';
         con.MailingStreet = 'Mst';
         con.MailingCity = 'Tucson';
         con.MailingState = 'Arizona';
         con.MailingPostalCode = '85710';
        
        update con;
        
         //Query in OLE to check primary contact's First Name and last name updated when the above contact is updated.
         Online_Enrollment__c oerec = [select id,Primary_Contact_Id__c,Primary_Address__c,Primary_City__c,Primary_State__c,Primary_Zipcode__c,Birth_Date_of_Primary__c,Primary_Home_Phone__c,Primary_ID_Type__c,PrimaryID__c from Online_Enrollment__c where id =: oe.id];
         
        system.AssertEquals(con.ID_Type__c,oerec.Primary_ID_Type__c);
        system.AssertEquals(con.ID_Information__c,oerec.PrimaryID__c);
        system.AssertEquals(con.BirthDate,oerec.Birth_Date_of_Primary__c);
        system.AssertEquals(con.Phone,oerec.Primary_Home_Phone__c);
        system.AssertEquals(con.MailingStreet,oerec.Primary_Address__c);
        system.AssertEquals(con.MailingState,oerec.Primary_State__c);
        system.AssertEquals(con.MailingCity,oerec.Primary_City__c);
        system.AssertEquals(con.MailingPostalCode,oerec.Primary_Zipcode__c);
         Test.StopTest();
        
    }
}
@isTest
public class AccountContactRelatedRecsInsertTest {
    public static List<Provider__c> providerList;
    public static Provider__c p1;
    public static Provider__c p2;
    public static Provider__c p3;
    public static List<Facility__c> facilityList;
    public static Facility__c f1;
    public static Facility__c f2;
    public static Facility__c f3;
    public static List<Provider_Facility__c> providerfacilityList;
    public static Provider_Facility__c pf1;
    public static Provider_Facility__c pf2;
    public static Provider_Facility__c pf3;
    
    public static void setupData(){
       Campaign c = new Campaign(Name ='TestCampaign',Campaign_Code__c='Test');
       insert c;
       Campaign c1 = new Campaign(Name ='TestCamId1',Campaign_Code__c='Scode');
       insert c1;
       Campaign c2 = new Campaign(Name ='TestCamId2',Campaign_Code__c='Pcode');
       insert c2;
         
       providerList = new List<Provider__c>();
       p1 = new Provider__c(Master_Provider_Id__c = 'TestMP1',Provider_First_Name__c = 'TestProviderFN1',Provider_Last_Name__c = 'TestProviderLN1');
       p2 = new Provider__c(Master_Provider_Id__c = 'TestMP2',Provider_First_Name__c = 'TestProviderFN2',Provider_Last_Name__c = 'TestProviderLN2');
       p3 = new Provider__c(Master_Provider_Id__c = 'TestMP3',Provider_First_Name__c = 'TestProviderFN3',Provider_Last_Name__c = 'TestProviderLN3');

       providerList.add(p1);
       providerList.add(p2);
       providerList.add(p3);
       insert providerList;
 
       facilityList = new List<Facility__c>();
       f1 = new Facility__c(Master_Facility_Id__c = 'TestMF1',Facility_Name__c='facilityname1');
       f2 = new Facility__c(Master_Facility_Id__c = 'TestMF2',Facility_Name__c='facilityname2');
       f3 = new Facility__c(Master_Facility_Id__c = 'TestMF3',Facility_Name__c='facilityname2');
       facilityList.add(f1);
       facilityList.add(f2);
       facilityList.add(f3);
       insert facilityList;

       providerfacilityList = new List<Provider_Facility__c>();
       pf1 = new Provider_Facility__c(Facility__c = f1.id,Provider__c = p1.id ,Master_Provider_Facility_ID__c = 'TestMPF1');
       pf2 = new Provider_Facility__c(Facility__c = f2.id,Provider__c = p2.id,Master_Provider_Facility_ID__c = 'TestMPF2');
       pf3 = new Provider_Facility__c(Facility__c = f3.id,Provider__c = p3.id,Master_Provider_Facility_ID__c = 'TestMPF3');

       providerfacilityList.add(pf1);
       providerfacilityList.add(pf2);
       providerfacilityList.add(pf3); 
       insert providerfacilityList;
    }
    //Test to check account,contact,Opp,OppContactRole, opp Provider and contact payment profile.
    static testMethod void AccountCreateTest(){
       
      setupData();
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
      oe.Provider_ID__c= 'TestMP2';
      oe.Primary_Email__c = 'samsmith@example.com';
      oe.Primary_Role__c='Mother';
      oe.of_CB__c = '1';
      oe.of_CT__c = '1';
      oe.Due_Date__c = System.today();
      oe.Adoption_Type__c = 'Open';
      oe.Provider_First_Name__c = 'Tom';
      oe.Provider_Last_Name__c = 'Raider';
      oe.PrimaryID__c ='TestMP2';
      oe.Provider_State__c = 'LA';
      oe.Provider_City__c = 'Chicago';
      oe.Provider_Address__c = 'Times Square';
      oe.Provider_Facility_ID__c = 'TestMPF2';
      oe.Hospital_Id__c = 'TestMF2';
      oe.Hospital_Address__c = 'St Anees Road';
      oe.Hospital_City__c = 'Southhamptom';
      oe.Hospital_Name__c ='Forbes';
      oe.Hospital_State__c = 'London';  
      oe.Provider_City__c = 'Japan';
      oe.Provider_Address__c='St Johns';
      oe.Secondary_First_Name__c = 'TestS';
      oe.Secondary_Last_Name__c = 'TestLN00';
      oe.Secondary_Role__c = 'Father';
      oe.Ship_to_first_name__c = 'Shipnametest';
      oe.Ship_to_Last_Name__c = 'lastnametest';
      oe.Campaign_ID_2__c = 'TestCampaign';
      oe.Source_Code__c = 'Scode';
      oe.Promo_Code__c = 'Pcode';
      oe.Last_4_Digits__c = '1221';
      oe.Ship_Kit_Flag__c = true;
      oe.Completed_Flag__c  = true;
      oe.How_Did_You_Hear__c = 'Article/News Story';
      insert oe;
         
      //Check Account creation for OLE
      Account acc= [Select id,name,Online_Enrollment__c from account where Online_Enrollment__c =: oe.id limit 1];
      System.assertEquals(acc.Online_Enrollment__c, oe.Id);

      //Check Contact Creation for OLE
      List<Contact> contList = [select id,Online_Enrollment__c,AccountId from contact where AccountId =: acc.id];
      system.assertEquals(contList.size(),2);

      //Opportunity creation for OLE
      Opportunity opp = [select id,Online_Enrollment__c,AccountId,Delivering_Hospital__c,PickUp_or_Ship_Kit__c,stageName,LeadSource from opportunity where AccountId =: acc.id];
      system.assertEquals(opp.Online_Enrollment__c, oe.id);
      system.assertEquals(opp.PickUp_or_Ship_Kit__c,'Ship');
      system.assertEquals(opp.StageName,'Won (9)');
      system.assertEquals(opp.LeadSource,'Online Enrollment');
      //Check delivering hospital on opportunity
      system.assertEquals(opp.Delivering_Hospital__c,f2.id);

      //check opportunity providerList
      Opportunity_Provider__c op= [select id,Opportunity__c,Provider__c,Facility__c,Primary_Provider__c,Provider_Facility__c from Opportunity_Provider__c where Opportunity__c =:opp.id];

      system.assertEquals(op.Provider__c,p2.id);
      system.assertEquals(op.Provider_Facility__c,pf2.id);
      system.assertEquals(op.Primary_Provider__c,true);
      system.assertEquals(op.Facility__c,f2.id);

      //Check contact payment profile
      Contact_Payment_Profile__c cpp = [select id,Contact__c,Contact__r.Online_Enrollment__c,Last_4_Digits__c from Contact_Payment_Profile__c where Contact__r.Online_Enrollment__c = : oe.id];
      system.assertEquals(cpp.Last_4_Digits__c,oe.Last_4_Digits__c);
      Test.StopTest();

      //Check campaign influence records creation
      List<CampaignInfluence> CiList = [Select id,OpportunityId,CampaignId,Campaign.Campaign_Code__c from CampaignInfluence Where OpportunityId =: opp.id];
      system.assertEquals(CiList.size(),3);
               
    }
    
    //Repeat Client testing
    static testMethod void OppStageWonTest(){
      setupData();
      Test.StartTest();
      //Create OLE
      Online_Enrollment__c oe1 = new Online_Enrollment__c();
      oe1.Cardholder_Name__c ='Test';
      oe1.Primary_First_Name__c = 'SamTom';
      oe1.Primary_Last_Name__c = 'SmithTt';
      oe1.Primary_Home_Phone__c = '1234567000';
      oe1.Birth_Date_of_Primary__c = Date.today();
      oe1.Primary_Address__c = 'St Marks road';
      oe1.Primary_City__c = 'Texas';
      oe1.Primary_State__c = 'Texas';
      oe1.Primary_Country__c = 'United States';
      oe1.Primary_Zipcode__c = '73301';
      //oe1.Primary_ID__c= 'TestMP2';
      oe1.Primary_Email__c = 'samtest@example.com';
      oe1.Primary_Role__c='Mother';
      oe1.of_CB__c = '1';
      oe1.of_CT__c = '1';
      oe1.Due_Date__c = System.today();
      oe1.Adoption_Type__c = 'Open';
      oe1.Secondary_First_Name__c = 'TestSerw';
      oe1.Secondary_Last_Name__c = 'TestLN00tt';
      oe1.Secondary_Role__c = 'Father';
      oe1.Primary_ID_Type__c = 'Passport #';
      oe1.PrimaryID__c = '1234554454677';
      oe1.Credit_Card_Profile_ID__c = '332200998877456';
      oe1.Credit_Card_Type__c = 'MasterCard';
      oe1.Expiration_Year__c = '2025';
      oe1.CC_Expiration_Month__c = '6';
      oe1.Last_4_Digits__c = '8877';
      //Insert OLE
      insert oe1;

      //query on contacts whose OLE id is oe1. Update SCSS id of primary contact and secondary contact.
      List<Contact> conList = [select id,SCSS_Contact_Id__c,Online_Enrollment__c,ID_Type__c,AccountId from contact where Online_Enrollment__c =:oe1.id];
      
      Contact PrimaryCon = new contact();
      contact secCont = new Contact();
      
      for(contact c:conList){
          if(String.isNotBlank(c.ID_Type__c)){
              PrimaryCon = c;
          }
          else{
             secCont = c; 
          }
      }
         
      //Update Primary contact SCSS id
      PrimaryCon.SCSS_Contact_Id__c = 'RepeatClientId';
      update PrimaryCon;

      //Update Secondary contactSCSS Id
      secCont.SCSS_Contact_Id__c = 'SecRepeatClient';
      update secCont;

      system.debug('contact SCSS_Contact_Id__c ======'+PrimaryCon.SCSS_Contact_Id__c);
      //OLE with Primary and Secondary SCSS Id field values. For this OLE we query on contact for exisitng primary and secondary contacts
      Online_Enrollment__c oe2 = new Online_Enrollment__c();
      oe2.Cardholder_Name__c ='TestName';
      oe2.Primary_First_Name__c = 'SamTom';
      oe2.Primary_Last_Name__c = 'SmithTt';
      oe2.Primary_Home_Phone__c = '1234567000';
      oe2.Birth_Date_of_Primary__c = Date.today();
      oe2.Primary_Address__c = 'St Marks road';
      oe2.Primary_City__c = 'Texas';
      oe2.Primary_State__c = 'Texas';
      oe2.Primary_Country__c = 'United States';
      oe2.Primary_Zipcode__c = '73301';
      oe2.PrimaryID__c= 'TestMP2';
      oe2.Primary_Email__c = 'samtest11@example.com';
      oe2.Primary_Role__c='Mother';
      oe2.of_CB__c = '1';
      oe2.of_CT__c = '1';
      oe2.Due_Date__c = System.today();
      oe2.Adoption_Type__c = 'Open';
      oe2.Secondary_First_Name__c = 'TestSerw';
      oe2.Secondary_Last_Name__c = 'TestLN00tt';
      oe2.Secondary_Role__c = 'Father';
      oe2.Ship_to_first_name__c = 'Shipnametest';
      oe2.Completed_Flag__c  = true;
      oe2.Primary_Contact_SCSS_Id__c = 'RepeatClientId';
      oe2.Repeat_Client__c = true;
      oe2.Secondary_Contact_SCSS_Id__c = 'SecRepeatClient';
      oe2.Credit_Card_Profile_ID__c = '33221111877456';
      oe2.Credit_Card_Type__c = 'MasterCard';
      oe2.Expiration_Year__c = '2024';
      oe2.CC_Expiration_Month__c = '6';
      oe2.Last_4_Digits__c = '8811';
         
      //Insert OLE with repeat client
      insert oe2;
      //Query on opportunity to check duplicate opps not created
      List<opportunity> opplist = [Select id,name,Online_Enrollment__c from opportunity where Online_Enrollment__c =: oe2.id];
      system.debug('count opps'+opplist.size());
      system.assertEquals(opplist.size(),1);
      //Query on OLE to check its primary contact id and secondary contact id
      Online_Enrollment__c oerepeat = [select id,Primary_Contact_SCSS_Id__c,Primary_Contact_Id__c,Secondary_Contact__c from Online_Enrollment__c where id =:oe2.id];
      //Query on Contact payment profile to check dupliacte record is not created and existing record's is updated with new values for repeat client 
      Contact_Payment_Profile__c cpp = [select id,Contact__c,Credit_Card_Type__c,Profile_Token__c,Contact__r.Online_Enrollment__c from Contact_Payment_Profile__c Where Contact__r.Online_Enrollment__c =:oerepeat.id ];
      system.debug('oerepeat.Primary_Contact_Id__c'+oerepeat.Primary_Contact_Id__c);
      system.assertEquals(oerepeat.Primary_Contact_Id__c,PrimaryCon.id);
      system.assertEquals(cpp.Profile_Token__c,oe2.Credit_Card_Profile_ID__c);
      system.assertEquals(oerepeat.Secondary_Contact__c,secCont.id);

      //Test record to check newSecondary contact is created if secondary contact SCSS id is not provided on OLE.
      Online_Enrollment__c oe3 = new Online_Enrollment__c();
      oe3.Cardholder_Name__c ='TestName';
      oe3.Primary_First_Name__c = 'SamTom';
      oe3.Primary_Last_Name__c = 'SmithTt';
      oe3.Primary_Home_Phone__c = '1234567000';
      oe3.Birth_Date_of_Primary__c = Date.today();
      oe3.Primary_Address__c = 'St Marks road';
      oe3.Primary_City__c = 'Texas';
      oe3.Primary_State__c = 'Texas';
      oe3.Primary_Country__c = 'United States';
      oe3.Primary_Zipcode__c = '73301';
      oe3.PrimaryID__c= 'TestMP2';
      oe3.Primary_Email__c = 'samtest11@example.com';
      oe3.Primary_Role__c='Mother';
      oe3.of_CB__c = '1';
      oe3.of_CT__c = '1';
      oe3.Due_Date__c = System.today();
      oe3.Adoption_Type__c = 'Open';
      oe3.Secondary_First_Name__c = 'TestNewSecondary';
      oe3.Secondary_Last_Name__c = 'NewLN';
      oe3.Secondary_Role__c = 'Father';
      oe3.Primary_Contact_SCSS_Id__c = 'RepeatClientId';
      oe3.Repeat_Client__c = true;
          Test.StopTest();
      //Insert OLE
      insert oe3;
      
      //Query on OLE object 
      Online_Enrollment__c oerepeat1 = [select id,Primary_Contact_SCSS_Id__c,Primary_Contact_Id__c,Secondary_Contact__c,Opportunity_Id__c from Online_Enrollment__c where id =:oe3.id];
      //Query on contact weather new secondary contact is created.
      Contact newSecContact = [select id,Name,SCSS_Contact_Id__c,AccountId,Online_Enrollment__c from Contact Where FirstName = 'TestNewSecondary' AND LastName = 'NewLN' ];
      system.assertEquals(newSecContact.SCSS_Contact_Id__c,null);
      system.assertEquals(newSecContact.Online_Enrollment__c,oe3.id);
      system.assertEquals(newSecContact.AccountId,PrimaryCon.AccountId);
      system.assertEquals(oerepeat1.Primary_Contact_Id__c,PrimaryCon.id);
      //Query on OpportunityContactRole to check 2 OppCon Roles are created 
      List<OpportunityContactRole> OCRList = [Select id,ROle,OpportunityId,ContactId,isPrimary from OpportunityContactRole where OpportunityId =:oerepeat1.Opportunity_Id__c];
      system.assertEquals(OCRList.size(),2);
      OpportunityContactRole PrimaryOCR = new OpportunityContactRole();
      OpportunityContactRole secondaryOCR = new OpportunityContactRole();
      
      for(OpportunityContactRole ocr:OCRList){
        if(ocr.isPrimary){
            PrimaryOCR = ocr;
        }
        else{
            secondaryOCR = ocr;
        }
      }
      system.assertEquals(PrimaryOCR.Role,oe3.Primary_Role__c);
      system.assertEquals(secondaryOCR.Role,oe3.Secondary_Role__c);

       Online_Enrollment__c oe4 = new Online_Enrollment__c();
      oe4.Cardholder_Name__c ='TestName';
      oe4.Primary_First_Name__c = 'SamTom';
      oe4.Primary_Last_Name__c = 'SmithTt';
      oe4.Primary_Home_Phone__c = '1234567000';
      oe4.Birth_Date_of_Primary__c = Date.today();
      oe4.Primary_Address__c = 'St Marks road';
      oe4.Primary_City__c = 'Texas';
      oe4.Primary_State__c = 'Texas';
      oe4.Primary_Country__c = 'United States';
      oe4.Primary_Zipcode__c = '73301';
      oe4.PrimaryID__c= 'TestMP2';
      oe4.Primary_Email__c = 'samtest11@example.com';
      oe4.Primary_Role__c='Mother';
      oe4.of_CB__c = '1';
      oe4.of_CT__c = '1';
      oe4.Due_Date__c = System.today();
      oe4.Adoption_Type__c = 'Open';
      oe4.Primary_Contact_SCSS_Id__c = 'RepeatClientId';
      oe4.Repeat_Client__c = true;
      oe4.Secondary_Contact_SCSS_Id__c = 'SecRepeatClient';  
      //Insert OLE
     
      insert oe4;

      opportunity opty4= [Select id,Online_Enrollment__c from Opportunity where Online_Enrollment__c =: oe4.id];
      OpportunityContactRole ocr4 = [select id,Role,opportunityid,contactId,contact.SCSS_Contact_Id__c from OpportunityContactRole where opportunityid =:opty4.id AND contact.SCSS_Contact_Id__c = 'SecRepeatClient'];
      system.assertEquals(ocr4.Role,'Unknown');

      
    }
}
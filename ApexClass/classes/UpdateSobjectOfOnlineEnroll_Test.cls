@isTest
public class UpdateSobjectOfOnlineEnroll_Test{
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
    
    //Creation of Provider, facility and provider facility records is in setupdata method 
    public static void setupdata(){
        providerList = new List<Provider__c>();
         p1 = new Provider__c(Master_Provider_Id__c = 'TestMP1',Provider_First_Name__c = 'TestProviderFN1',Provider_Last_Name__c = 'TestProviderLN1');
         p2 = new Provider__c(Master_Provider_Id__c = 'TestMP2',Provider_First_Name__c = 'TestProviderFN2',Provider_Last_Name__c = 'TestProviderLN2');
         p3 = new Provider__c(Master_Provider_Id__c = 'TestMP3',Provider_First_Name__c = 'TestProviderFN3',Provider_Last_Name__c = 'TestProviderLN3');
         providerList.add(p1);
         providerList.add(p2);
         providerList.add(p3);
 
         insert providerList;
        system.debug('providerList'+providerList);
        
        facilityList = new List<Facility__c>();
        f1 = new Facility__c(Master_Facility_Id__c = 'TestMF1',Facility_Name__c='facilityname1');
        f2 = new Facility__c(Master_Facility_Id__c = 'TestMF2',Facility_Name__c='facilityname2');
        f3 = new Facility__c(Master_Facility_Id__c = 'TestMF3',Facility_Name__c='facilityname2');
        facilityList.add(f1);
        facilityList.add(f2);
        facilityList.add(f3);
        insert facilityList;

        system.debug('facilityList'+facilityList);
        providerfacilityList = new List<Provider_Facility__c>();
        pf1 = new Provider_Facility__c(Facility__c = f1.id,Provider__c = p1.id ,Master_Provider_Facility_ID__c = 'TestMPF1');
        pf2 = new Provider_Facility__c(Facility__c = f2.id,Provider__c = p2.id,Master_Provider_Facility_ID__c = 'TestMPF2');
        pf3 = new Provider_Facility__c(Facility__c = f3.id,Provider__c = p3.id,Master_Provider_Facility_ID__c = 'TestMPF3');

        providerfacilityList.add(pf1);
        providerfacilityList.add(pf2);
        providerfacilityList.add(pf3);
        insert providerfacilityList;
    }
    //Setup OLE
    @testSetup static void OLESetup(){
        Online_Enrollment__c ole = new Online_Enrollment__c(of_Babies__c = 'Single',of_CB__c='1',of_CT__c='1',Adoption_Type__c = 'Open',Birth_Date_of_Primary__c = system.today(),CB_Storage_Fee_Option__c = 'Annual Storage',CT_Storage_Fee_Option__c = 'Annual Storage', Due_Date__c = system.today(), Hospital_Address__c = 'testHA123', Hospital_City__c = 'TestHC123',Hospital_Country__c = 'HC123Test', Hospital_Id__c = 'TestMF2', Hospital_Name__c = 'facilityname2', Hospital_State__c = 'Texas', Hospital_Zip_Code__c = '73301', Online_Enrollment_External_Id__c = 'testOnline1233', Payment_Plan__c = 'Pay in Full',Primary_Address__c = 'mst Texas',Primary_Address_2__c='test',Primary_City__c = 'Texas', Primary_Country__c = 'United States',Primary_Email__c = 'OE1testtest33@gmail.com', Primary_First_Name__c='TestP23', Primary_Home_Phone__c= '9492475564', PrimaryID__c='77533', Primary_ID_Type__c = 'Passport #',Primary_Last_Name__c = 'TestPLN123',Primary_Mobile_Phone__c = '9988790655', Primary_Role__c = 'Mother', Primary_State__c = 'Texas',Primary_Zipcode__c = '73301');
           
           insert ole;
    }
    //Opportunity Update when OLE is updated.

   @isTest static void OLEOppUpdateTest(){
        setupdata();
        test.StartTest();
        Online_Enrollment__c oleOpp= [Select id,of_Babies__c,of_CB__c,of_CT__c,Adoption_Type__c,Birth_Date_of_Primary__c,CB_Storage_Fee_Option__c,CT_Storage_Fee_Option__c,Due_Date__c,Hospital_Id__c,Referrer_Name__c,Promo_Code__c,Ship_To_Street_Address__c,Ship_To_Addr_2__c,Ship_To_City__c,Ship_To_Country__c,Ship_To_State__c,Ship_To_Zip_Code__c,Completed_Flag__c,Payment_Plan__c,Ship_to_first_name__c,Ship_to_Last_Name__c,How_Did_You_Hear__c,Primary_Address__c,Primary_Address_2__c,Primary_City__c,Primary_Country__c,Primary_Zipcode__c,Primary_State__c from Online_Enrollment__c];
        oleOpp.of_Babies__c = 'Twins';
        oleOpp.of_CB__c = '2';
        oleOpp.of_CT__c = '2';
        oleOpp.Adoption_Type__c = 'Surrogate';
        oleOpp.Birth_Date_of_Primary__c = system.today().AddDays(-10);
        oleOpp.CB_Storage_Fee_Option__c = 'Lifetime';
        oleOpp.CT_Storage_Fee_Option__c = 'Lifetime';
        oleOpp.Due_Date__c = system.today().AddDays(2);
        //oleOpp.Hospital_Id__c = 'TestMF1';
        oleOpp.Referrer_Name__c = 'TestReff';
        oleOpp.Promo_Code__c = 'TestPromoCOde';
        oleOpp.Ship_To_Addr_2__c= 'TestSTA';
        oleOpp.Ship_To_Street_Address__c = 'mst';
        oleOpp.Ship_To_City__c = 'Texas';
        oleOpp.Ship_To_Country__c = 'United States';
        oleOpp.Ship_To_State__c = 'Texas';
        oleOpp.Ship_To_Zip_Code__c = '73301';
        //oleOpp.Completed_Flag__c = true;
        oleOpp.Payment_Plan__c = '12 Months Plan';
        oleOpp.Ship_to_first_name__c = 'testSFN';
        oleOpp.Ship_to_Last_Name__c = 'testLN';
        
        //Update OLE and check opportunity fields also updated
        update oleOpp;

        List<Opportunity> oppList = [Select id,of_Babies__c,of_CB__c,of_CT__c,Adoption_Type__c,CB_Storage_Fee_Option__c,CT_Storage_Fee_Option__c,Due_Date__c,Delivering_Hospital__c,Delivering_Hospital__r.Master_Facility_Id__c,Referral_Name__c,Promo_Code__c,Ship_To_Street2__c,Ship_To_Street1__c,Ship_To_City__c,Ship_To_Country__c,Ship_To_Name__c,Ship_To_Phone__c,Ship_To_State__c,Ship_To_Zip_Code__c,Primary_Source__c,Completed_Flag__c,StageName,Status__c,Online_Enrollment__c,Primary_Contact__c,Primary_Contact__r.MailingCity,Primary_Contact__r.MailingState,Primary_Contact__r.MailingPostalCode from Opportunity where Online_Enrollment__c =: oleOpp.id];
        system.assertEquals(oppList.size(),1);
        system.assertEquals(oleOpp.of_Babies__c,oppList[0].of_Babies__c);
       // system.assertEquals(oleOpp.Hospital_Id__c,oppList[0].Delivering_Hospital__r.Master_Facility_Id__c);
        system.assertEquals(oleOpp.Referrer_Name__c,oppList[0].Referral_Name__c);
        system.assertEquals(oleOpp.Promo_Code__c,oppList[0].Promo_Code__c);
        system.assertEquals(oleOpp.of_CB__c,oppList[0].of_CB__c);
        system.assertEquals(oleOpp.of_CT__c,oppList[0].of_CT__c);
        system.assertEquals(oleOpp.Adoption_Type__c,oppList[0].Adoption_Type__c);
        system.assertEquals(oleOpp.How_Did_You_Hear__c,oppList[0].Primary_Source__c);
        system.assertEquals(oleOpp.CB_Storage_Fee_Option__c,oppList[0].CB_Storage_Fee_Option__c);
        system.assertEquals(oleOpp.CT_Storage_Fee_Option__c,oppList[0].CT_Storage_Fee_Option__c);
        system.assertEquals(oleOpp.Due_Date__c,oppList[0].Due_Date__c);
        //system.assertEquals(oleOpp.Completed_Flag__c,oppList[0].Completed_Flag__c);

       Test.StopTest();
    } 
    @isTest static void Unittest1(){
      setupdata();
        test.StartTest();
        Online_Enrollment__c oleOpp= [Select id,of_Babies__c,of_CB__c,of_CT__c,Adoption_Type__c,Birth_Date_of_Primary__c,CB_Storage_Fee_Option__c,CT_Storage_Fee_Option__c,Due_Date__c,Hospital_Id__c,Referrer_Name__c,Promo_Code__c,Ship_To_Street_Address__c,Ship_To_Addr_2__c,Ship_To_City__c,Ship_To_Country__c,Ship_To_State__c,Ship_To_Zip_Code__c,Completed_Flag__c,Payment_Plan__c,Ship_to_first_name__c,Ship_to_Last_Name__c,How_Did_You_Hear__c,Primary_Address__c,Primary_Address_2__c,Primary_City__c,Primary_Country__c,Primary_Zipcode__c,Primary_State__c,Primary_Contact_Id__c from Online_Enrollment__c];
       // oleOpp.How_Did_You_Hear__c = 'Article/News Story';
        oleOpp.Primary_Address__c = 'mstsds';
        oleOpp.Primary_Address_2__c = 'mstddd';
        oleOpp.Primary_City__c = 'Tucson';
        oleOpp.Primary_Zipcode__c = '85710';
        oleOpp.Primary_State__c = 'Arizona';
        update oleOpp;
        system.debug('oleOpp.Primary_City__c========'+oleOpp.Primary_City__c);
        system.debug('oleOpp.Primary_Zipcode__c========'+oleOpp.Primary_Zipcode__c);
        system.debug('oleOpp.Primary_State__c========'+oleOpp.Primary_State__c);
       system.debug('oleOpp.Primary_Address__c---------'+oleOpp.Primary_Address__c);
       system.debug('oleOpp.Primary_Address_2__c--------'+oleOpp.Primary_Address_2__c);
       Contact c = [Select id,MailingStreet,MailingState,MailingPostalCode,MailingCity from Contact where Id =:oleOpp.Primary_Contact_Id__c];
        system.debug('c============'+c);
      
        system.assertEquals(oleOpp.Primary_City__c,c.MailingCity);
        system.assertEquals(oleOpp.Primary_Zipcode__c,c.MailingPostalCode);
        system.assertEquals(oleOpp.Primary_State__c,c.MailingState);
        test.StopTest();
    } 
    //Secondary contact Creation
    @isTest static void SecondaryConCreateTest(){
        setupdata();
        test.StartTest();
        Online_Enrollment__c oleOpp = [Select Id,Secondary_First_Name__c,Secondary_Last_Name__c,Secondary_Role__c from Online_Enrollment__c];
        oleOpp.Secondary_First_Name__c = 'TestSFN';
        oleOpp.Secondary_Last_Name__c = 'TestLN';
        oleOpp.Secondary_Role__c = 'Father';
        //Update OLE secondary contact details and check secondary contact is created and opportunityContactRole is created
        update oleOpp;

        List<Contact> contList = [Select id,FirstName,LastName,Online_Enrollment__c,ID_Type__c From contact where Online_Enrollment__c =:oleOpp.id];
            system.assertEquals(contList.size(),2);
            contact SecondaryCont = new contact();
            for(Contact c:contList){
                if(String.isBlank(c.ID_Type__c)){
                    SecondaryCont = c;
                }
            }

            system.assertEquals(SecondaryCont.FirstName,oleOpp.Secondary_First_Name__c);
            system.assertEquals(SecondaryCont.LastName,oleOpp.Secondary_Last_Name__c);
            //Query on OpportunityContactRole for secondary contact 
            List<OpportunityContactRole> OCRSecondary = [select id,ContactId from OpportunityContactRole where ContactId =:SecondaryCont.id];
            system.assertEquals(OCRSecondary.size(),1);
            Test.StopTest();
    }
    //Create and update Contact Payment profile
    @isTest static void ContactPayProfileTest(){
        setupdata();
        Test.StartTest();
         Online_Enrollment__c oleOpp = [select id,Credit_Card_Profile_ID__c,Credit_Card_Type__c,CC_Expiration_Month__c,Cardholder_Name__c,Expiration_Year__c,Last_4_Digits__c,Primary_Contact_Id__c from Online_Enrollment__c];
         oleOpp.Credit_Card_Profile_ID__c = '1122334466';
        oleOpp.Credit_Card_Type__c = 'Visa';
        oleOpp.CC_Expiration_Month__c = '1';
        oleOpp.Cardholder_Name__c = 'TestCN123';
        oleOpp.Expiration_Year__c = '2022';
        oleOpp.Last_4_Digits__c = '1234';
        //Update OLE and verify new contact payment profile record is created.
        update oleOpp;


Contact_Payment_Profile__c cpp = [select id,Contact__c,Card__c,Profile_Token__c,Contact__r.Online_Enrollment__c from Contact_Payment_Profile__c];
    system.assertEquals(cpp.Profile_Token__c,oleOpp.Credit_Card_Profile_ID__c );
    system.assertEquals(cpp.Contact__r.Online_Enrollment__c,oleOpp.id);
    system.assertEquals(cpp.Contact__c,oleOpp.Primary_Contact_Id__c);

        oleOpp.Credit_Card_Profile_ID__c = '11223344663311';
        oleOpp.Credit_Card_Type__c = 'MasterCard';
        oleOpp.CC_Expiration_Month__c = '2';
        oleOpp.Cardholder_Name__c = 'TestCN11232';
        oleOpp.Expiration_Year__c = '2025';
        oleOpp.Last_4_Digits__c = '1224';
        //Update OLE and verify existing contact payment profile record is updated.
        update oleOpp;

        Contact_Payment_Profile__c cpp1 = [select id,Contact__c,Card__c,Profile_Token__c,Contact__r.Online_Enrollment__c from Contact_Payment_Profile__c];
    system.assertEquals(cpp1.Profile_Token__c,oleOpp.Credit_Card_Profile_ID__c);
    system.assertEquals(cpp1.Contact__r.Online_Enrollment__c,oleOpp.id);
    system.assertEquals(cpp1.Contact__c,oleOpp.Primary_Contact_Id__c);

        Test.StopTest();
    }
    //Test to Check Opportunity Provider create and update
    @isTest static void OppProviderTest(){
        setupdata();
        Test.startTest();
        Online_Enrollment__c oleOpp = [select id,Provider_Facility_ID__c,Provider_ID__c,Hospital_Id__c from Online_Enrollment__c];
        oleOpp.Provider_Facility_ID__c = 'TestMPF1';
    oleOpp.Provider_ID__c = 'TestMP1';
    //Update OLE with provider Id and Provider facility master ids and verify new opp provider is created
    update oleOpp;
     List<Opportunity_Provider__c> op=[select id,Provider__c,Primary_Provider__c,Provider__r.Master_Provider_Id__c,Provider_Facility__c,Provider_Facility__r.Master_Provider_Facility_ID__c,Opportunity__c,Opportunity__r.Online_Enrollment__c,Opportunity__r.Status__c from Opportunity_Provider__c Where Opportunity__r.Online_Enrollment__c = :oleOpp.id];

    system.assertEquals(oleOpp.Provider_Facility_ID__c,op[0].Provider_Facility__r.Master_Provider_Facility_ID__c);
    system.assertEquals(oleOpp.Provider_ID__c,op[0].Provider__r.Master_Provider_Id__c);
    system.assertEquals(op[0].Primary_Provider__c,true);
    system.assertEquals(op.size(),1);
    oleOpp.Provider_Facility_ID__c = 'TestMPF2';
    oleOpp.Provider_ID__c = 'TestMP2';
    //update OLE's provider facility id and provider id. And verify values on opportunity provider also updated.
    update oleOpp;


      Opportunity_Provider__c op1=[select id,Provider__c,Primary_Provider__c,Provider__r.Master_Provider_Id__c,Provider_Facility__c,Provider_Facility__r.Master_Provider_Facility_ID__c,Opportunity__c,Opportunity__r.Online_Enrollment__c,Opportunity__r.Status__c from Opportunity_Provider__c Where Opportunity__r.Online_Enrollment__c = :oleOpp.id ];
      system.assertEquals(op1.Provider__r.Master_Provider_Id__c,'TestMP2');
      system.assertEquals(op1.Provider_Facility__r.Master_Provider_Facility_ID__c,'TestMPF2');

      //update OLE's provider facility id and provider id. And verify Primary_Provider__c field on opportunity proivder is unchecked
    oleOpp.Provider_Facility_ID__c = null;
    oleOpp.Provider_ID__c = null;
    update oleOpp;

    Opportunity_Provider__c op2 = [select id,Provider__c,Primary_Provider__c,Provider__r.Master_Provider_Id__c,Provider_Facility__c,Provider_Facility__r.Master_Provider_Facility_ID__c,Opportunity__c,Opportunity__r.Online_Enrollment__c,Opportunity__r.Status__c from Opportunity_Provider__c Where Opportunity__r.Online_Enrollment__c = :oleOpp.id ];
    system.assertEquals(op2.Primary_Provider__c,false);

     oleOpp.Provider_Facility_ID__c = 'TestMPF3';
    oleOpp.Provider_ID__c = 'TestMP3';
    update oleOpp;

Opportunity_Provider__c op3 = [select id,Provider__c,Primary_Provider__c,Provider__r.Master_Provider_Id__c,Provider_Facility__c,Provider_Facility__r.Master_Provider_Facility_ID__c,Opportunity__c,Opportunity__r.Online_Enrollment__c,Opportunity__r.Status__c from Opportunity_Provider__c Where Opportunity__r.Online_Enrollment__c = :oleOpp.id ];
    system.assertEquals(op3.Primary_Provider__c,true);

        Test.stopTest();

    }
    @isTest static void OppStageWonTest(){
        setupdata();
        Test.startTest();
        system.debug('Won Stage Check');
         Campaign c1 = new Campaign(Name ='TestCamId',Campaign_Code__c='Scode1');
         insert c1;
         Campaign c2 = new Campaign(Name ='TestCamId12',Campaign_Code__c='Pcode2');
         insert c2;

         Online_Enrollment__c oe = [Select id,Cardholder_Name__c,Provider_First_Name__c,Provider_Last_Name__c,Provider_ID__c,Provider_State__c,Provider_City__c,Provider_Address__c,Provider_Facility_ID__c,Hospital_Id__c,Hospital_Address__c,Hospital_City__c,Hospital_State__c,Ship_to_first_name__c,Ship_to_Last_Name__c,Completed_Flag__c,How_Did_You_Hear__c,Source_Code__c,Promo_Code__c,Opportunity_Id__c,Opportunity_Status__c from Online_Enrollment__c];
         system.debug('queried record...........'+oe);
         system.debug('Opportunity_Status__c'+oe.Opportunity_Status__c);
        system.debug('Hospital_Id__c========='+oe.Hospital_Id__c);
         oe.Provider_ID__c ='TestMP2';
         oe.Provider_State__c = 'LA';
         oe.Provider_City__c = 'Chicago';
         oe.Provider_Address__c = 'Times Square';
         oe.Provider_Facility_ID__c = 'TestMPF2';
        oe.Hospital_Id__c = 'TestMF3';
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
          oe.How_Did_You_Hear__c = 'Article/News Story';
          oe.Provider_First_Name__c = 'Tom';
         oe.Provider_Last_Name__c = 'Raider';
          oe.Completed_Flag__c = true;
          oe.Source_Code__c = 'Scode1';
          oe.Promo_Code__c = 'Pcode2';
          update oe;

          system.debug('oe record...........'+oe);
          Opportunity_Provider__c op3 = [select id,Provider__c,Primary_Provider__c,Provider__r.Master_Provider_Id__c,Provider_Facility__c,Provider_Facility__r.Master_Provider_Facility_ID__c,Opportunity__c,Opportunity__r.Online_Enrollment__c,Opportunity__r.Status__c from Opportunity_Provider__c Where Opportunity__r.Online_Enrollment__c = :oe.id ];
system.debug('op333333333333333333333'+op3);
          Opportunity o = [Select id,Online_Enrollment__c,Stagename,Delivering_Hospital__c,Status__c,Primary_Source__c,LeadSource,PickUp_or_Ship_Kit__c,Shipping_Method__c,Ship_To_Name__c,Requested_Shipping_Date__c,Ship_To_Street1__c from Opportunity where Online_Enrollment__c =: oe.id];
          system.debug('==========Delivering_Hospital__c'+o.Delivering_Hospital__c);
           system.debug('==========Primary_Source__c'+o.Primary_Source__c);
            system.debug('==========LeadSource'+o.LeadSource);
             system.debug('==========PickUp_or_Ship_Kit__c'+o.PickUp_or_Ship_Kit__c);
              system.debug('==========Shipping_Method__c'+o.Shipping_Method__c);
               system.debug('==========Ship_To_Name__c'+o.Ship_To_Name__c);
                system.debug('==========Requested_Shipping_Date__c'+o.Requested_Shipping_Date__c);
                 system.debug('==========Ship_To_Street1__c'+o.Ship_To_Street1__c);

          system.assertEquals(o.StageName,'Won (9)');

           List<CampaignInfluence> CiList = [Select id,OpportunityId,CampaignId,Campaign.Campaign_Code__c from CampaignInfluence Where OpportunityId =: o.id];
         system.assertEquals(CiList.size(),2);
          Test.stopTest();
    }
    //Check if secondary contact on OLE is updated when Secondary contact SCSS id is updated on OLE 
    @isTest static void SecondarySCSSIdTest(){
        setupdata();
        test.StartTest();
        Contact c = new Contact(FirstName='Testttt',LastName='LastNameCon',SCSS_Contact_Id__c = 'SCSSCode');
        insert c;
        Contact secondryCon = [select id,Online_Enrollment__c,FirstName,LastName,SCSS_Contact_Id__c from Contact where FirstName = 'Testttt' AND LastName='LastNameCon'];

        Online_Enrollment__c ole = [select id,Secondary_Contact_SCSS_Id__c,Secondary_Contact__c from Online_Enrollment__c];
        //secondryCon.Online_Enrollment__c = ole.id;
        

        ole.Secondary_Contact_SCSS_Id__c = 'SCSSCode';
        update ole;

        Online_Enrollment__c ole1 = [select id,Secondary_Contact_SCSS_Id__c,Secondary_Contact__c from Online_Enrollment__c where Id =: ole.id];
        //system.assertEquals(ole1.Secondary_Contact__c,secondryCon.id);
        system.assertEquals(ole.Secondary_Contact_SCSS_Id__c,secondryCon.SCSS_Contact_Id__c);

        List<OpportunityContactRole> ocr = [Select id,ContactId,OpportunityId from OpportunityContactRole where ContactId =:secondryCon.id ];
        system.debug('ocr--------------'+ocr);
        system.assertEquals(ocr.size(),1);

        Contact updatedContactOLEid = [select id,Online_Enrollment__c from Contact Where id =:secondryCon.id];
        system.assertEquals(updatedContactOLEid.Online_Enrollment__c,ole1.id);
        Test.stopTest();

    }
    
}
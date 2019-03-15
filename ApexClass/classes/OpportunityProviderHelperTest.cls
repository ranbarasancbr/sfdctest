/*
* This is a test class for OpportunityProviderHelper
* Created By: Tek Systems
*/
@isTest
private class OpportunityProviderHelperTest {
   @isTest static void ruleInsertTest(){
   
        List<Contact> contList = TestDataFactory.CreateAccountWithContacts();
        List<Opportunity> OppList = TestDataFactory.CreateOpportunitiesWithContactRoles();
        List<Facility__c> FacilityList = TestDataFactory.CreateFacilities();
        List<Provider__c> ProviderList = TestDataFactory.CreateProviders();
        List<Provider_Facility__c> PFList = TestDataFactory.CreateProviderFacilities(FacilityList,ProviderList);
        List<Opportunity_Provider__c> OPList = TestDataFactory.CreateOpportunityProviders(PFList,ProviderList,FacilityList,OppList);
       //List<Opportunity_Provider__c> OPList = new List<Opportunity_Provider__c>(); 
        OppList.add(new Opportunity(name = 'Test4',of_Babies__c = 'Single',
                                    StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',
                                    closeDate = system.today(),status__C = 'Enrolled',Due_Date__c = system.today().addDays(35),
                                    Ship_To_Street1__c = 'Texas mst',Ship_To_City__c = 'Texas',Ship_To_State__c = 'Texas',
                                    Ship_To_Zip_Code__c = '73301',Ship_To_Phone__c = '9900990099',
                                    Requested_Shipping_Date__c = system.today(),Ship_To_Name__c = 'testName',Description = 'Opportunity4'));
                              
         Test.startTest();                      
        upsert OppList;
        system.debug('OppList size...'+OppList.size());
        OPList.add(new Opportunity_Provider__c(Provider__c = ProviderList[0].id, Opportunity__c = OppList[3].id,Provider_Facility__c  = PFList[0].id,Facility__c = FacilityList[0].id));
        //OPList.add(new Opportunity_Provider__c(Provider__c = ProviderList[1].id, Opportunity__c = OppList[3].id,Provider_Facility__c  = PFList[1].id,Facility__c = FacilityList[1].id));
         upsert OPList;
        Map<Id,Opportunity_Provider__c> oldMap = new Map<Id,Opportunity_Provider__c>();
        OpportunityProviderHelper.rule(OPList,true,oldMap);
    Test.stopTest();
   }
  @isTest static void ruleUpdateTest(){
    Test.startTest();
    try{
      List<Contact> contList = TestDataFactory.CreateAccountWithContacts();
        List<Opportunity> OppList = TestDataFactory.CreateOpportunitiesWithContactRoles();
        List<Facility__c> FacilityList = TestDataFactory.CreateFacilities();
        List<Provider__c> ProviderList = TestDataFactory.CreateProviders();
        List<Provider_Facility__c> PFList = TestDataFactory.CreateProviderFacilities(FacilityList,ProviderList);
        List<Opportunity_Provider__c> OPList = TestDataFactory.CreateOpportunityProviders(PFList,ProviderList,FacilityList,OppList);
        OPList[0].Primary_Provider__c = true;
        OPList[0].Delivering_Provider__c = true;
        update OPList;
        Map<Id,Opportunity_Provider__c> oldMap = new Map<Id,Opportunity_Provider__c>();
        for(Opportunity_Provider__c op:OPList){
            oldMap.put(op.id,op);
        }
        OpportunityProviderHelper.rule(OPList,false,oldMap);
    }
    catch(Exception e){
      system.debug('Exception message'+e.getMessage());
    } 
    Test.stopTest();
   }
   @isTest static void multiplePrimaryDeliveringProviders(){
    Test.startTest();
    try{
        List<Contact> contList = TestDataFactory.CreateAccountWithContacts();
        List<Opportunity> OppList = TestDataFactory.CreateOpportunitiesWithContactRoles();
        List<Facility__c> FacilityList = TestDataFactory.CreateFacilities();
        List<Provider__c> ProviderList = TestDataFactory.CreateProviders();
        List<Provider_Facility__c> PFList = TestDataFactory.CreateProviderFacilities(FacilityList,ProviderList);
        List<Opportunity_Provider__c> OPList = TestDataFactory.CreateOpportunityProviders(PFList,ProviderList,FacilityList,OppList);
        OPList[0].Primary_Provider__c = true;
        OPList[0].Delivering_Provider__c = true;
       OPList.add(new Opportunity_Provider__c(Provider__c = ProviderList[1].id, Opportunity__c = OppList[0].id,Provider_Facility__c  = PFList[1].id,Facility__c = FacilityList[1].id,Delivering_Provider__c = true));
       OPList.add(new Opportunity_Provider__c(Provider__c = ProviderList[2].id, Opportunity__c = OppList[0].id,Provider_Facility__c  = PFList[2].id,Facility__c = FacilityList[2].id,Primary_Provider__c = true));
       upsert OPList;
       Map<Id,Opportunity_Provider__c> oldMap = new Map<Id,Opportunity_Provider__c>();
       for(Opportunity_Provider__c op:OPList){
            oldMap.put(op.id,op);
        }
       
        OpportunityProviderHelper.rule(OPList,false,oldMap);
    }
    catch(Exception e){
       // system.assertEquals()
       system.debug('Error message'+e.getMessage());
    }  
    Test.stopTest();
   }
    @isTest static void multiplePrimaryProviders(){
    Test.startTest();
    try{
        List<Contact> contList = TestDataFactory.CreateAccountWithContacts();
        List<Opportunity> OppList = TestDataFactory.CreateOpportunitiesWithContactRoles();
        List<Facility__c> FacilityList = TestDataFactory.CreateFacilities();
        List<Provider__c> ProviderList = TestDataFactory.CreateProviders();
        List<Provider_Facility__c> PFList = TestDataFactory.CreateProviderFacilities(FacilityList,ProviderList);
        List<Opportunity_Provider__c> OPList = TestDataFactory.CreateOpportunityProviders(PFList,ProviderList,FacilityList,OppList);
        OPList.add(new Opportunity_Provider__c(Provider__c = ProviderList[0].id, Opportunity__c = OppList[1].id,Provider_Facility__c  = PFList[1].id,Facility__c = FacilityList[0].id,Delivering_Provider__c = true,Primary_Provider__c = true));
       OPList.add(new Opportunity_Provider__c(Provider__c = ProviderList[2].id, Opportunity__c = OppList[1].id,Provider_Facility__c  = PFList[2].id,Facility__c = FacilityList[2].id,Primary_Provider__c = true));
       upsert OPList;
       Map<Id,Opportunity_Provider__c> oldMap = new Map<Id,Opportunity_Provider__c>();
        OpportunityProviderHelper.rule(OPList,true,oldMap);
    }
    catch(Exception e){
       // system.assertEquals()
       system.debug('Error message'+e.getMessage());
    }  
    Test.stopTest();
   }
   @isTest static void ruleUpdateWithDuplicateProviderTest(){
    Test.startTest();
    try{
      List<Contact> contList = TestDataFactory.CreateAccountWithContacts();
        List<Opportunity> OppList = TestDataFactory.CreateOpportunitiesWithContactRoles();
        List<Facility__c> FacilityList = TestDataFactory.CreateFacilities();
        List<Provider__c> ProviderList = TestDataFactory.CreateProviders();
        List<Provider_Facility__c> PFList = TestDataFactory.CreateProviderFacilities(FacilityList,ProviderList);
        List<Opportunity_Provider__c> OPList = TestDataFactory.CreateOpportunityProviders(PFList,ProviderList,FacilityList,OppList);
        OPList[1].Provider__c = ProviderList[1].id;
        update OPList;
        Map<Id,Opportunity_Provider__c> oldMap = new Map<Id,Opportunity_Provider__c>();
       for(Opportunity_Provider__c op:OPList){
            oldMap.put(op.id,op);
        }
       
        OpportunityProviderHelper.rule(OPList,false,oldMap);
    }
      catch(Exception e){
        system.debug('Exception message'+e.getMessage());
      }
        Test.stopTest();
      
      }
    @isTest static void multiplePrimaryProvidersOnUpdate(){
    Test.startTest();
    try{
        List<Contact> contList = TestDataFactory.CreateAccountWithContacts();
        List<Opportunity> OppList = TestDataFactory.CreateOpportunitiesWithContactRoles();
        List<Facility__c> FacilityList = TestDataFactory.CreateFacilities();
        List<Provider__c> ProviderList = TestDataFactory.CreateProviders();
        List<Provider_Facility__c> PFList = TestDataFactory.CreateProviderFacilities(FacilityList,ProviderList);
        List<Opportunity_Provider__c> OPList = TestDataFactory.CreateOpportunityProviders(PFList,ProviderList,FacilityList,OppList);
        OPList[0].Primary_Provider__c = true;

       upsert OPList;
       Map<Id,Opportunity_Provider__c> oldMap = new Map<Id,Opportunity_Provider__c>();
       for(Opportunity_Provider__c op:OPList){
            oldMap.put(op.id,op);
        }
        OpportunityProviderHelper.rule(OPList,false,oldMap);
    }
    catch(Exception e){
       // system.assertEquals()
       system.debug('Error message'+e.getMessage());
    }  
    Test.stopTest();
   }
   @isTest static void multipleDeliveringProviders(){
    Test.startTest();
    try{
        List<Contact> contList = TestDataFactory.CreateAccountWithContacts();
        List<Opportunity> OppList = TestDataFactory.CreateOpportunitiesWithContactRoles();
        List<Facility__c> FacilityList = TestDataFactory.CreateFacilities();
        List<Provider__c> ProviderList = TestDataFactory.CreateProviders();
        List<Provider_Facility__c> PFList = TestDataFactory.CreateProviderFacilities(FacilityList,ProviderList);
        List<Opportunity_Provider__c> OPList = TestDataFactory.CreateOpportunityProviders(PFList,ProviderList,FacilityList,OppList);
        OPList.add(new Opportunity_Provider__c(Provider__c = ProviderList[0].id, Opportunity__c = OppList[1].id,Provider_Facility__c  = PFList[1].id,Facility__c = FacilityList[0].id,Delivering_Provider__c = true));
        OPList[0].Delivering_Provider__c = true;
       OPList.add(new Opportunity_Provider__c(Provider__c = ProviderList[2].id, Opportunity__c = OppList[1].id,Provider_Facility__c  = PFList[2].id,Facility__c = FacilityList[2].id,Delivering_Provider__c = true));
       upsert OPList;
       Map<Id,Opportunity_Provider__c> oldMap = new Map<Id,Opportunity_Provider__c>();
        for(Opportunity_Provider__c op:OPList){
            oldMap.put(op.id,op);
        }
        OpportunityProviderHelper.rule(OPList,false,oldMap);
    }
    catch(Exception e){
       // system.assertEquals()
       system.debug('Error message'+e.getMessage());
    }  
    Test.stopTest();
   }
   @isTest static void UpdateOpportunityPickUpOrShipKitFieldTest(){
        Test.StartTest();
        List<Contact> contList = TestDataFactory.CreateAccountWithContacts();
        List<Opportunity> OppList = TestDataFactory.CreateOpportunitiesWithContactRoles();
        List<Facility__c> FacilityList = TestDataFactory.CreateFacilities();
        List<Provider__c> ProviderList = TestDataFactory.CreateProviders();
        List<Provider_Facility__c> PFList = TestDataFactory.CreateProviderFacilities(FacilityList,ProviderList);
        List<Opportunity_Provider__c> OPList = TestDataFactory.CreateOpportunityProviders(PFList,ProviderList,FacilityList,OppList);
        Map<id,Opportunity_Provider__c> NewMap = new Map<Id,Opportunity_Provider__c>();
        for(Opportunity_Provider__c op:OPList){
            NewMap.put(op.id,op);
        }
        OpportunityProviderHelper.UpdateOpportunityPickUpOrShipKitField(NewMap);
        List<Opportunity> OppList1 = [Select id,PickUp_or_Ship_Kit__c  from Opportunity Where PickUp_or_Ship_Kit__c  = 'PickUp'];
        system.assertEquals(1,OppList1.size());
        Test.stopTest();
    }
}
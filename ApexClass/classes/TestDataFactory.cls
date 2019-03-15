@isTest
public class TestDataFactory {
    //This method creates contact with Account
    public static List<Contact> CreateAccountWithContacts(){
        List<Contact> ContactList = new List<Contact>();
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        ContactList.add(new Contact(AccountId = acc.id,FirstName = 'Jhon', LastName = 'JhonTest',Birthdate = System.today().addDays(-2),Phone='1232431234',ID_Type__c = 'Passport #',ID_Information__c = '54546565655',Email = 'test111@test.com',MailingCountry = 'United States',MailingState = 'Texas',MailingCity = 'Texas',MailingPostalCode='73301',MailingStreet = 'Testmst'));
        ContactList.add(new Contact(AccountId = acc.id,FirstName = 'Joy', LastName = 'JoyTest',Birthdate = System.today().addDays(-6),Phone = '8900988900',ID_Type__c = 'Passport #',ID_Information__c = '23475676878',Email = 'test222@test.com',MailingCountry = 'United States',MailingState = 'Texas',MailingCity = 'Texas',MailingPostalCode='73301',MailingStreet = 'mstmst',OtherCountry ='United States',OtherState = 'New York',OtherCity = 'New Jersey',OtherPostalCode='08823',OtherStreet = 'TestAddress' ));
        ContactList.add(new Contact(AccountId = acc.id,FirstName = 'Jack', LastName = 'JackTest',Birthdate = System.today().addDays(-7),Phone = '6786786776',ID_Type__c = 'Passport #',ID_Information__c = '4557609989',Email = 'test333@test.com',MailingCountry = 'United States',MailingState = 'New York',MailingCity = 'New Jersey',MailingPostalCode='08823',MailingStreet = 'Test'));
        insert ContactList;
        return ContactList;
    }
    //Below method creates and returns opportunity List
    public static List<Opportunity> CreateOpportunitiesWithContactRoles(){
        List<Opportunity> OpportunityList = new List<Opportunity>();
        OpportunityList.add(new Opportunity(name = 'Test1',of_Babies__c = 'Single',
                                    StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',
                                    closeDate = system.today(),status__C = 'Open',Due_Date__c = system.today().addDays(42),
                                    Ship_To_Street1__c = 'Texas mst',Ship_To_City__c = 'Texas',Ship_To_State__c = 'Texas',
                                    Ship_To_Zip_Code__c = '73301',Ship_To_Phone__c = '9900990099',
                                    Requested_Shipping_Date__c = system.today(),Ship_To_Name__c = 'testName',Description = 'Opportunity1'));
        OpportunityList.add(new Opportunity(name = 'Test2',of_Babies__c = 'Single',
                                    StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',
                                    closeDate = system.today(),status__C = 'Open',Due_Date__c = system.today().addDays(40),
                                    Ship_To_Street1__c = 'Texas mst',Ship_To_City__c = 'Texas',Ship_To_State__c = 'Texas',
                                    Ship_To_Zip_Code__c = '73301',Ship_To_Phone__c = '9900990099',
                                    Requested_Shipping_Date__c = system.today(),Ship_To_Name__c = 'testName',Description = 'Opportunity2'));
        OpportunityList.add(new Opportunity(name = 'Test3',of_Babies__c = 'Single',
                                    StageName = 'Ask for sale (7)',PickUp_or_Ship_Kit__c = 'Ship',
                                    closeDate = system.today(),status__C = 'Open',Due_Date__c = system.today().addDays(35),
                                    Ship_To_Street1__c = 'Texas mst',Ship_To_City__c = 'Texas',Ship_To_State__c = 'Texas',
                                    Ship_To_Zip_Code__c = '73301',Ship_To_Phone__c = '9900990099',
                                    Requested_Shipping_Date__c = system.today(),Ship_To_Name__c = 'testName',Description = 'Opportunity3'));
        insert OpportunityList;
        return OpportunityList;
    }
    //Method create and return OpportunityContactRole list for input opportunityList
    public static List<OpportunityContactRole> CreateOpportunityContactRoles(List<Contact> ContList,List<Opportunity> OppList){
        List<OpportunityContactRole> OCRList = new List<OpportunityContactRole>();
        OCRList.add(new OpportunityContactRole(OpportunityId = OppList[0].id,ContactId = ContList[0].id,Role = 'Mother',isPrimary = true));
        OCRList.add(new OpportunityContactRole(OpportunityId = OppList[1].id,ContactId = ContList[1].id,Role = 'Father',isPrimary = true));
        OCRList.add(new OpportunityContactRole(OpportunityId = OppList[2].id,ContactId = ContList[2].id,Role = 'Mother',isPrimary = true));
        insert OCRList;
        return OCRList;
    }
    //Create and return Facility records
    public static List<Facility__c> CreateFacilities(){
        List<Facility__c> FacilityList = new List<Facility__c>();
        FacilityList.add(new Facility__c(Master_Facility_Id__c = 'MasterFacility1'));
        FacilityList.add(new Facility__c(Master_Facility_Id__c = 'MasterFacility2'));
        FacilityList.add(new Facility__c(Master_Facility_Id__c = 'MasterFacility3'));
        insert FacilityList;
        return FacilityList;
    }
    //Create and return Provider records
    public static List<Provider__c> CreateProviders(){
        List<Provider__c> ProviderList = new List<Provider__c>();
        ProviderList.add(new Provider__c(Master_Provider_Id__c = 'MasterProvider1'));
        ProviderList.add(new Provider__c(Master_Provider_Id__c = 'MasterProvider2'));
        ProviderList.add(new Provider__c(Master_Provider_Id__c = 'MasterProvider3'));
        insert ProviderList;
        return ProviderList;
    }
    //Create and return Provider facility reords.
    public static List<Provider_Facility__c> CreateProviderFacilities(List<Facility__c> FacilityList,List<Provider__c> ProviderList){
        List<Provider_Facility__c> ProviderFacilityList = new List<Provider_Facility__c>();
        ProviderFacilityList.add(new Provider_Facility__c(Master_Provider_Facility_ID__c='MasterPF1',Facility__c = FacilityList[0].id,Provider__c = ProviderList[0].id));
        ProviderFacilityList.add(new Provider_Facility__c(Master_Provider_Facility_ID__c='MasterPF2',Facility__c = FacilityList[1].id,Provider__c = ProviderList[1].id,Ship_Kit__c = 'Always Ship Kit'));
        ProviderFacilityList.add(new Provider_Facility__c(Master_Provider_Facility_ID__c='MasterPF3',Facility__c = FacilityList[2].id,Provider__c = ProviderList[2].id,Ship_Kit__c = 'Never Ship Kit'));
        insert ProviderFacilityList;
        return ProviderFacilityList;
    }
    //Create and return OpportuntiyProviders
    public static List<Opportunity_Provider__c> CreateOpportunityProviders(List<Provider_Facility__c> ProviderFacilityList,List<Provider__c> ProviderList,List<Facility__c> FacilityList,List<Opportunity> OpportunityList){
        List<Opportunity_Provider__c> OpportunityProviderList = new List<Opportunity_Provider__c>();
        OpportunityProviderList.add(new Opportunity_Provider__c(Provider__c = ProviderList[0].id, Opportunity__c = OpportunityList[0].id,Provider_Facility__c  = ProviderFacilityList[0].id,Facility__c = FacilityList[0].id));
        OpportunityProviderList.add(new Opportunity_Provider__c(Provider__c = ProviderList[1].id, Opportunity__c = OpportunityList[0].id,Provider_Facility__c  = ProviderFacilityList[1].id,Facility__c = FacilityList[1].id,Primary_Provider__c =true,Delivering_Provider__c = true));
        OpportunityProviderList.add(new Opportunity_Provider__c(Provider__c = ProviderList[1].id, Opportunity__c = OpportunityList[1].id,Provider_Facility__c  = ProviderFacilityList[1].id,Facility__c = FacilityList[1].id,Primary_Provider__c = true));
        OpportunityProviderList.add(new Opportunity_Provider__c(Provider__c = ProviderList[2].id, Opportunity__c = OpportunityList[2].id,Provider_Facility__c  = ProviderFacilityList[2].id,Facility__c = FacilityList[2].id,Primary_Provider__c = true));
        insert OpportunityProviderList;
        return OpportunityProviderList;
    }
    public static void CustomSettingRecords(){
        List<US_Zipcode__c> zipCodeList = new List<US_Zipcode__c>();
        zipCodeList.add(new US_Zipcode__c(City__c = 'New York',Country__c = 'US',Name = '10001'));
        zipCodeList.add(new US_Zipcode__c(City__c = 'New York',Country__c = 'US',Name = '94066'));
        insert zipCodeList;
       
    }
}
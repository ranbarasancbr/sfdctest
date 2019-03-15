/*******************************************************************************************************************************
Component Name:onlineEnrollmentHelper
Description:This class contains helper methods to get values
Created By:Teksystems
********************************************************************************************************************************/
public class onlineEnrollmentCreateupdateHelper{

//Method to return map of online enrollements with all fields
public static map<id,Online_Enrollment__c> getOnlineEnrollMap(Set<id> OEids){
      map<id,Online_Enrollment__c> onlineEmap = new map<id,Online_Enrollment__c>();
         if(OEids!=null && !OEids.isEmpty()){
             onlineEmap = new Map<Id,Online_Enrollment__c>([SELECT Id,Secondary_Contact_SCSS_Id__c,Secondary_Contact__c,Repeat_Client__c,Primary_Contact_SCSS_Id__c,Ship_Kit_Flag__c,Campaign_ID__c,Opportunity_Id__c,Primary_Contact_Id__c,Campaign_ID_2__c,Source_Code__c,Completed_Flag__c,Ship_to_first_name__c,Ship_to_Last_Name__c,How_Did_You_Hear__c,Ship_To_Street_Address__c,Primary_Country__c,Primary_ID_Type__c, Name,Cardholder_Name__c, Due_Date__c, Online_Enrollment_External_Id__c, Primary_Email__c, Primary_First_Name__c, Primary_Last_Name__c, Primary_Role__c, Secondary_First_Name__c, Secondary_Last_Name__c, Secondary_Role__c, of_Babies__c, of_CB__c, of_CT__c, Primary_Home_Phone__c, Primary_Mobile_Phone__c,Adoption_Type__c, Provider_First_Name__c, Provider_Last_Name__c, Provider_City__c, Provider_State__c, Provider_Zip__c, Provider_Country__c, Provider_Phone__c, Provider_ID__c, Provider_Address__c, Hospital_Name__c, Hospital_Address__c, Hospital_City__c, Hospital_State__c, Hospital_Zip_Code__c, Hospital_Country__c,PrimaryID__c,Primary_City__c,Primary_State__c,Primary_Zipcode__c,Primary_Address__c, Hospital_Id__c, Referrer_Name__c,Credit_Card_Type__c, Provider_Facility_ID__c,Payment_Plan__c, Primary_Address_2__c ,Ship_To_Addr_2__c,Birth_Date_of_Primary__c,Last_4_Digits__c,CB_Storage_Fee_Option__c, CT_Storage_Fee_Option__c, Promo_Code__c,Ship_To_City__c,Ship_To_Country__c,Ship_To_State__c,Ship_To_Zip_Code__c,Credit_Card_Profile_ID__c,Expiration_Year__c,CC_Expiration_Month__c,Auto_Enroll__c FROM Online_Enrollment__c Where id IN:OEids]);
         }
         return onlineEmap;
}

//Method to return map of sfdc facility id and master facility id
public static Map<String,String> getFacilityrecords(Set<String> facilityids){
    Map<id,Facility__c> facilityMap = new Map<id,Facility__c>();
    Map<String,String> FacilityIdMap = new Map<String,String>();//Key is master facility id with sfdc facility id as value
    if(facilityids!=null && !facilityids.isEmpty()){
        facilityMap = new map<id,Facility__c>([select id,Master_Facility_Id__c from Facility__c where Master_Facility_Id__c IN:facilityids]);
    }
     if(facilityMap!=null && !facilityMap.isEmpty()){
            for(Facility__c f:facilityMap.values()){
                if(String.isNotBlank(f.Master_Facility_Id__c)){
                    FacilityIdMap.put(f.Master_Facility_Id__c,f.id);
                    system.debug('FacilityIdMap'+FacilityIdMap);
                }
            }
        }
    return FacilityIdMap;
}

//Method to return map of master provider id and sfdc provider id
public static map<String,String> getProviderrecords(Set<String> providerids){
     Map<id,Provider__c> prviderMap = new Map<Id,Provider__c>();//Map to store providers of online enrollments
       Map<String,String> MasterIdProviderIdMap = new Map<String,String>();//Map to store master provider as key and sfdc provider id as value
       if(providerids!=null && !providerids.isEmpty()){
           prviderMap = new Map<id,Provider__c>([Select id,Master_Provider_Id__c,Opportunity_Provider__c,Provider_First_Name__c,Provider_Last_Name__c from Provider__c where Master_Provider_Id__c IN:providerids]);
       }
       if(prviderMap!=null && !prviderMap.isEmpty()){
           for(Provider__c p:prviderMap.values()){
               if(String.isNotBlank(p.Master_Provider_Id__c)){
                   MasterIdProviderIdMap.put(p.Master_Provider_Id__c,p.id);
               }
           }
       }
       return MasterIdProviderIdMap;
}
//Method to return map of provider facility sfdc and master ids 
public static Map<string,Provider_Facility__c> getproviderfacilityids(Set<string> masterids){
     Map<id,Provider_Facility__c> provderFacilityMap = new Map<id,Provider_Facility__c>();
       Map<String,Provider_Facility__c> MasterPFSfdcMap = new map<String,Provider_Facility__c>();//Master provider facility as key and sfdc provider faclity as value
       if(masterids!=null && !masterids.isEmpty()){
           provderFacilityMap = new Map<Id,Provider_Facility__c>([Select id,Master_Facility_Id__c,Master_Provider_Facility_ID__c,Master_Provider_Id__c,Opportunity__c,Provider__c,Facility__c from Provider_Facility__c where Master_Provider_Facility_ID__c IN:masterids]);
       }
       if(provderFacilityMap!= null && !provderFacilityMap.isEmpty()){
           for(Provider_Facility__c pf:provderFacilityMap.values()){
               MasterPFSfdcMap.put(pf.Master_Provider_Facility_ID__c,pf);
           }
       }
       return MasterPFSfdcMap;
}
//Validations check for completed flag true Opportunities to set stage to Won
    public static void checkOLEOppValidations(Map<id,opportunity> OppMap,Map<id,Online_Enrollment__c> OLEMap){
        List<Opportunity> OppToUpdateList = new List<Opportunity>();
        List<opportunity> finalListOpp = new List<Opportunity>();
        Map<id,Opportunity> oppMapToValidate = new Map<id,Opportunity>();
        List<Online_Enrollment__c> FinalOLEToUpdate = new List<Online_Enrollment__c>();
        Set<id> OLEIds = new Set<id>();
        system.debug('OppMap'+OppMap);
        //Query on opportunity to get all fields of opportunity which are need to be validated
        if(OppMap!=null && !OppMap.isEmpty()){
            oppMapToValidate = new Map<id,Opportunity>([Select id,StageName,Online_Enroll_Status__c, Completed_Flag__c, Delivering_Hospital__c, Primary_Source__c,LeadSource, PickUp_or_Ship_Kit__c, Shipping_Method__c, Ship_To_Name__c, Ship_To_Street1__c, Ship_To_Phone__c, Requested_Shipping_Date__c, Primary_Contact__c,Primary_Contact__r.MailingCountry, Primary_Contact__r.ID_Type__c,Online_Enrollment__c,Ship_To_City__c,Ship_To_State__c,Ship_To_Zip_Code__c from Opportunity where Id IN:OppMap.keyset()]);
        }
        system.debug('oppMapToValidate'+oppMapToValidate);
        //If above list is not empty validate opportunities
        if(oppMapToValidate!=null && !oppMapToValidate.isEmpty()){
            for(Opportunity opp:oppMapToValidate.values()){
                system.debug('Ship_To_Street1__c'+opp.Ship_To_Street1__c);
                system.debug('opp.Delivering_Hospital__c===='+opp.Delivering_Hospital__c);
                system.debug('opp.Primary_Source__c===='+opp.Primary_Source__c);
                system.debug('opp.LeadSource===='+opp.LeadSource);
                system.debug('opp.PickUp_or_Ship_Kit__c===='+opp.PickUp_or_Ship_Kit__c);
                system.debug('opp.Shipping_Method__c===='+opp.Shipping_Method__c);
                
                system.debug('opp.Ship_To_Name__c===='+opp.Ship_To_Name__c);
                system.debug('opp.Ship_To_Phone__c===='+opp.Ship_To_Phone__c);
                system.debug('opp.Requested_Shipping_Date__c-------------- '+opp.Requested_Shipping_Date__c);
                system.debug('opp.Ship_To_City__c===='+opp.Ship_To_City__c);
                system.debug('opp.Ship_To_State__c===='+opp.Ship_To_State__c);
                system.debug('opp.Ship_To_Zip_Code__c-------------- '+opp.Ship_To_Zip_Code__c);
                if(String.isNotBlank(opp.Delivering_Hospital__c) && String.isNotBlank(opp.Primary_Source__c) && String.isNotBlank(opp.LeadSource) && String.isNotBlank(opp.PickUp_or_Ship_Kit__c) && 
                        ((opp.PickUp_or_Ship_Kit__c.equals('Ship') && String.isNotBlank(opp.Shipping_Method__c) && String.isNotBlank(opp.Ship_To_Name__c) && String.isNotBlank(opp.Ship_To_Street1__c) && String.isNotBlank(opp.Ship_To_City__c) && String.isNotBlank(opp.Ship_To_State__c) && String.isNotBlank(opp.Ship_To_Zip_Code__c)&& opp.Ship_To_Phone__c!=null && opp.Requested_Shipping_Date__c != null) || opp.PickUp_or_Ship_Kit__c.equals('PickUp')) ){
                            system.debug('true to update');
                            opp.StageName = 'Won (9)';
                            opp.Online_Enroll_Status__c = 'Auto Enrolled';
                            OppToUpdateList.add(opp);//add Opp to list 
                            OLEIds.add(opp.Online_Enrollment__c);
                }
            }
        }
        List<Database.SaveResult> oppUpdateSaveResults = new List<Database.SaveResult>();
        List<String> OppUpdateerrors = new list<String>();
        if(OppToUpdateList!=null && OppToUpdateList.size()>0){
             oppUpdateSaveResults = Database.update(OppToUpdateList,false);//Update List OppToUpdateList
        }
        
        for (Database.SaveResult saveResult : oppUpdateSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()){
                    OppUpdateerrors.add(e.getMessage());
                }
            }
            
        }
        system.debug('upadteee'+OppUpdateerrors);
        system.debug('Opportunity ContactRoles final recods'+OppToUpdateList);
        system.debug('OppToUpdateList size'+OppToUpdateList.size()); 
        system.debug('OLEIds'+OLEIds);
        system.debug('OLEMap'+OLEMap);
        Map<string,Opportunity> OLEOppMap = new Map<String,Opportunity>();
        Map<Id,Online_Enrollment__c> OLEsToUpdateMap = new Map<Id,Online_Enrollment__c>();
        //Add Opp to map OLEOppMap this map is used to check opportunity's online enroll status
        if(OppToUpdateList!=null && !OppToUpdateList.isEmpty()){
            for(Opportunity opp:OppToUpdateList){
                OLEOppMap.put(opp.Online_Enrollment__c,opp);
            }
        }
        //Query on Online enrollment object to get fields which need to be upated Auto_Enroll__c field is updated when Ole's relaetd opportunity.Online_Enroll_Status__c = 'Auto enrolled'
        if(OLEIds!=null && !OLEIds.isEmpty() && OLEMap!=null && !OLEMap.isEmpty()){
            system.debug('inside null check');
            OLEsToUpdateMap = new Map<Id,Online_Enrollment__c>([select id,Auto_Enroll__c,Opportunity_Id__c from Online_Enrollment__c where Id IN:OLEMap.keyset()]);
        }
        if(OLEsToUpdateMap!=null && !OLEsToUpdateMap.isEmpty()){
            for(Online_Enrollment__c oe:OLEsToUpdateMap.values()){
                system.debug('inside for loop');
                system.debug('oe.Opportunity_Id__c---------'+oe.Opportunity_Id__c);
                //Check if OLE's opp.Online enroll.status = Auto Enrolled. If true set OLE's Auto_Enroll__c =true
                if(OLEIds.contains(oe.id) && !OLEOppMap.isEmpty() && OLEOppMap.containsKey(oe.id) && OLEOppMap.get(oe.id).Online_Enroll_Status__c == 'Auto Enrolled'){
                    system.debug('oe.Opportunity_Id__c'+oe.Opportunity_Id__c);
                    system.debug('true setting');
                    oe.Auto_Enroll__c = true;
                    FinalOLEToUpdate.add(oe);
                }
            }
        }
        List<Database.SaveResult> OLEUpdateSaveResults = new List<Database.SaveResult>();
        List<String> OLEErrors = new list<String>();
        //Update OLE
        if(FinalOLEToUpdate!=null && !FinalOLEToUpdate.isEmpty()){
            OLEUpdateSaveResults = Database.update(FinalOLEToUpdate,false);
        }
        for (Database.SaveResult saveResult : OLEUpdateSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()){
                    OLEErrors.add(e.getMessage());
                }
            }
        }
        system.debug('OLEErrors'+OLEErrors);
        system.debug('FinalOLEToUpdate final recods'+FinalOLEToUpdate);
        system.debug('FinalOLEToUpdate size'+FinalOLEToUpdate.size()); 
    }
}
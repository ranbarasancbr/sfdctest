/****************************************************************************************************************************************************
Component Name: UpdateSobjectOfOnlineEnroll
Description   : To update online enrollment related SOBjects (Contact, opportunity, contact payment profile)
Developed By  : TEK Systems
User Stories  : 45, 469, 470, 471.
*****************************************************************************************************************************************************/
public class UpdateSobjectOfOnlineEnroll{
    //Method to update all related records of online enrollment
    public static void updateAllRecords(Map<id,Online_Enrollment__c> newOEMap, Map<id,Online_Enrollment__c> OldOEMap){
        Map<String,opportunity> OppUpdateFieldsMap = new Map<String,Opportunity>();//If opp realted fields on OLE updated then we add that OLE id as key and its opportunity as value to this map 
        Map<String,opportunity> SecondaryContactFieldsMap = new Map<String,Opportunity>();//If secondary contact details are provided on updata of OLE then we add that OLE id as key and its opportunity as value to this map 
        map<String,Opportunity> oppProviderFacilityMapCreate = new Map<String,Opportunity>();//If new Opportunity Provider is to be created for an opportunity then we add that OLE id as key and its opportunity as value to this map 
        map<String,Opportunity> oppProviderFacilityMapupdate = new Map<String,Opportunity>();
        Set<String> CampaignCodeSet = new Set<String>();//This set holds Source Code and Promo code values of online enrollment
        Map<id,Opportunity> OppOeMapForCampagin = new Map<Id,Opportunity>();
        Set<id> CCPOeIds = new Set<id>();
        set<id> ContactOes = new set<id>();
        Map<id,Opportunity> opptoupdate = new Map<id,opportunity>();
        Set<id> OEids = new Set<id>();
        Set<String> facilityChangedOEs = new Set<String>();//This set holds all online enrollment ids whose facility is updated
        Set<String> ProviderChangedOEs = new Set<String>();//This Set holds all provider ids on online enrollment
        Set<String> ProviderFacilityOEs = new Set<String>();//This Set holds all provider facility ids on online enrollment
        Set<String> SecondaryConSCSSid = new Set<String>();//This set holds secondary contact SCSS id which is used to updated OLE's secondary contact field and to create Opportunity Contact Role.
        Set<String> SecSCSSId = new Set<String>();
        Map<String,Opportunity> SecondaryOCROppCreateMap = new Map<String,Opportunity>();//This Map holds key as online Enrollment Id and value as its opportunity.
        Map<String,String> SecondarySCSSIdOLEIdMap = new Map<String,String>();//This map holds Seconadry contact SCSS id as key and OLE id as value
        Map<id,Online_Enrollment__c> OLESecondaryConUpdate = new Map<id,Online_Enrollment__c>();//This Map holds OLEs that needs to update with secondary contact Id when Secondary contact SCSS id is provided on OLE
        if(newOEMap!=null && !newOEMap.isEmpty()){
            for(Online_Enrollment__c oe:newOEMap.values()){
                if(String.isNotBlank(OldOEMap.get(oe.id).Opportunity_Id__c) && String.isNotBlank(oe.Opportunity_Id__c)){
                     OEids.add(oe.id);   
                    //Add hospital Id(if field value is not null) value on facilityChangedOEs
                    if(String.isNotBlank(oe.Hospital_Id__c)){
                        facilityChangedOEs.add(oe.Hospital_Id__c);
                    }
                   //Add Provider Id(if field value is not null) value on ProviderChangedOEs
                    if(String.isNotBlank(oe.Provider_ID__c)){
                        ProviderChangedOEs.add(oe.Provider_ID__c);
                    }
                     //Add Provider facility Id(if field value is not null) value on ProviderFacilityOEs
                    if(string.isNotBlank(oe.Provider_Facility_ID__c)){
                        ProviderFacilityOEs.add(oe.Provider_Facility_ID__c);
                    }
                }
               
            }
        }
        if( OEids!=null && !OEids.isEmpty()){
            System.debug('===========Opp Error' +OEids.size());
            //Query on opportunities whose OLE ids are in set -OEids. Only if opportunity's status is Open then only opportunity and its related child object's records are updated.
            opptoupdate =new Map<id,Opportunity>([select id,AccountId,Online_Enrollment__c,of_Babies__c,of_CB__c,of_CT__c,Adoption_Type__c,CB_Storage_Fee_Option__c,CT_Storage_Fee_Option__c,Due_Date__c,Promo_Code__c,Ship_To_Street2__c,Ship_To_Street1__c,Ship_To_City__c,Ship_To_Country__c,Ship_To_State__c,Ship_To_Zip_Code__c,Payment_Plan__c,Ship_To_Name__c,Completed_Flag__c,Delivering_Hospital__c,Primary_Source__c,Online_Enroll_Status__c,Section_1_Received__c,Section_4_Received__c,StageName,Referral_Name__c  from Opportunity Where Online_Enrollment__c IN:OEids AND Status__c = 'Open']);
        }
        system.debug('opptoupdate..............'+opptoupdate);
         //Start Get facility sfdc ids and provider ids 
        Map<String,String> MasterIdProviderIdMap = new Map<String,String>();//Map holds master provider as key and sfdc provider id as value
        Map<String,String> MasterIdFacilityIdMap = new Map<String,String>(); //Map holds facility master id of online enrollment as key and facility id as value to update opportunity
        map<String,Provider_Facility__c> MasteridPFSfdcIdmap = new Map<String,Provider_Facility__c>();//map contains master id of provider facility and sfdc id
        if(facilityChangedOEs!=null && !facilityChangedOEs.isEmpty()){
            MasterIdFacilityIdMap = onlineEnrollmentCreateupdateHelper.getFacilityrecords(facilityChangedOEs);
        }
        if(ProviderChangedOEs!=null && !ProviderChangedOEs.isEmpty()){
            MasterIdProviderIdMap = onlineEnrollmentCreateupdateHelper.getProviderrecords(ProviderChangedOEs);
        }
        if(ProviderFacilityOEs!=null && !ProviderFacilityOEs.isEmpty()){
            MasteridPFSfdcIdmap = onlineEnrollmentCreateupdateHelper.getproviderfacilityids(ProviderFacilityOEs);
        }
        system.debug('getAggregateQueries'+Limits.getAggregateQueries());
        //End get facility sfdcids and provider ids
        //Start Spliting of opportunities to update into different maps by checking which fields on online enrollment are updated
        Set<id> oppidsForOppProvider = new Set<Id>();
        Set<id> OEoppIds = new Set<id>();
        if(opptoupdate!=null && !opptoupdate.isEmpty()){
            for(opportunity opp:opptoupdate.values()){
                Online_Enrollment__c newoe = newOEMap.get(opp.Online_Enrollment__c);
                system.debug('newoe'+newoe);
                Online_Enrollment__c oldoe = OldOEMap.get(opp.Online_Enrollment__c);
                system.debug('oldoe'+oldoe);
                //Check if any fields on OLE are updated which are realted to opportunity
                if(newoe.of_Babies__c!=oldoe.of_Babies__c || newoe.of_CB__c != oldoe.of_CB__c || newoe.of_CT__c!=oldoe.of_CT__c || newoe.Adoption_Type__c!=oldoe.Adoption_Type__c || newoe.CB_Storage_Fee_Option__c!=oldoe.CB_Storage_Fee_Option__c || newoe.CT_Storage_Fee_Option__c!=oldoe.CT_Storage_Fee_Option__c || newoe.Due_Date__c!=oldoe.Due_Date__c || newoe.Promo_Code__c!=oldoe.Promo_Code__c || newoe.Ship_To_Addr_2__c!=oldoe.Ship_To_Addr_2__c || newoe.Ship_To_City__c!= oldoe.Ship_To_City__c || newoe.Ship_To_Country__c!=oldoe.Ship_To_Country__c || newoe.Ship_To_State__c!=oldoe.Ship_To_State__c || newoe.Ship_To_Zip_Code__c!=oldoe.Ship_To_Zip_Code__c || newoe.Completed_Flag__c!=oldoe.Completed_Flag__c || newoe.Payment_Plan__c!=oldoe.Payment_Plan__c || newoe.Hospital_Id__c!=oldoe.Hospital_Id__c || newoe.Ship_to_first_name__c != oldoe.Ship_to_first_name__c || newoe.Ship_to_Last_Name__c != oldoe.Ship_to_Last_Name__c || oldoe.Referrer_Name__c != newoe.Referrer_Name__c || newoe.How_Did_You_Hear__c != oldoe.How_Did_You_Hear__c || newoe.Ship_To_Street_Address__c != oldoe.Ship_To_Street_Address__c){
                    system.debug('completed flag check');
                    OppUpdateFieldsMap.put(opp.Online_Enrollment__c,opp);
                }
                // check If any fields related to Secondary contact are updated.
                if(String.isBlank(oldoe.Secondary_First_Name__c) && String.isBlank(oldoe.Secondary_Last_Name__c) && String.isBlank(oldoe.Secondary_Role__c) && (String.isNotBlank(newoe.Secondary_First_Name__c) || String.isNotBlank(newoe.Secondary_Last_Name__c) ||String.isNotBlank(newoe.Secondary_Role__c)) && String.isBlank(newoe.Secondary_Contact_SCSS_Id__c)){
                    system.debug('update secoondary contatc');
                    SecondaryContactFieldsMap.put(opp.Online_Enrollment__c,opp);
                }
                //If Secondary Contact SCSS id is updated on OLE then query on contact and update OLE's Secondary contact Id field and create OpportunityContactRole with secondary contact id
                if(String.isNotBlank(newoe.Secondary_Contact_SCSS_Id__c) && String.isBlank(oldoe.Secondary_Contact_SCSS_Id__c)){
                    system.debug('Seondary SCSS Id'+newoe.Secondary_Contact_SCSS_Id__c);
                    SecSCSSId.add(newoe.Secondary_Contact_SCSS_Id__c);
                    SecondaryOCROppCreateMap.put(opp.Online_Enrollment__c,opp);
                    SecondarySCSSIdOLEIdMap.put(newoe.Secondary_Contact_SCSS_Id__c,newoe.id);
                    OLESecondaryConUpdate.put(newoe.id,newoe);
                }
                // check If any fields related to opportunity provider and delivering hospital id are updated
                if(oldoe.Provider_Facility_ID__c != newoe.Provider_Facility_ID__c || oldoe.Provider_ID__c!=newoe.Provider_ID__c || oldoe.Hospital_Id__c != newoe.Hospital_Id__c){
                    system.debug('inside provider change and provider facility');
                    oppProviderFacilityMapCreate.put(opp.Online_Enrollment__c,opp);
                    oppidsForOppProvider.add(opp.id);
                }
                //Check if contact payment profile related fields are updated
                if(oldoe.Cardholder_Name__c != newoe.Cardholder_Name__c || oldoe.Expiration_Year__c != newoe.Expiration_Year__c || oldoe.CC_Expiration_Month__c != newoe.CC_Expiration_Month__c || oldoe.Credit_Card_Profile_ID__c != newoe.Credit_Card_Profile_ID__c || oldoe.Credit_Card_Type__c != newoe.Credit_Card_Type__c || oldoe.Last_4_Digits__c != newoe.Last_4_Digits__c){
                    system.debug('Update Cppp');
                    CCPOeIds.add(newoe.id);
                }
                //Check id contacts related fields are updated.
                if(oldoe.Primary_Address__c != newoe.Primary_Address__c || oldoe.Primary_Address_2__c != newoe.Primary_Address_2__c || oldoe.Primary_City__c != newoe.Primary_City__c || oldoe.Primary_Country__c != newoe.Primary_Country__c ||  oldoe.Primary_Home_Phone__c != newoe.Primary_Home_Phone__c || oldoe.Birth_Date_of_Primary__c != newoe.Birth_Date_of_Primary__c || oldoe.Primary_Zipcode__c != newoe.Primary_Zipcode__c || oldoe.Primary_State__c != newoe.Primary_State__c || oldoe.PrimaryID__c != newoe.PrimaryID__c || oldoe.Primary_ID_Type__c != newoe.Primary_ID_Type__c){
                    system.debug('contact updates');
                    ContactOes.add(newoe.Id);
                }
                //Added as part of User Stories 469, 470, 471
                if(oldoe.Source_Code__c != newoe.Source_Code__c || oldoe.Promo_Code__c != newoe.Promo_Code__c){
                    OppOeMapForCampagin.put(newoe.id,opp);
                    if(oldoe.Source_Code__c != newoe.Source_Code__c){
                        CampaignCodeSet.add(newoe.Source_Code__c);
                    }
                    if(oldoe.Promo_Code__c != newoe.Promo_Code__c){
                        CampaignCodeSet.add(newoe.Promo_Code__c);
                    }
                }
            }
        }
        system.debug('SecondaryOCROppCreateMap=========='+SecondaryOCROppCreateMap);
        system.debug('SecondaryContactFieldsMap'+SecondaryContactFieldsMap);
        system.debug(CCPOeIds);
        system.debug('oppidsForOppProvider'+oppidsForOppProvider);
        system.debug('OppUpdateFieldsMap'+OppUpdateFieldsMap);
         List<opportunity> finalupdateOpplist = new List<Opportunity>();
         //Start of opportunity Update Logic. When fields on OLE updated which reflect on Opportunity then we compare Opp fields and OLE fields and update opportunities.
        if(OppUpdateFieldsMap!=null && !OppUpdateFieldsMap.isEmpty() && !newOEMap.isEmpty() && !OldOEMap.isEmpty()){
            for(opportunity opp:OppUpdateFieldsMap.values()){
                    Online_Enrollment__c newoe = newOEMap.get(opp.Online_Enrollment__c);
                    system.debug('newoe'+newoe);
                    Online_Enrollment__c oldoe = OldOEMap.get(opp.Online_Enrollment__c);
                    system.debug('oldoe'+oldoe);
                        if(opp.of_Babies__c!=newoe.of_Babies__c){
                            if(String.isNotBlank(newoe.of_Babies__c)){opp.of_Babies__c = newoe.of_Babies__c;}
                        }
                        if(opp.Referral_Name__c!=newoe.Referrer_Name__c){
                            if(String.isNotBlank(newoe.Referrer_Name__c)){opp.Referral_Name__c = newoe.Referrer_Name__c;}
                        }
                        if(opp.of_CB__c!=newoe.of_CB__c){
                            if(String.isNotBlank(newoe.of_CB__c)){opp.of_CB__c = newoe.of_CB__c;}
                        }
                        if(opp.of_CT__c!=newoe.of_CT__c){
                           if(String.isNotBlank(newoe.of_CT__c)){ opp.of_CT__c = newoe.of_CT__c;}
                        }
                        if(opp.Adoption_Type__c!=newoe.Adoption_Type__c){
                           if(String.isNotBlank(newoe.Adoption_Type__c)) opp.Adoption_Type__c = newoe.Adoption_Type__c;
                        }
                        if(opp.CB_Storage_Fee_Option__c!=newoe.CB_Storage_Fee_Option__c){
                            if(newoe.CB_Storage_Fee_Option__c!=null){opp.CB_Storage_Fee_Option__c = newoe.CB_Storage_Fee_Option__c;}
                        }
                        if(opp.CT_Storage_Fee_Option__c!=newoe.CT_Storage_Fee_Option__c){
                            if(String.isNotBlank(newoe.CT_Storage_Fee_Option__c)){opp.CT_Storage_Fee_Option__c = newoe.CT_Storage_Fee_Option__c;}
                        }
                        if(opp.Due_Date__c!=newoe.Due_Date__c){
                            if(newoe.Due_Date__c!=null){opp.Due_Date__c = newoe.Due_Date__c;}
                        }
                        if(opp.Promo_Code__c != newoe.Promo_Code__c){
                           if(String.isNotBlank(newoe.Promo_Code__c)){opp.Promo_Code__c = newoe.Promo_Code__c;}
                        }
                        if(opp.Ship_To_Street2__c!= newoe.Ship_To_Addr_2__c){
                            if(String.isNotBlank(newoe.Ship_To_Addr_2__c)){opp.Ship_To_Street2__c= newoe.Ship_To_Addr_2__c;}
                        }
                        if(opp.Ship_To_Street1__c!= newoe.Ship_To_Street_Address__c){
                            if(String.isNotBlank(newoe.Ship_To_Street_Address__c)){opp.Ship_To_Street1__c= newoe.Ship_To_Street_Address__c;}
                        }
                        if(opp.Ship_To_City__c != newoe.Ship_To_City__c){
                            if(String.isNotBlank(newoe.Ship_To_City__c)){opp.Ship_To_City__c = newoe.Ship_To_City__c;}
                        }
                        if(opp.Ship_To_Country__c != newoe.Ship_To_Country__c){
                            if(String.isNotBlank(opp.Ship_To_Country__c)){opp.Ship_To_Country__c = newoe.Ship_To_Country__c;}
                        }
                        if(opp.Ship_To_State__c!=newoe.Ship_To_State__c){
                           if(String.isNotBlank(newoe.Ship_To_State__c)) {opp.Ship_To_State__c = newoe.Ship_To_State__c;}
                        }
                        if(opp.Ship_To_Zip_Code__c != newoe.Ship_To_Zip_Code__c){
                            if(String.isNotBlank(newoe.Ship_To_Zip_Code__c)){opp.Ship_To_Zip_Code__c = newoe.Ship_To_Zip_Code__c;}
                        }
                        //Start Completed flag changes for story CBRSFDC8-423
                        if(opp.Completed_Flag__c!=newoe.Completed_Flag__c){
                            system.debug('flag check true or false......');
                            opp.Completed_Flag__c = newoe.Completed_Flag__c;
                            if(newoe.Completed_Flag__c){
                                opp.Completed_Flag__c = newoe.Completed_Flag__c;
                                opp.Section_1_Received__c = true;
                                opp.Section_4_Received__c = true;
                                opp.Online_Enroll_Status__c = 'Complete';
                            }
                            else{
                                opp.Completed_Flag__c = newoe.Completed_Flag__c;
                                opp.StageName = 'Partial Online Enroll (8)';
                                opp.Online_Enroll_Status__c = 'Incomplete';
                            }
                        }
                        //End Completed flag changes for story CBRSFDC8-423
                        if(opp.Payment_Plan__c!=newoe.Payment_Plan__c){
                           if(String.isNotBlank(newoe.Payment_Plan__c)){ opp.Payment_Plan__c = newoe.Payment_Plan__c;}
                        }
                       
                        if(String.isNotBlank(newoe.Hospital_Id__c) && oldoe.Hospital_Id__c != newoe.Hospital_Id__c){
                            if(MasterIdFacilityIdMap!=null && !MasterIdFacilityIdMap.isEmpty() && MasterIdFacilityIdMap.containsKey(newoe.Hospital_Id__c)){
                                opp.Delivering_Hospital__c = MasterIdFacilityIdMap.get(newoe.Hospital_Id__c);
                            }
                        }
                        else if(String.isBlank(newoe.Hospital_Id__c)){
                            opp.Delivering_Hospital__c = null;
                        }
                        if(oldoe.Ship_to_first_name__c != newoe.Ship_to_first_name__c || oldoe.Ship_to_Last_Name__c != newoe.Ship_to_Last_Name__c){
                            if(oldoe.Ship_to_first_name__c != newoe.Ship_to_first_name__c && oldoe.Ship_to_Last_Name__c != newoe.Ship_to_Last_Name__c){
                                if(String.isBlank(newoe.Ship_to_first_name__c) && String.isBlank(newoe.Ship_to_Last_Name__c)){
                                    opp.Ship_To_Name__c = null;
                                }
                                else if(String.isBlank(newoe.Ship_to_first_name__c) && String.isNotBlank(newoe.Ship_to_Last_Name__c)){
                                    opp.Ship_To_Name__c = newoe.Ship_to_Last_Name__c;
                                }
                                else if(String.isNotBlank(newoe.Ship_to_first_name__c) && String.isBlank(newoe.Ship_to_Last_Name__c)){
                                    opp.Ship_To_Name__c = newoe.Ship_to_first_name__c;
                                }
                                else{
                                opp.Ship_To_Name__c = newoe.Ship_to_first_name__c +' '+newoe.Ship_to_Last_Name__c;
                                }
                            }
                            if(oldoe.Ship_to_first_name__c != newoe.Ship_to_first_name__c && oldoe.Ship_to_Last_Name__c == newoe.Ship_to_Last_Name__c){
                                if(String.isBlank(newoe.Ship_to_first_name__c) && String.isBlank(newoe.Ship_to_Last_Name__c)){
                                    opp.Ship_To_Name__c = null;
                                }
                                else if(String.isBlank(newoe.Ship_to_first_name__c) && String.isNotBlank(newoe.Ship_to_Last_Name__c)){
                                    opp.Ship_To_Name__c = newoe.Ship_to_Last_Name__c;
                                }
                                else if(String.isNotBlank(newoe.Ship_to_first_name__c) && String.isBlank(newoe.Ship_to_Last_Name__c)){
                                    opp.Ship_To_Name__c = newoe.Ship_to_first_name__c;
                                }
                                else{
                                opp.Ship_To_Name__c = newoe.Ship_to_first_name__c +' '+newoe.Ship_to_Last_Name__c;
                                }
                            }
                            if(oldoe.Ship_to_first_name__c == newoe.Ship_to_first_name__c && oldoe.Ship_to_Last_Name__c != newoe.Ship_to_Last_Name__c){
                                if(String.isBlank(newoe.Ship_to_first_name__c) && String.isBlank(newoe.Ship_to_Last_Name__c)){
                                    opp.Ship_To_Name__c = null;
                                }
                                else if(String.isBlank(newoe.Ship_to_first_name__c) && String.isNotBlank(newoe.Ship_to_Last_Name__c)){
                                    opp.Ship_To_Name__c = newoe.Ship_to_Last_Name__c;
                                }
                                else if(String.isNotBlank(newoe.Ship_to_first_name__c) && String.isBlank(newoe.Ship_to_Last_Name__c)){
                                    opp.Ship_To_Name__c = newoe.Ship_to_first_name__c;
                                }
                                else{
                                opp.Ship_To_Name__c = newoe.Ship_to_first_name__c +' '+newoe.Ship_to_Last_Name__c;
                                }
                            }
                            
                        }
                        system.debug('How_Did_You_Hear__c'+newoe.How_Did_You_Hear__c);
                            system.debug('How_Did_You_Hear__c--------'+oldoe.How_Did_You_Hear__c);
                            system.debug('Primary_Source__c'+opp.Primary_Source__c);
                        if(String.isNotBlank(newoe.How_Did_You_Hear__c) && String.isBlank(oldoe.How_Did_You_Hear__c)){
                            system.debug('test primary source');
                            opp.Primary_Source__c=newoe.How_Did_You_Hear__c;
                        }
                        
                finalupdateOpplist.add(opp);
            }
        
        }
        List<Database.SaveResult> oppsaveResults = new List<Database.SaveResult>();
        List<String> oppErrors = new List<String>();
        if(finalupdateOpplist!=null && finalupdateOpplist.size()>0){
            //Update Opportunities Related to OLE's
             oppsaveResults = Database.Update(finalupdateOpplist,false);
             recursive.OLEToOpp  = true;//This boolean is set to true to prevent afterupdate of opportunity object trigger. This static boolean is used to prevent recursion because when Ole is updated we updated opp and when opp is updated we update OLE
        }
        for (Database.SaveResult saveResult : oppsaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    oppErrors.add(e.getMessage());
                }
            }
        }
        system.debug(oppErrors);
        system.debug('opp updated list '+finalupdateOpplist);
        //End of opp update logic
        //Start of inserting secondary contacts
        List<Contact> SecondarycontactListFinal = new List<Contact>();
       
       if(newOEMap!=null && !newOEMap.isEmpty() && SecondaryContactFieldsMap!=null && !SecondaryContactFieldsMap.isEmpty()){
           for(Online_Enrollment__c oe:newOEMap.values()){
                Online_Enrollment__c newoe = newOEMap.get(oe.id);
                system.debug('newoe'+newoe);
                Online_Enrollment__c oldoe = OldOEMap.get(oe.id);
                system.debug('oldoe'+oldoe);
                if(String.isBlank(oldoe.Secondary_First_Name__c) && String.isBlank(oldoe.Secondary_Last_Name__c) && String.isBlank(oldoe.Secondary_Role__c) && (String.isNotBlank(newoe.Secondary_First_Name__c) || String.isNotBlank(newoe.Secondary_Last_Name__c) || String.isNotBlank(newoe.Secondary_Role__c))){
                    if(SecondaryContactFieldsMap.containsKey(oe.id)){
                        Contact c = new Contact();
                        if(String.isNotBlank(newoe.Secondary_First_Name__c)){
                        c.FirstName = newoe.Secondary_First_Name__c;
                        }
                        if(String.isNotBlank(newoe.Secondary_Last_Name__c)){c.LastName = newoe.Secondary_Last_Name__c;}
                        //if(String.isNotBlank(newoe.Secondary_Role__c)){ c.Role_Online_Enrollment__c = newoe.Secondary_Role__c;}
                        if(String.isNotBlank(SecondaryContactFieldsMap.get(newoe.id).Accountid)){c.accountId = SecondaryContactFieldsMap.get(newoe.id).Accountid;}
                        if(String.IsNotBlank(newoe.id)){ c.Online_Enrollment__c  = newoe.id;}
                        SecondarycontactListFinal.add(c);
                    }
                }
           }
       }
       
       List<Database.SaveResult> contactsaveResults = new List<Database.SaveResult>();
        List<String> contactErrors = new List<String>();
        if(SecondarycontactListFinal!=null && SecondarycontactListFinal.size()>0){
             contactsaveResults = Database.Insert(SecondarycontactListFinal,false);
        }
        for (Database.SaveResult saveResult : contactsaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    contactErrors.add(e.getMessage());
                }
            }
        }
        system.debug(contactErrors);
        system.debug('opp updated list '+SecondarycontactListFinal);
        //End of seconadry contacts creation.

        //Start of opportunityContactRole Create LogicalHandler
        List<OpportunityContactRole> oppConRoleFinal = new List<OpportunityContactRole>();
        if(SecondarycontactListFinal!=null && !SecondarycontactListFinal.isEmpty()){
            for(Contact c:SecondarycontactListFinal){
                if(SecondaryContactFieldsMap!=null && !SecondaryContactFieldsMap.isEmpty() && SecondaryContactFieldsMap.containsKey(c.Online_Enrollment__c)){
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.contactId  = c.id;
                    ocr.OpportunityID  = SecondaryContactFieldsMap.get(c.Online_Enrollment__c).id;
                    ocr.Role=newOEMap.get(c.Online_Enrollment__c).Secondary_Role__c;
                    oppConRoleFinal.add(ocr);
                }
            }
        }
        
        List<Database.SaveResult> OCRsaveResults = new List<Database.SaveResult>();
        List<String> OCRErrors = new List<String>();
        if(oppConRoleFinal!=null && oppConRoleFinal.size()>0){
             OCRsaveResults = Database.Insert(oppConRoleFinal,false);
        }
        for (Database.SaveResult saveResult : OCRsaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    OCRErrors.add(e.getMessage());
                }
            }
        }
        system.debug(OCRErrors);
        system.debug('opportunity ContactRoles for new secondary contacts '+oppConRoleFinal);
        
        //End of opportunity Contact role create logic
       
        //Start of provider facility logic
        Map<id,Opportunity_Provider__c> OppProviderMap = new Map<id,Opportunity_Provider__c>();
        List<Opportunity_Provider__c> finalOppProviderList = new List<Opportunity_Provider__c>();
        List<Opportunity_Provider__c> finalOppProviderListUpdate = new List<Opportunity_Provider__c>();
        if(oppidsForOppProvider!= null && !oppidsForOppProvider.isEmpty() && !oppProviderFacilityMapCreate.isEmpty()){
            system.debug('inside if');
            OppProviderMap = new Map<id,Opportunity_Provider__c>([select id,Facility__c,Primary_Provider__c,Opportunity__c,Provider__c,Provider_Facility__c,Opportunity__r.Online_Enrollment__c from Opportunity_Provider__c where Opportunity__c IN:oppidsForOppProvider AND Opportunity__r.Online_Enrollment__c IN:oppProviderFacilityMapCreate.keyset()]);
        }
        system.debug('OppProviderMap'+OppProviderMap);
        if(OppProviderMap!=null && !OppProviderMap.isEmpty() && !newOEMap.isEmpty()){
            system.debug('main if');
            for(Opportunity_Provider__c op:OppProviderMap.values()){
                Boolean Providerchcek = false;
                system.debug('for loop');
                Online_Enrollment__c newoe = newOEMap.get(op.Opportunity__r.Online_Enrollment__c);
                Online_Enrollment__c oldoe = OldOEMap.get(op.Opportunity__r.Online_Enrollment__c);
                //if provider and provider facility details are updated to null on online enrollment and existing opportunitiy provider has primary provider then update primary checkbox to false 
                if(String.isBlank(newoe.Provider_ID__c) && String.isBlank(newoe.Provider_Facility_ID__c) && String.isNotBlank(oldoe.Provider_ID__c) && String.isNotBlank(oldoe.Provider_Facility_ID__c) && String.isNotBlank(op.Opportunity__c)){
                    if(op.Primary_Provider__c){
                        op.Primary_Provider__c = false;
                    }
                } 
                if(MasteridPFSfdcIdmap!=null && !MasteridPFSfdcIdmap.isEmpty() && !MasterIdProviderIdMap.isEmpty() && MasteridPFSfdcIdmap.containsKey(newoe.Provider_Facility_ID__c) && MasterIdProviderIdMap.containsKey(newoe.Provider_ID__c)){
                    if(MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).Provider__c == MasterIdProviderIdMap.get(newoe.Provider_ID__c)){
                        Providerchcek=true;
                    }
                    if(String.isBlank(oldoe.Provider_ID__c) && String.isBlank(oldoe.Provider_Facility_ID__c) && String.isNotBlank(newoe.Provider_ID__c) && String.isNotBlank(newoe.Provider_Facility_ID__c) && String.isNotBlank(op.Opportunity__c) && MasterIdProviderIdMap.containsKey(newoe.Provider_ID__c) && MasteridPFSfdcIdmap.containsKey(newoe.Provider_Facility_ID__c)){
                        if(Providerchcek){
                           op.Provider__c  = MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).Provider__c; 
                           op.Provider_Facility__c = MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).id;
                           op.Facility__c = MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).Facility__c;
                           op.Primary_Provider__c = true;
                        }
                        if(op.Primary_Provider__c){
                            recursive.OLEToOp = true;//This boolean prevents opp proivder object's afterupdate trigger from executing. As we update opp provider from OLE. We update Opp provider when OLE's Provider Facility id and provider id fields are updated.
                        }
                    }
                    if(String.isNotBlank(oldoe.Provider_ID__c) && String.isNotBlank(newoe.Provider_ID__c) && newoe.Provider_ID__c != oldoe.Provider_ID__c && MasterIdProviderIdMap.containsKey(newoe.Provider_ID__c)){
                        system.debug('Check one');
                        if(Providerchcek){
                           op.Provider__c  = MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).Provider__c; 
                           op.Provider_Facility__c = MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).id;
                           op.Facility__c = MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).Facility__c;
                        }
                        if(op.Primary_Provider__c){
                            recursive.OLEToOp = true;//This boolean prevents opp proivder object's afterupdate trigger from executing. As we update opp provider from OLE. We update Opp provider when OLE's Provider Facility id and provider id fields are updated.
                        }
                      
                    }
                    if(String.isNotBlank(newoe.Provider_Facility_ID__c) && String.isNotBlank(oldoe.Provider_Facility_ID__c) && newoe.Provider_Facility_ID__c != oldoe.Provider_Facility_ID__c && MasteridPFSfdcIdmap.containsKey(newoe.Provider_Facility_ID__c)){
                        system.debug('check 2');
                       if(Providerchcek){
                           op.Provider__c  = MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).Provider__c; 
                           op.Provider_Facility__c = MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).id;
                           op.Facility__c = MasteridPFSfdcIdmap.get(newoe.Provider_Facility_ID__c).Facility__c;
                        }
                        if(op.Primary_Provider__c){
                            recursive.OLEToOp = true;//This boolean prevents opp proivder object's afterupdate trigger from executing. As we update opp provider from OLE. We update Opp provider when OLE's Provider Facility id and provider id fields are updated.
                        }
                       
                    }
                     
                }
               
                finalOppProviderListUpdate.add(op);
            }
        }
        system.debug('finalOppProviderListUpdate'+finalOppProviderListUpdate);
        List<Database.SaveResult> updateoppProvidersaveResults = new List<Database.SaveResult>();
        List<String> updateOPErrors = new List<String>();
        if(finalOppProviderListUpdate!=null && finalOppProviderListUpdate.size()>0){
             updateoppProvidersaveResults = Database.Update(finalOppProviderListUpdate,false);
        }
        for (Database.SaveResult saveResult : updateoppProvidersaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    updateOPErrors.add(e.getMessage());
                }
            }
        }
        system.debug(updateOPErrors);
        system.debug('updated opportunity provider '+finalOppProviderListUpdate);
        
        //To check  there is no opportunity provider for updated online enrollment's opportunities
        Set<id> OLDOppProvOes = new Set<id>();//set that contains online enrollment ids of OppProviderMap opportunities
        if(OppProviderMap!=null && !OppProviderMap.isEmpty()){
            for(Opportunity_Provider__c op:OppProviderMap.values()){
                if(String.isNotBlank(op.Opportunity__r.Online_Enrollment__c)){
                    OLDOppProvOes.add(op.Opportunity__r.Online_Enrollment__c);
                }
            }
        }
        
        if(newOEMap!=null && !newOEMap.isEmpty() && oppProviderFacilityMapCreate!=null &&!oppProviderFacilityMapCreate.isEmpty() && !MasterIdProviderIdMap.isEmpty() && MasteridPFSfdcIdmap!=null && !MasteridPFSfdcIdmap.isEmpty() && OppProviderMap.isEmpty()){
            for(Online_Enrollment__c oe:newOEMap.values()){
                Online_Enrollment__c newoe = newOEMap.get(oe.id);
                system.debug('newoe'+newoe);
                Online_Enrollment__c oldoe = OldOEMap.get(oe.id);
                system.debug('oldoe'+oldoe);
                if(!OLDOppProvOes.contains(oe.id) && ((String.isBlank(oldoe.Provider_ID__c) && String.isBlank(oldoe.Provider_Facility_ID__c) && String.isNotBlank(newoe.Provider_ID__c) && String.isNotBlank(newoe.Provider_Facility_ID__c)) || (String.isNotBlank(oldoe.Provider_ID__c) && String.isNotBlank(oldoe.Provider_Facility_ID__c) && String.isNotBlank(newoe.Provider_ID__c) && String.isNotBlank(newoe.Provider_Facility_ID__c)) )){
                    Opportunity_Provider__c op = new Opportunity_Provider__c();
                    if(String.isNotBlank(oppProviderFacilityMapCreate.get(oe.id).id)){
                        op.Opportunity__c = oppProviderFacilityMapCreate.get(oe.id).id;}
                    if(MasteridPFSfdcIdmap.ContainsKey(oe.Provider_Facility_ID__c)){
                        if(String.isNotBlank(MasteridPFSfdcIdmap.get(oe.Provider_Facility_ID__c).Provider__c)){
                            op.Provider__c  = MasteridPFSfdcIdmap.get(oe.Provider_Facility_ID__c).Provider__c;}
                        if(String.isNotBlank(MasteridPFSfdcIdmap.get(oe.Provider_Facility_ID__c).id)){
                            op.Provider_Facility__c  = MasteridPFSfdcIdmap.get(oe.Provider_Facility_ID__c).id;}
                        if(String.isNotBlank(MasteridPFSfdcIdmap.get(oe.Provider_Facility_ID__c).Facility__c)){
                            op.Facility__c = MasteridPFSfdcIdmap.get(oe.Provider_Facility_ID__c).Facility__c;}
                    }
                    op.Primary_Provider__c = true;
                    finalOppProviderList.add(op);
                }
            }
        }
        List<Database.SaveResult> oppProvidersaveResults = new List<Database.SaveResult>();
        List<String> OPErrors = new List<String>();
        if(finalOppProviderList!=null && finalOppProviderList.size()>0){
             oppProvidersaveResults = Database.Insert(finalOppProviderList,false);
        }
        for (Database.SaveResult saveResult : oppProvidersaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    OPErrors.add(e.getMessage());
                }
            }
        }
        system.debug(OPErrors);
        system.debug('opp updated list '+finalOppProviderList);
        
        //End of provider facility logic
        //Start of Contact Profile Payment update logic
        Map<id,Contact_Payment_Profile__c> CPPMap = new Map<id,Contact_Payment_Profile__c>();
         List<Contact_Payment_Profile__c> PayProfileFinalList = new list<Contact_Payment_Profile__c>();
        List<Contact_Payment_Profile__c> cppFinalUpdateList = new List<Contact_Payment_Profile__c>();
        Map<id,Contact> Primarycontacts = new Map<id,Contact>();
        if(CCPOeIds!=null && !CCPOeIds.isEmpty()){
            system.debug('cpp niot null');
            Primarycontacts = new map<id,Contact>([Select id,Online_Enrollment__c,ID_Information__c from contact where Online_Enrollment__c IN:CCPOeIds]);
            CPPMap = new Map<id,Contact_Payment_Profile__c>([Select id,Contact__c,Contact__r.Online_Enrollment__c,Card__c,Credit_Card_Type__c,Expiration_Month__c,Expiration_Year__c,Last_4_Digits__c,AX_CC_Id__c from Contact_Payment_Profile__c where Contact__r.Online_Enrollment__c IN:CCPOeIds]);
        }
        system.debug('..........Primarycontacts'+Primarycontacts);
        system.debug('CPPMap------'+CPPMap);
        Set<id> CppContactIds = new Set<id>();
        if(CPPMap!=null && !CPPMap.isEmpty()){
            system.debug('cpp map');
            for(Contact_Payment_Profile__c cpp:CPPMap.values()){
                system.debug('cpp valuessssss'+cpp);
                CppContactIds.add(cpp.Contact__c);
                Online_Enrollment__c newoe = newOEMap.get(cpp.Contact__r.Online_Enrollment__c);
                system.debug('newoe'+newoe);
                Online_Enrollment__c oldoe = OldOEMap.get(cpp.Contact__r.Online_Enrollment__c);
                system.debug('oldoe'+oldoe);
                if(Primarycontacts!=null && !Primarycontacts.isEmpty() && Primarycontacts.containsKey(cpp.Contact__c)){
                    if(newoe.Cardholder_Name__c!=oldoe.Cardholder_Name__c && String.isNotBlank(newoe.Cardholder_Name__c)){
                        cpp.Card__c = newoe.Cardholder_Name__c;
                    }
                    if(newoe.CC_Expiration_Month__c != oldoe.CC_Expiration_Month__c && newoe.CC_Expiration_Month__c!=null){
                        cpp.Expiration_Month__c =newoe.CC_Expiration_Month__c;
                    }
                    if(newoe.Credit_Card_Type__c != oldoe.Credit_Card_Type__c && String.IsNotBlank(newoe.Credit_Card_Type__c)){
                        cpp.Credit_Card_Type__c =newoe.Credit_Card_Type__c;
                    }
                    if(newoe.Credit_Card_Profile_ID__c != oldoe.Credit_Card_Profile_ID__c && newoe.Credit_Card_Profile_ID__c!=null){
                        cpp.Profile_Token__c =newoe.Credit_Card_Profile_ID__c;
                    }
                    if(newoe.Expiration_Year__c != oldoe.Expiration_Year__c && newoe.Expiration_Year__c!=null ){
                        cpp.Expiration_Year__c =newoe.Expiration_Year__c;
                    }
                    if(newoe.Last_4_Digits__c != oldoe.Last_4_Digits__c && newoe.Last_4_Digits__c !=null){
                        cpp.Last_4_Digits__c =newoe.Last_4_Digits__c;
                    }
                    cppFinalUpdateList.add(cpp);
                }
            }
        }
        else{
            if(Primarycontacts!=null && !Primarycontacts.isEmpty() && CppContactIds.isEmpty()){
                for(Contact c:Primarycontacts.values()){
                    if(!CppContactIds.contains(c.id)){
                        if(String.isNotBlank(c.ID_Information__c)){
                            Online_Enrollment__c newoe = newOEMap.get(c.Online_Enrollment__c);
                            system.debug('newoe'+newoe);
                            Contact_Payment_Profile__c cpp =new Contact_Payment_Profile__c();
                            cpp.Contact__c = c.id;
                            if(newoe.Credit_Card_Profile_ID__c!=null){cpp.Profile_Token__c =newoe.Credit_Card_Profile_ID__c;}
                            if(String.isNotBlank(newoe.Cardholder_Name__c)){cpp.Card__c = newoe.Cardholder_Name__c;}
                            if(String.isNotBlank(newoe.Credit_Card_Type__c)){ cpp.Credit_Card_Type__c = newoe.Credit_Card_Type__c;}
                            if(String.isNotBlank(newoe.Expiration_Year__c)){cpp.Expiration_Year__c = newoe.Expiration_Year__c;}
                            if(String.isNotBlank(newoe.CC_Expiration_Month__c)){cpp.Expiration_Month__c = newoe.CC_Expiration_Month__c;}
                            if(newoe.Last_4_Digits__c!=null){cpp.Last_4_Digits__c = newoe.Last_4_Digits__c;}
                            PayProfileFinalList.add(cpp);
                        }
                    }
                }
            }
        }
        
        List<Database.SaveResult> CPPsaveResults = new List<Database.SaveResult>();
        List<String> CPPErrors = new List<String>();
        if(cppFinalUpdateList!=null && cppFinalUpdateList.size()>0){
             CPPsaveResults = Database.Update(cppFinalUpdateList,false);
        }
        for (Database.SaveResult saveResult : CPPsaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    CPPErrors.add(e.getMessage());
                }
            }
        }
        system.debug(CPPErrors);
        system.debug('Cpp update list '+cppFinalUpdateList);
        
        //Creating new CPP if 
        
        List<Database.SaveResult> PayProSaveResults=new List<Database.SaveResult>();
        List<String> PayProErrors = new List<String>();
        if(PayProfileFinalList!=null && PayProfileFinalList.size()>0){
             PayProSaveResults = Database.insert(PayProfileFinalList,false);
        }
        for (Database.SaveResult saveResult : PayProSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    PayProErrors.add(e.getMessage());
                }
            }
        }
        system.debug('opp provider errors'+PayProErrors);
        system.debug('Contact payment profile final list'+PayProfileFinalList);
        //End of Contact Profile Payment update logic
        
        //Start of Contact Records update
        List<Contact> UpdateFinalContacts = new List<Contact>();
        Map<id,Contact> contactMap = new Map<id,contact>();
        Map<Contact,Online_Enrollment__c> SecondaryConOLEMap = new Map<Contact,Online_Enrollment__c>();
        list<OpportunityContactRole> OCRSecondarySCSSIdOles = new List<OpportunityContactRole>();
        Map<id,id> OLEToSecondaryContactIdMap = new Map<id,Id>();//This Map holds ole id as key and its secondary contact id as value when a seconadry contact SCSS id is provided on OLEe
        //Query on Contact to update contacts when contact related fields on OLE are updated.
        system.debug('SecSCSSId========'+SecSCSSId);
        if((ContactOes!=null && !ContactOes.isEmpty())||(SecondarySCSSIdOLEIdMap!=null && !SecondarySCSSIdOLEIdMap.isEmpty())){
            system.debug('ContactOes'+ContactOes);
            contactMap = new Map<id,Contact>([Select id,Online_Enrollment__c,Birthdate ,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,ID_Information__c,ID_Type__c,Phone,SCSS_Contact_Id__c from Contact where Online_Enrollment__c  IN :ContactOes OR SCSS_Contact_Id__c IN :SecondarySCSSIdOLEIdMap.keyset()]);
        }
        system.debug('SecondarySCSSIdOLEIdMap.keyset()'+SecondarySCSSIdOLEIdMap.keyset());
        system.debug('contactMap'+contactMap);
        if(contactMap!=null && !contactMap.isEmpty()){
            for(Contact c:contactMap.values()) {
                if(ContactOes.contains(c.Online_Enrollment__c)){
                    Online_Enrollment__c newoe = newOEMap.get(c.Online_Enrollment__c);
                    system.debug('newoe'+newoe);
                    Online_Enrollment__c oldoe = OldOEMap.get(c.Online_Enrollment__c);
                    system.debug('oldoe'+oldoe);
                    if(oldoe.Primary_Address__c != newoe.Primary_Address__c || newoe.Primary_Address_2__c != oldoe.Primary_Address_2__c){
                        
                        //If both primary address and primary address 2 are updated
                        if(oldoe.Primary_Address__c != newoe.Primary_Address__c && newoe.Primary_Address_2__c != oldoe.Primary_Address_2__c){
                            if(String.isNotBlank(newoe.Primary_Address__c) && String.isBlank(newoe.Primary_Address_2__c)){
                                 c.MailingStreet = newoe.Primary_Address__c;
                            }
                            else if(String.isBlank(newoe.Primary_Address__c) && String.isNotBlank(newoe.Primary_Address_2__c)){
                                c.MailingStreet = newoe.Primary_Address_2__c;
                            }
                            else{
                                c.MailingStreet = newoe.Primary_Address__c + ' '+ newoe.Primary_Address_2__c;
                            }
                        }
                        //When only Primary_Address__c is updated
                        else if(oldoe.Primary_Address__c != newoe.Primary_Address__c && newoe.Primary_Address_2__c == oldoe.Primary_Address_2__c){
                            if(String.isNotBlank(newoe.Primary_Address__c) && String.isBlank(newoe.Primary_Address_2__c)){
                                 c.MailingStreet = newoe.Primary_Address__c;
                            }
                            else if(String.isBlank(newoe.Primary_Address__c) && String.isNotBlank(newoe.Primary_Address_2__c)){
                                c.MailingStreet = newoe.Primary_Address_2__c;
                            }
                            else{
                                c.MailingStreet = newoe.Primary_Address__c + ' '+ newoe.Primary_Address_2__c;
                            }
                        }
                        //When only Primary_Address_2__c is updated
                        else if(oldoe.Primary_Address__c == newoe.Primary_Address__c && newoe.Primary_Address_2__c != oldoe.Primary_Address_2__c){
                            if(String.isNotBlank(newoe.Primary_Address__c) && String.isBlank(newoe.Primary_Address_2__c)){
                                 c.MailingStreet = newoe.Primary_Address__c;
                            }
                            else if(String.isBlank(newoe.Primary_Address__c) && String.isNotBlank(newoe.Primary_Address_2__c)){
                                c.MailingStreet = newoe.Primary_Address_2__c;
                            }
                            else{
                                c.MailingStreet = newoe.Primary_Address__c + ' '+ newoe.Primary_Address_2__c;
                        }
                    }
                }
                if(oldoe.Primary_City__c != newoe.Primary_City__c){
                    c.MailingCity  =newoe.Primary_City__c;
                }
                if(oldoe.Primary_State__c != newoe.Primary_State__c){
                    c.MailingState  =newoe.Primary_State__c;
                }
                if(oldoe.Primary_Country__c != newoe.Primary_Country__c){
                    c.MailingCountry  =newoe.Primary_Country__c;
                }
                if(oldoe.Primary_Zipcode__c != newoe.Primary_Zipcode__c){
                    c.MailingPostalCode  =newoe.Primary_Zipcode__c;
                }
                if(oldoe.PrimaryID__c != newoe.PrimaryID__c){
                    c.ID_Information__c  =newoe.PrimaryID__c;
                }
                if(oldoe.Primary_ID_Type__c != newoe.Primary_ID_Type__c){
                    c.ID_Type__c  =newoe.Primary_ID_Type__c;
                }
                if(oldoe.Primary_Home_Phone__c != newoe.Primary_Home_Phone__c){
                    c.Phone  =newoe.Primary_Home_Phone__c;
                }
                if(oldoe.Birth_Date_of_Primary__c != newoe.Birth_Date_of_Primary__c){
                    c.Birthdate  =newoe.Birth_Date_of_Primary__c;
                }
                
            }
            //If Secondary contact SCSS id is updated on OLE then update OLE id on contact
             if(SecondarySCSSIdOLEIdMap.containsKey(c.SCSS_Contact_Id__c)){
                system.debug('c.SCSS_Contact_Id__c==========='+c.SCSS_Contact_Id__c);
                system.debug('SecondarySCSSIdOLEIdMap====='+SecondarySCSSIdOLEIdMap);
                OLEToSecondaryContactIdMap.put(SecondarySCSSIdOLEIdMap.get(c.SCSS_Contact_Id__c),c.id);
                  c.Online_Enrollment__c = SecondarySCSSIdOLEIdMap.get(c.SCSS_Contact_Id__c);
                  //Create OpportunityContactRole for Seconadry conatct of OLE
                  OpportunityContactRole newOcr = new OpportunityContactRole();
                  newOcr.ContactId = c.id;
                  newOcr.Opportunityid = SecondaryOCROppCreateMap.get(SecondarySCSSIdOLEIdMap.get(c.SCSS_Contact_Id__c)).id;
                  if(String.isNotBlank(newOEMap.get(SecondarySCSSIdOLEIdMap.get(c.SCSS_Contact_Id__c)).Secondary_Role__c)){
                      newOcr.Role = newOEMap.get(SecondarySCSSIdOLEIdMap.get(c.SCSS_Contact_Id__c)).Secondary_Role__c;
                  }
                    else{
                        newOcr.Role = 'Unkown';
                    }
                    OCRSecondarySCSSIdOles.add(newOcr);
                }
                UpdateFinalContacts.add(c);
            }
           
        }
        List<Database.SaveResult> ContactsSaveResults=new List<Database.SaveResult>();
        List<String> UpdatedContactsErrors = new List<String>();
        system.debug('recursive.OleToContact============'+recursive.OleToContact);
        if(UpdateFinalContacts!=null && UpdateFinalContacts.size()>0 && !recursive.OleToContact){
             system.debug('Contact update from OLe');
             recursive.OleToContact = true;//This boolean is set to true to avoid recursion. we update contact when OLE is updated vice versa so to prevent recursion this boolean is used.This restricts after update trigger on contact object from exectuing 
             ContactsSaveResults = Database.update(UpdateFinalContacts,false);
             system.debug('ContactUpdateLogoc');
             system.debug('recursive.OleToContact'+recursive.OleToContact);
        }
        for (Database.SaveResult saveResult : ContactsSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    UpdatedContactsErrors.add(e.getMessage());
                }
            }
        }
        system.debug('updated contact erros'+UpdatedContactsErrors);
        system.debug('Update contacts list'+UpdateFinalContacts);

        //Inserting new OppContRole for Seconadry contact of OLE
        List<Database.SaveResult> SecConOCRSaveResults=new List<Database.SaveResult>();
        List<String> SecConOCRErrors = new List<String>();
        system.debug('OCRSecondarySCSSIdOles========'+OCRSecondarySCSSIdOles);
        if(OCRSecondarySCSSIdOles!=null && !OCRSecondarySCSSIdOles.isEmpty()){
            SecConOCRSaveResults = Database.Insert(OCRSecondarySCSSIdOles,false);
        }
        system.debug('SecConOCRSaveResults========'+SecConOCRSaveResults);
        for (Database.SaveResult saveResult : SecConOCRSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    SecConOCRErrors.add(e.getMessage());
                }
            }
        }
        system.debug('updated contact erros'+SecConOCRErrors);
        system.debug('New OCR list for secondary contacts of repeat client OLEs'+OCRSecondarySCSSIdOles);


        //End of contact Records update
        
          //Start of Online Enrollment validations if completed check is true
           Map<id,Opportunity> CompletedOppMap = new Map<Id,Opportunity>();//This map stores opp if completed flag is true
           Map<id,Opportunity> OppWithOP = new Map<id,Opportunity>();//This map stores opportunity contains opportuntiy provider
           Map<id,Opportunity_Provider__c> OppCompletedOPMap = new Map<id,Opportunity_Provider__c>();//This map holds opportunity providers of CompletedOppMap opportunities
           Map<id,Online_Enrollment__c> OLEMap = new Map<Id,Online_Enrollment__c>();
           //Below if condition if a updated opportunity's completed flag is true we add that opportunity id as key and opp as value to map CompletedOppMap
            if(finalupdateOpplist!=null && !finalupdateOpplist.isEmpty()){
                for(Opportunity opp:finalupdateOpplist){
                    if(opp.Completed_Flag__c){
                        system.debug('final list of opp provider');
                        CompletedOppMap.put(opp.id,opp);
                    }
                }
            }
            system.debug('CompletedOppMap--------'+CompletedOppMap);
            //If CompletedOppMap is not null then  query on opportunity provider where opp id of opp provider in CompletedOppMap key set.
            if(CompletedOppMap!=null && !CompletedOppMap.isEmpty()){
                OppCompletedOPMap = new Map<id,Opportunity_Provider__c>([select id,Facility__c,Primary_Provider__c,Opportunity__c,Provider__c,Provider_Facility__c,Opportunity__r.Online_Enrollment__c,Opportunity__r.Completed_Flag__c from Opportunity_Provider__c where Primary_Provider__c =true AND Opportunity__c IN:CompletedOppMap.keyset()]);
            }
            system.debug('OppCompletedOPMap========'+OppCompletedOPMap);
            //If a opportunity as opportunity provider record then we add that opp to map OppWithOP
            if(OppCompletedOPMap!=null && !OppCompletedOPMap.isEmpty() && CompletedOppMap!=null && !CompletedOppMap.isEmpty()){
                for(Opportunity_Provider__c op:OppCompletedOPMap.values()){
                    if(CompletedOppMap.containsKey(op.Opportunity__c)){
                        OppWithOP.put(op.Opportunity__c,CompletedOppMap.get(op.Opportunity__c));
                    }
                }
            }
            system.debug('OppWithOP======='+OppWithOP);
                            system.debug('finalOppProviderList true'+finalOppProviderList);
            //If finalOppProviderList is not null then we check if opp provider's opportunity's client flag is true. If it is true we add that opportunity to map OppWithOP
            if(finalOppProviderList!=null && !finalOppProviderList.isEmpty()){
                system.debug('finalOppProviderList true');
                for(Opportunity_Provider__c op:finalOppProviderList){
                    system.debug('op========='+op);
                    system.debug('oppProviderFacilityMapCreate==='+oppProviderFacilityMapCreate);
                    if(oppidsForOppProvider!=null && !oppidsForOppProvider.isEmpty() && oppidsForOppProvider.contains(op.Opportunity__c)  && opptoupdate.get(op.Opportunity__c).Completed_Flag__c){
                        system.debug('trueeeee=======');
                        system.debug('oppProviderFacilityMapCreate.get(op.Opportunity__c)'+oppProviderFacilityMapCreate.get(op.Opportunity__c));
                        system.debug('op.Opportunity__c-------------'+op.Opportunity__c);
                        system.debug('op.Opportunity__r.Online_Enrollment__c========'+op.Opportunity__r.Online_Enrollment__c);
                        OppWithOP.put(op.Opportunity__c,opptoupdate.get(op.Opportunity__c));
                    }
                    
                }
            }
            system.debug('OppWithOP========='+OppWithOP);
            if(OppWithOP!=null && !OppWithOP.isEmpty()){
                for(Opportunity opp:OppWithOP.values()){
                    if(newOEMap!=null && !newOEMap.isEmpty()){
                        OLEMap.put(opp.Online_Enrollment__c,newOEMap.get(opp.Online_Enrollment__c));
                    }
                }
                system.debug('isempty');
                if(OLEMap!=null && !OLEMap.isEmpty()){
                    onlineEnrollmentCreateupdateHelper.checkOLEOppValidations(OppWithOP,OLEMap);
                }
            }
           //End of Online Enrollment validations
        
            //Start of User Stories 469, 470, 471. During the creation of Online Enrollment record, there are  fields called ‘Campaign ID2’, ‘Source Code’ and ‘Promo Code’ if these fields have values then check for a campaign record if campaign record is found create a campaignInfluence record.
            List<CampaignInfluence> FinalCampaignInfList = new List<CampaignInfluence>();//List to insert campaignInfluence
            
            Map<id,Campaign> CampaignMap = new Map<id,Campaign>();//This Map holds campaigns which match with campaign id 2 or source code or promo code
             Map<String,Campaign> PromoSourceCode = new Map<String,Campaign>();
            if(CampaignCodeSet!=null && !CampaignCodeSet.isEmpty()){
                CampaignMap = new Map<id,Campaign>([Select id,Campaign_Code__c from Campaign where Campaign_Code__c IN:CampaignCodeSet]);
            }
            if(CampaignMap!=null && !CampaignMap.isEmpty()){
                for(Campaign c:CampaignMap.values()){
                     PromoSourceCode.put(c.Campaign_Code__c,c);
                }
            }
            if(PromoSourceCode!=null && !PromoSourceCode.isEmpty() && OppOeMapForCampagin!=null && !OppOeMapForCampagin.isEmpty()){
                for(Opportunity opp:OppOeMapForCampagin.values()){
                    Online_Enrollment__c newoe = newOEMap.get(opp.Online_Enrollment__c);
                    system.debug('newoe'+newoe);
                    Online_Enrollment__c oldoe = OldOEMap.get(opp.Online_Enrollment__c);
                    system.debug('oldoe'+oldoe);
                    if(oldoe.Promo_Code__c!=newoe.Promo_Code__c && String.isNotBlank(newoe.Promo_Code__c)){
                        CampaignInfluence ci = new CampaignInfluence();
                        ci.CampaignId = PromoSourceCode.get(newoe.Promo_Code__c).Id;
                        ci.OpportunityId = opp.id;
                        ci.Modelid =Label.Campaign_Model_Id;
                        FinalCampaignInfList.add(ci);
                    }
                    if(oldoe.Source_Code__c!=newoe.Source_Code__c &&  String.isNotBlank(newoe.Source_Code__c)){
                        CampaignInfluence ci1 = new CampaignInfluence();
                        ci1.CampaignId = PromoSourceCode.get(newoe.Source_Code__c).Id;
                        ci1.OpportunityId = opp.id;
                        ci1.Modelid =Label.Campaign_Model_Id;
                        FinalCampaignInfList.add(ci1);
                    }
                }
            }
            List<Database.SaveResult> CampaignInfSaveResult = new List<Database.SaveResult>();
            List<String> CIerrors = new list<String>();
            //insert FinalCampaignInfList if list is not empty
            if(FinalCampaignInfList!=null && FinalCampaignInfList.size()>0){
                 CampaignInfSaveResult = Database.insert(FinalCampaignInfList,false);
            }
            for (Database.SaveResult saveResult : CampaignInfSaveResult) {
                if (!saveResult.isSuccess()) {
                    for (Database.Error e : saveResult.getErrors()) {
                        CIerrors.add(e.getMessage());
                    }
                }
            }
            system.debug('CampaignInfluence errors'+CIerrors);
            system.debug('CampaignInfluence final recods'+FinalCampaignInfList);
            system.debug('FinalCampaignInfList size'+FinalCampaignInfList.size()); 
            
            //End of User Stories 469, 470, 471
           
    }
}
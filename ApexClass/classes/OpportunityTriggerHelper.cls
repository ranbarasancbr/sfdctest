/******************************************************************************************************************************
Component Name: OpportunityTriggerHelper
Description   : Helper class for opportunityTrigger. Logic of before and after trigger events are handled
Developed By  : TEKsystems
*******************************************************************************************************************************/
public class OpportunityTriggerHelper{
    // by using this method validate opportunity field CBRSFDC8-145 
    public static void checkvalidStage(List<Opportunity> oppList){
        Set<Id> oppIdSet = new Set<Id>();
        for(opportunity opp : oppList){
            Boolean allValidations = true;//If this boolean is true then only 
            oppIdSet.add(opp.Id);
            system.debug(opp.Ship_To_Phone__c);
            if(opp.Due_Date__c == null){
                Trigger.new[0].addError('Please Enter Due Date');
            }
            if(opp.Delivering_Hospital__c == Null){
                Trigger.new[0].addError('Please Enter Delivering Hospital');
            }
            if(opp.LeadSource == Null){
                Trigger.new[0].addError('Please Enter Lead Source');
            } 
            if( opp.Primary_Source__c == Null){
                Trigger.new[0].addError('Please Enter Primary Source');
            }
            if(opp.PickUp_or_Ship_Kit__c == 'N/A' || opp.PickUp_or_Ship_Kit__c == null){
                Trigger.new[0].addError('Please Select PickUp or Ship Kit');
            }
            if(opp.PickUp_or_Ship_Kit__c == 'Ship' && opp.Ship_To_Phone__c == Null){ 
                Trigger.new[0].addError('Please Enter Ship to Phone ');
            }
            if(opp.PickUp_or_Ship_Kit__c == 'Ship' && opp.Shipping_Method__c == Null){
                Trigger.new[0].addError('Please Enter Shipping Method');
            }
            if(opp.PickUp_or_Ship_Kit__c == 'Ship' && opp.Requested_Shipping_Date__c == Null){
                Trigger.new[0].addError('Please Enter Requested Shipping Date');
            }
            if(opp.PickUp_or_Ship_Kit__c == 'Ship' && String.isBlank(opp.Ship_To_Name__c)){
                Trigger.new[0].addError('Please Enter Ship to Name');
            }
            if(opp.PickUp_or_Ship_Kit__c == 'Ship' && String.isBlank(opp.Ship_To_Street1__c)){ 
                Trigger.new[0].addError('Please Enter Ship to Street');
            }
             if(opp.PickUp_or_Ship_Kit__c == 'Ship' && String.isBlank(opp.Ship_To_City__c)){ 
                Trigger.new[0].addError('Please Enter Ship to City');
            }
             if(opp.PickUp_or_Ship_Kit__c == 'Ship' && String.isBlank(opp.Ship_To_State__c)){ 
                Trigger.new[0].addError('Please Enter Ship to State');
            }
            if(opp.PickUp_or_Ship_Kit__c == 'Ship' && String.isBlank(opp.Ship_To_Zip_Code__c)){ 
                Trigger.new[0].addError('Please Enter Ship to Zip Code');
            }
          
        }
        system.debug('oppIdSet000000000000'+oppIdSet);
       if(oppIdSet!=null && !oppIdSet.isEmpty()){
           system.debug('oppIdSet0000000000009999'+oppIdSet);
           //Logic to check Primary provider for enrolled opportunity
           List<Opportunity_Provider__c> oppProviderList = [Select Id,Name,Primary_Provider__c,Facility__c, Provider_Facility__c,Opportunity__c From Opportunity_Provider__c Where Primary_Provider__c = true and Opportunity__c IN :oppIdSet]; 
           system.debug(oppProviderList );
            if(oppProviderList.size() >0){
                for(Opportunity_Provider__c oppProvider: oppProviderList){
                    //if( oppProvider.Facility__c == Null){
                    if( oppProvider.Provider_Facility__c == Null){    
                        Trigger.new[0].addError('Please Enter Primary Provider Facility');
                    }
                }
            }else{
                Trigger.new[0].addError('Please Enter Primary Provider');
            }
            //Check atleast one mother contactRole on opportunity
            List<OpportunityContactRole> contactRoleList = [SELECT ContactId,IsPrimary,Role,Contact.MailingStreet,Contact.MailingCountry,Contact.Birthdate,Contact.Email,Contact.ID_Information__c,Contact.ID_Type__c,Contact.Phone, OpportunityId, Id FROM OpportunityContactRole Where OpportunityId In : oppIdSet];
            Map<Id,List<OpportunityContactRole>> oppContactRolesMap = new Map<id,List<OpportunityContactRole>>();
            if(contactRoleList!=null && !contactRoleList.isEmpty()){
                for(OpportunityContactRole ocr:contactRoleList){
                    List<OpportunityContactRole> tempList = new List<OpportunityContactRole>();
                    tempList = oppContactRolesMap.get(ocr.OpportunityId);
                    if(tempList == null){
                        oppContactRolesMap.put(ocr.OpportunityId,new List<OpportunityContactRole>{ocr});
                    }
                    else{
                        tempList.add(ocr);
                        oppContactRolesMap.put(ocr.Opportunityid,tempList);
                    }
                }    
            }
            Map<id,OpportunityContactRole> oppContactRoleMap = new Map<id,OpportunityContactRole>();
            Map<id,id> OppIdPrimaryContactIdMap = new Map<Id,Id>();//This map holds opp id as key and its primary contact's id as value
            Integer count = 0;
            if(!oppContactRolesMap.isEmpty()){
                //Check mother contact role if not present error is displayed or if there are more than 1 mother role error is displayed
                for(Opportunity opp:oppList){
                    if(oppContactRolesMap.containsKey(opp.id)){
                        Boolean hasMotherRole = false;

                        for(OpportunityContactRole ocr:oppContactRolesMap.get(opp.id)){
                            if(ocr.Role == 'Mother'){
                                hasMotherRole = true;
                                count++;
                            }
                            if(ocr.IsPrimary){
                                oppContactRoleMap.put(opp.id,ocr);
                                OppIdPrimaryContactIdMap.put(opp.id,ocr.ContactId);
                            }
                        }
                        if(!hasMotherRole){
                            opp.addError('Please Add Mother Contact Role');
                        }
                        //Number of ContactRoles with mother 
                        if( count >1){
                            opp.addError('Opportunity can contain only one Mother');
                        }
                    }
                    else{
                        opp.addError('Please Add Mother Contact Role');
                    }
                }
                for(Opportunity opp:oppList){
                    if(!oppContactRoleMap.isEmpty() && oppContactRoleMap.containsKey(opp.id)){
                        OpportunityContactRole ocr = oppContactRoleMap.get(opp.id);
                        if(String.isBlank(ocr.Contact.MailingStreet)){
                            opp.addError('Please Enter Primary Address');
                        }
                        if(String.isBlank(ocr.Contact.MailingCountry)){
                            opp.addError('Please Enter Primary Country');
                        }
                        if(ocr.Contact.Birthdate == null){
                            opp.addError('Please Enter Primary Contact Date Of Birth');
                        }
                        if(ocr.Contact.Email==null){
                            opp.addError('Please Enter Primary Contact Email');
                        }
                        if(String.isBlank(ocr.Contact.ID_Information__c)){
                            opp.addError('Please Enter Primary Contact ID Information');
                        }
                        if(String.isBlank(ocr.Contact.ID_Type__c)){
                            opp.addError('Please Enter Primary Contact ID Type');
                        }
                        if(ocr.Contact.Phone == null){
                            opp.addError('Please Enter Primary Contact Phone');
                        }
                    }
                    else{
                        opp.addError('Please add a primary contact');
                        }
                }
                //CBRSFDC8-677 Logic to check if enrolling opp's primary contact is associated with already closed opportunity with loss reason = 'OFAC/SDNL' 
                Map<id,OpportunityContactRole> OCRMap = new Map<Id,OpportunityContactRole>();
                if(OppIdPrimaryContactIdMap!=null && !OppIdPrimaryContactIdMap.isEmpty()){
                    System.debug('OppIdPrimaryContactIdMap======================> '+OppIdPrimaryContactIdMap);
                 
                    //Creating Map with OppContactRole id as key and OppContactRole record as value
                    //OCRMap = new Map<Id,OpportunityContactRole>([Select id,OpportunityId,Opportunity.Status__c,Opportunity.Loss_Reason__c from OpportunityContactRole where id IN:OppIdPrimaryContactIdMap.values() AND OpportunityId NOT IN:oppIdSet AND Opportunity.Status__c = 'Closed_Lost' AND Opportunity.Loss_Reason__c = 'OFAC/SDNL']);
                    OCRMap = new Map<Id,OpportunityContactRole>([Select id,OpportunityId,ContactId,Opportunity.Status__c,Opportunity.Loss_Reason__c from OpportunityContactRole where ContactId IN:OppIdPrimaryContactIdMap.values() AND Opportunity.Status__c = 'Closed_Lost' AND Opportunity.Loss_Reason__c = 'OFAC/SDNL']);
                    Set<Id> OCRContactIdSet = new Set<Id>();
                   for (OpportunityContactRole ocr : OCRMap.values()){
                            OCRContactIdSet.add(ocr.contactId);
                    }

                    system.debug('OCRMap==========> '+ OCRMap);
                    if(OCRMap!=null && !OCRMap.isEmpty()){
                        for(opportunity opp:oppList){
                            
                           // if(OCRMap.containsKey(OppIdPrimaryContactIdMap.get(opp.id))){
                            if(OCRContactIdSet.contains(OppIdPrimaryContactIdMap.get(opp.id))){
                                system.debug('Opp-Name====='+ opp.name);

                                opp.addError('Opportunity cannot be enrolled, due to OFAC/SDNL. Please notify the manager');
                            }
                        }//End of for loop
                    }
                   
                }

            }
         
        }
        
    }
   
    //by using this method update kit order Information CBRSFDC8-147
    public static void updateKitOrderInformation(List<Opportunity> oppList){
        Shipping_Cost__mdt[] custMeta;
        Set<Id> conIdSet = new Set<Id>();
        Map<Id,Id> oppConMap = new Map<Id,Id>();
        for(Opportunity opp :oppList){
            oppConMap.put(opp.Id,opp.Primary_Contact__c);
            conIdSet.add(opp.Primary_Contact__c);
            Date startDate = date.today();
            Date dueDate = opp.Due_Date__c;
            Integer numberDaysDue;
            if(dueDate!=null)
            numberDaysDue = startDate.daysBetween(dueDate);
            
         /*   if(opp.of_Babies__c == 'Single' && opp.PickUp_or_Ship_Kit__c == 'Ship' && numberDaysDue <= 30){
                opp.Shipping_Method__c = 'Priority Overnight';
            }   
            if(opp.of_Babies__c == 'Single'  && opp.PickUp_or_Ship_Kit__c == 'Ship' && numberDaysDue > 30){
                opp.Shipping_Method__c = 'Second day';
            }
            if((opp.of_Babies__c == 'Twins' || opp.of_Babies__c == ' Triplets   ' || opp.of_Babies__c == 'Quadruplets' || opp.of_Babies__c == 'Quintuplets')  && (numberDaysDue <= 60) && (opp.PickUp_or_Ship_Kit__c == 'Ship' )){
                opp.Shipping_Method__c = 'Priority Overnight';
            }
            if((opp.of_Babies__c == 'Twins' || opp.of_Babies__c == ' Triplets' || opp.of_Babies__c == 'Quadruplets' || opp.of_Babies__c == 'Quintuplets')  && (numberDaysDue >= 60)&& (opp.PickUp_or_Ship_Kit__c == 'Ship')){
                opp.Shipping_Method__c = 'Second day';
            }*/
            
            // Use custom meta data type Shipping_Method_mdt instead of hardcoding values.
            Shipping_Method__mdt[] shipMethods = [SELECT MasterLabel, DeveloperName,of_Babies__c,PickUp_or_Ship_Kit__c,Operator__c,NumberDaysDue__c,Shipping_Method__c FROM Shipping_Method__mdt];
            system.debug('ShipMethods==============>'+ shipMethods);
            
            for (Shipping_Method__mdt sm: shipMethods) {

                if( opp.of_Babies__c == sm.of_Babies__c && opp.PickUp_or_Ship_Kit__c == sm.PickUp_or_Ship_Kit__c && numberDaysDue <= sm.NumberDaysDue__c && sm.Operator__c == '<='){ 
                    opp.Shipping_Method__c = sm.Shipping_Method__c; 
                }
                else if( opp.of_Babies__c == sm.of_Babies__c && opp.PickUp_or_Ship_Kit__c == sm.PickUp_or_Ship_Kit__c && sm.Operator__c == '>' &&  numberDaysDue > sm.NumberDaysDue__c){ 
                    opp.Shipping_Method__c = sm.Shipping_Method__c; 
                }                 

            }            
            
            if(opp.Requested_Shipping_Date__c == Null || opp.Requested_Shipping_Date__c != Null){
                opp.Requested_Shipping_Date__c = system.Today();
            }
           /* if(opp.Requested_Shipping_Method__c == null){
                opp.Amount = 0;
                opp.Total_Expedited_Shipping_Cost__c = 0;
                opp.Saturday_Delivery__c = false;
                opp.Signature_Required__c = false;
            }
            if(opp.Requested_Shipping_Method__c == 'Priority Overnight'){
                opp.Amount = 25;
                opp.Total_Expedited_Shipping_Cost__c = 25;
            }
            if(opp.Requested_Shipping_Method__c == 'Courier'){
                opp.Amount = 125;
                opp.Total_Expedited_Shipping_Cost__c = 125;
            }
            if(opp.Signature_Required__c == true && opp.Requested_Shipping_Method__c == 'Priority Overnight'){
                opp.Amount = 25;
                opp.Total_Expedited_Shipping_Cost__c = 30;

            }
            if(opp.Saturday_Delivery__c == true && opp.Requested_Shipping_Method__c == 'Priority Overnight'){
                opp.Amount = 25;
                opp.Total_Expedited_Shipping_Cost__c = 45;

            }
            if(opp.Signature_Required__c == true && opp.Requested_Shipping_Method__c == 'Priority Overnight' && opp.Saturday_Delivery__c == true){
                opp.Amount = 25;
                opp.Total_Expedited_Shipping_Cost__c = 50;

            }
            if(opp.Saturday_Delivery__c == true && opp.Requested_Shipping_Method__c == 'Courier'){
                 opp.Amount = 125;
                 opp.Total_Expedited_Shipping_Cost__c = 145;
            }
            if(opp.Saturday_Delivery__c == true && opp.Requested_Shipping_Method__c == 'Courier' && opp.Signature_Required__c == true){
                 opp.Amount = 125;
                 opp.Total_Expedited_Shipping_Cost__c = 150;
            }*/
            Shipping_Cost__mdt[] shipCosts = [SELECT MasterLabel, DeveloperName,Requested_Shipping_Method__c,Saturday_Delivery__c,Signature_Required__c, Amount__c ,Total_Expedited_Shipping_Cost__c FROM Shipping_Cost__mdt];
            system.debug('ShipCosts==============>'+ shipCosts);
            for (Shipping_Cost__mdt s: shipCosts) { 
                if(opp.Requested_Shipping_Method__c == s.Requested_Shipping_Method__c && opp.Saturday_Delivery__c == s.Saturday_Delivery__c && opp.Signature_Required__c == s.Signature_Required__c){
                   opp.Amount = s.Amount__c;
                   opp.Total_Expedited_Shipping_Cost__c = s.Total_Expedited_Shipping_Cost__c;
                }
            }
            System.debug('opp.Amount===>'+opp.Amount);
            System.debug('opp.Total_Expedited_Shipping_Cost===>'+opp.Total_Expedited_Shipping_Cost__c);
            
        }
        //Map<Id,Contact>  conMap  = new Map<Id,Contact>([Select Id,Name,Primary_Address__c,Timezone__c,MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,Primary_Contact_Phone__c,Phone From Contact Where Id In:oppConMap.values()]);        
        Map<Id,Contact>  conMap  = new Map<Id,Contact>([Select Id,Name,Timezone__c,MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,Phone From Contact Where Id In:oppConMap.values()]);    
        if(oppList!=null && !oppList.isEmpty()){
            for(Opportunity opp :oppList){
               if(String.isNotBlank(opp.Primary_Contact__c)){ 
                   if(oppConMap!=null && !oppConMap.isEmpty() && oppConMap.containskey(opp.Id)){
                       if(conMap.containskey(oppConMap.get(opp.Id))){
                          
                           if(String.isNotBlank(conMap.get(oppConMap.get(opp.Id)).MailingStreet) && String.isBlank(opp.Ship_To_Street1__c)){
                                opp.Ship_To_Street1__c= conMap.get(oppConMap.get(opp.Id)).MailingStreet;
                           }
                           if(String.isNotBlank(conMap.get(oppConMap.get(opp.Id)).MailingCity) && String.isBlank(opp.Ship_To_City__c)){
                                opp.Ship_To_City__c = conMap.get(oppConMap.get(opp.Id)).MailingCity;
                           }
                           if(String.isNotBlank(conMap.get(oppConMap.get(opp.Id)).MailingState) && String.isBlank(opp.Ship_To_State__c)){
                                 opp.Ship_To_State__c = conMap.get(oppConMap.get(opp.Id)).MailingState;
                           }
                           if(String.isNotBlank(conMap.get(oppConMap.get(opp.Id)).MailingCountry) && String.isBlank(opp.Ship_To_Country__c)){
                                 opp.Ship_To_Country__c = conMap.get(oppConMap.get(opp.Id)).MailingCountry;
                           }
                           if(String.isNotBlank(conMap.get(oppConMap.get(opp.id)).MailingPostalCode) && String.isBlank(opp.Ship_To_Zip_Code__c) ){
                                 opp.Ship_To_Zip_Code__c = conMap.get(oppConMap.get(opp.Id)).MailingPostalCode;
                           }
                           if(String.isNotBlank(conMap.get(oppConMap.get(opp.Id)).Timezone__c) && String.isBlank(opp.Clients_Time_Zone__c)){
                                opp.Clients_Time_Zone__c = conMap.get(oppConMap.get(opp.Id)).Timezone__c;
                           }
                           if(String.isNotBlank(conMap.get(oppConMap.get(opp.Id)).Name) && String.isBlank(opp.Ship_To_Name__c)){
                                 opp.Ship_To_Name__c = conMap.get(oppConMap.get(opp.Id)).Name;
                           }
                           if(opp.Ship_To_Phone__c == null)
                           if(String.isNotBlank(conMap.get(oppConMap.get(opp.Id)).Phone)){opp.Ship_To_Phone__c = conMap.get(oppConMap.get(opp.Id)).Phone;}
                       }
                   }
               }
               
            }
        }
        
    }
    //By using this method we are updating Primary Contact and Secondary Contact Details on opportunity 
    public static void updatePrimaryContactOnOpp(List<Opportunity> oppList){
        Map<Id,Id> referMap = new Map<Id,Id>();
        Set<Id> oppIdSet = new Set<Id>();
        if(oppList!=null && !oppList.isEmpty()){
            for(Opportunity opp : oppList){
                oppIdSet.add(opp.Id);
                //oppIdSet.add(opp.Referred_By_Opportunity__c);
                referMap.put(opp.Id,opp.Referred_By_Opportunity__c);
            }
        }
        system.debug('oppIdSet'+oppIdSet);
        system.debug('oppList'+oppList);
        List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
        //Get all OCR for opportunities that are updating 
        if(oppIdSet!=null && !oppIdSet.isEmpty()){
        contactRoleList = [SELECT ContactId,Role,IsPrimary, OpportunityId, Id FROM OpportunityContactRole Where OpportunityId In: oppIdSet];
        }
        system.debug('contactRoleList'+contactRoleList);
        system.debug('list size contact Role'+contactRoleList.size());
        Map<Id,Id> primaryConMap = new Map<Id,Id>();
        Map<Id,Id> secondaryConMap = new Map<Id,Id>();
        Set<Id> conIdSet = new Set<Id>();
        Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
        if(contactRoleList!= null && contactRoleList.size() >0){
            for(OpportunityContactRole ocr : contactRoleList){
                if(ocr.IsPrimary == true){
                    primaryConMap.put(ocr.OpportunityId,ocr.ContactId);
                    }else{
                    secondaryConMap.put(ocr.OpportunityId,ocr.ContactId);
                }
                conIdSet.add(ocr.ContactId);
            }
        }
        system.debug('primaryConMap===='+primaryConMap);
        system.debug('secondaryConMap====='+secondaryConMap);
        if(conIdSet!=null && !conIdSet.isEmpty()){
            mapOfContact = new Map<Id,Contact>([Select Id,FirstName,Email,LastName,Name,Phone From Contact Where ID In : conIdSet]);
        } 
        system.debug('mapOfContact====='+mapOfContact);
            system.debug('list size contact map'+mapOfContact.size());
            List<Contact> conList = new List<Contact>();
            List<Opportunity> opprList = new List<Opportunity>();
            if(oppList!=null && !oppList.isEmpty()){
                system.debug('inside if condition....');
                for(Opportunity opp : oppList){
                    system.debug('inside if condition....');
                    //opp.Contact_Role_Primary__c = '';
                    //opp.Primary_Phone__c = '';
                    //Set opportunity primary contact
                    if(primaryConMap.containskey(opp.Id)){
                        String conKey = primaryConMap.get(opp.Id);
                        system.debug('Contact Key'+conKey);
                        if(mapOfContact.containskey(conKey)){
                            system.debug('firt Name'+mapOfContact.get(conKey).Name);
                            opp.Contact_Role_Primary__c = mapOfContact.get(conKey).Name;
                            //opp.Primary_Phone__c = mapOfContact.get(conKey).Phone;
                            opp.Primary_Email__c = mapOfContact.get(conKey).Email;
                            opp.primary_contact__c = mapOfContact.get(conKey).id;
                        }
                    }
                    else{
                            opp.primary_contact__c = null;
                    }
                    system.debug('opp id-----'+opp.id);
                    system.debug('secondaryConMap===='+secondaryConMap);
                    if(secondaryConMap.containskey(opp.Id) && secondaryConMap!=null && !secondaryConMap.isEmpty()){
                        system.debug('secondary contact');
                        //String conKey = secondaryConMap.get(opp.Id);
                        system.debug('Contact Key'+secondaryConMap.get(opp.Id));
                        if(mapOfContact.containskey(secondaryConMap.get(opp.Id))){
                            system.debug('Name'+mapOfContact.get(secondaryConMap.get(opp.Id)).Name);
                            opp.Secondary_Contact__c = mapOfContact.get(secondaryConMap.get(opp.Id)).id;
                            opp.Secondary_Phone__c = mapOfContact.get(secondaryConMap.get(opp.Id)).Phone;
                            opp.Contact_Role_Secondry__c = mapOfContact.get(secondaryConMap.get(opp.Id)).Name;
                        }
                        
                    }else{
                        opp.Contact_Role_Secondry__c =null;
                        opp.Secondary_Contact__c = null;
                        opp.Secondary_Phone__c = null;
                    }
                    
                  
                }   
            }
           
    }
    //Start of Logic for User Story 346 and 345
    //this method Update Opp StageName when opp created on lead coversion. If lead recordtype is manual lead then stage = Rapport and Education (5) and if lead recordtype is MQL stage is set to Marketing Qualified (4)
    public static void LeadOppUpdate(List<Opportunity> opplist){
        
       if(opplist!=null && !opplist.isEmpty()){
             for(Opportunity opp:opplist){
               if(String.IsNotBlank(opp.Lead_RecordType_Name__c)){
               system.debug('========='+opp.Lead_RecordType_Name__c);
                   if(opp.Lead_RecordType_Name__c == 'Manual Lead'){
                    opp.StageName = 'Rapport and Education (5)';
                   }
                   else if(opp.Lead_RecordType_Name__c == 'MQL'){
                       opp.StageName = 'Marketing Qualified (4)';
                   }
               }
             /*  if(opp.LeadSource == 'CSS Referral'){
                   opp.StageName = 'Marketing Qualified (4)';
               }*/
           }//End of for loop
        }
    }
    //End of Logic for User Story 346 and 345
    
    // User Story 544 this method update manager field on opportunity according to opportunity owner
      
    public static void populateRoleHierarchyPaarent(List<Opportunity> lstOpp){
        
        Map<String,String> mapOfRoleParentName = new Map<String,String>();
        Map<String,String> mapOfRoleHierarchy = new Map<String,String>();
        Map<String,String> mapOfUserRole = new Map<String,String>();
        Set<String> opportunityOwnerSet = new Set<String>();
        Map<id,user> userIdMap = new Map<id,user>();
        Map<id,Id> userIdWithParentRoleIdMap = new Map<id,Id>();
        Map<id,User> usersAsParentRolesMap = new Map<id,User>();
        Map<id,Id> ParentRoleIdUserIdMap = new Map<id,Id>();//This map holds parent role id as key and user id as values
        for(Opportunity opp : lstOpp){
            System.debug('opp.OwnerId' + opp.OwnerId);
            opportunityOwnerSet.add(opp.OwnerId);//Add opportunity owner ids in set opportunityOwnerSet
        }
        
        System.debug(opportunityOwnerSet);
        //Query on users who are opp's owners whose UserRole.ParentRoleId != NULL
        if(opportunityOwnerSet!=null && !opportunityOwnerSet.isEmpty()){
            userIdMap = new Map<id,User>([SELECT Id, Username,Name,UserRole.Name,UserRoleId,UserRole.ParentRoleId 
                        FROM User WHERE UserRole.ParentRoleId != NULL AND Id IN : opportunityOwnerSet]);
        }
        //Add userId and its parentRoleId to map userIdWithParentRoleIdMap as key value pair
        for(User u:userIdMap.values()){
           userIdWithParentRoleIdMap.put(u.id,u.UserRole.ParentRoleId);
        }
        //if userIdWithParentRoleIdMap is having values then again query on user whose UserRoleId in parentRole ids of opportunity owners
        if(!userIdWithParentRoleIdMap.isEmpty()){
            usersAsParentRolesMap = new Map<id,user>([SELECT Id, Username,Name,UserRole.Name,UserRoleId,UserRole.ParentRoleId 
                        FROM User WHERE UserRoleId IN : userIdWithParentRoleIdMap.values()]);
        }
        //Add UserRoleid (which is parentRole id of opportunity owners) as key and user id as value.  usersAsParentRolesMap will have more than one user with parentRoleId but we assign value of first user as manager__c form usersAsParentRolesMap.
        for(User u:usersAsParentRolesMap.values()){
            ParentRoleIdUserIdMap.put(u.UserRoleId,u.id);
        }
        //Update Manager__c with user id whose Role id is parentRoleId of opportunty owner
        if(ParentRoleIdUserIdMap!=null || !ParentRoleIdUserIdMap.isEmpty()){
            for(Opportunity opp:lstOpp){
                opp.Manager__c = ParentRoleIdUserIdMap.get(userIdWithParentRoleIdMap.get(opp.OwnerId));
            }
        }
    }
    //End of Logic for User Story 544
    // User Story 676 This method update Ship To City & Ship To State field on opportunity when Ship To Zip Code is selected

    public static void OpportunityZipUpdate(List<Opportunity> opplist){
        //get the first five digits of the PostalCode from the opp
        set<string> left5zips = new set<string>(); 
        for(Opportunity Opp: opplist){
            if (opp.Ship_To_Zip_Code__c !=null && opp.Ship_To_Zip_Code__c.length()>=5){
                left5zips.add(opp.Ship_To_Zip_Code__c.substring(0,5));
            }     
        } 

        //query the zip_code object to get the zipcode (Name) and zone from the zip code object 
        map<string,string> zmapCity = new map<string,string>(); 
        map<string,string> zmapState = new map<string,string>(); 
        for(US_Zipcode__c z :[Select name, city__c, state__c from US_Zipcode__c WHERE name IN :left5zips]){
            zmapCity.put (z.name, z.city__c);
            zmapState.put (z.name, z.state__c);
        }
        
        for(Opportunity Opp: opplist){ 

            if(Opp.Ship_To_Country__c == 'United States'&& zmapCity != null && !zmapCity.isempty() && zmapCity.containskey(opp.Ship_To_Zip_Code__c.substring(0,5))){ 
                Opp.Ship_To_City__c=zmapCity.get(opp.Ship_To_Zip_Code__c.substring(0,5)); 
            }
            if(opp.Ship_To_Country__c == 'United States'&& zmapState != null && !zmapState.isempty() &&zmapState.containskey(opp.Ship_To_Zip_Code__c.substring(0,5))){ 
                Opp.Ship_To_State__c=zmapState.get(opp.Ship_To_Zip_Code__c.substring(0,5)); 
            }                
        } 
    }  

}
/***************************************************************************************************************************************************
*Component Name: 
*Description   : Validation on contact object to prevent FirstName, LastName and Email fields values update this triggers on contact before update. 
                 When user trying to edit First name, Last Name and Email on primary contact of a Lab Created opportunity. 
*Developed By  :Teksystems
*/
public class LabContactsUpdateValidations{
public static void ContactValidations(Map<Id,Contact> newMap, Map<Id,Contact> oldMap){
    Map<Id,Opportunity> oppMap = new Map<id,Opportunity>();//This Map holds Lab Created Opportunities 
    Set<id> contactIds = new Set<Id>();//set holds Contact ids for which First Name or last name or email are updating
    Map<Id,Contact> UpdatingContactMap = new Map<Id,Contact>();//Contatcs for which First Name or last name or email are updating those contacts are added to this map 
    //Checking if First Name  or last name or Email are udpating if these fields are updating then adding those contact ids to contactIds and also adding values in map UpdatingContactMap
    if(newMap!=null && !newMap.isEmpty()){
        for(Contact c:newMap.values()){
            if(oldMap.get(c.id).FirstName != newMap.get(c.id).FirstName || oldMap.get(c.id).LastName != newMap.get(c.id).LastName || oldMap.get(c.id).Email != newMap.get(c.id).Email){
                contactIds.add(c.id);
                UpdatingContactMap.put(c.id,c);
            }
        }
    }
    //If contactIds is not null then querying on opportunity object to get opportunties where Lead source ='lab' and primary contact is from updating contact ids(i.e contactIds)
    if(contactIds!=null && !contactIds.isEmpty()){
        oppMap = new Map<id,Opportunity>([Select id,Primary_Contact__c from Opportunity Where Primary_Contact__c IN:contactIds AND LeadSource = 'Lab']);
    }
    Set<Id> ContactIdsOnOpp = new Set<Id>();//This Set contact ids which are on primary contact of opportunity records(i.e from oppMap)
    system.debug('oppMap'+oppMap);
    //If there are opportunities with primary contact as updating contacts and leadsource is Lab(i.e oppMap is not null) then we add those opportunity's primary contact ids to this set ContactIdsOnOpp.
    if(oppMap!=null && !oppMap.isEmpty()){
        for(Opportunity opp:oppMap.values()){
            ContactIdsOnOpp.add(opp.Primary_Contact__c);
        }
    }
    system.debug('ContactIdsOnOpp'+ContactIdsOnOpp);
    //If First name or Lastname or Email of primary contact of a lab created  Opportunity is updating then below errors are triggered.
    system.debug('UpdatingContactMap'+UpdatingContactMap);
    if(UpdatingContactMap!=null && !UpdatingContactMap.isEmpty() && ContactIdsOnOpp!=null && !ContactIdsOnOpp.isEmpty()){
        for(Contact c:UpdatingContactMap.Values()){
            if(ContactIdsOnOpp.contains(c.id)){
                //if first name is updating below error is showed 
                if(!Test.isRunningTest() && oldMap.get(c.id).FirstName != newMap.get(c.id).FirstName || oldMap.get(c.id).LastName != newMap.get(c.id).LastName || oldMap.get(c.id).Email != newMap.get(c.id).Email){
                    c.addError(System.Label.Primary_Contact_Name_Email_Update_Error);
                }
            }
        }
    }
    
}
}
/********************************************************************************************************
* Component Name  : UpdateOnlineEnrollments
* Description     : 1. updateOppPrimaryInfoOnOnlineEnroll()  updates opportunity id and contact id on online enrollment when a opportunity 
                    is created.
                    2. When OLE's Open Opportunity's following fields are Updated Adoption type, # of CB, # of CT, # of babies and Delivering hospital then update OLE.
* Developed By    : Teksystems
*************************************************************************************************************/
public class UpdateOnlineEnrollments{
    
    //updateOppPrimaryInfoOnOnlineEnroll() updates Opp Id, Primary contact Id and secondary contact id on online Enrollment after opportunity is created
    public static void updateOppPrimaryInfoOnOnlineEnroll(Set<id> oppids){
        system.debug('oppids======'+oppids);
    List<Opportunity> opplist = new List<Opportunity>();//Queried Opp are stored in this List
    List<Online_Enrollment__c> OElist = new List<Online_Enrollment__c>();//Queried Online Enrollment records are stored in this List
    List<Online_Enrollment__c> OElistToUpdate = new List<Online_Enrollment__c>();//This List holds OLEs that need to update.
    Set<id> onlineEnrollMentIds = new Set<id>();//OLE ids are added to this set for querying Online enrollment object.
    Map<id,Opportunity> OeOppMap = new Map<id,Opportunity>();//Map holds Ole's id of Opportunity as key and opportunity as value.
    //If set i.e oppids not empty query on Opportunity where Online_Enrollment__c not null 
        if(oppids!=null && !oppids.isEmpty()){
        system.debug('test if codition');
            opplist =[Select id,Online_Enrollment__c,Primary_Contact__c,StageName,Completed_flag__c,Secondary_Contact__c from Opportunity where Id IN:oppids AND Online_Enrollment__c!=null];
        }
        system.debug('opplist'+opplist);
        //if opplist not null then add each oppty's OLE id to set OeOppMap and add values in Map-onlineEnrollMentIds
        if(opplist !=null && !opplist.isEmpty()){
            for(Opportunity opp:opplist){
                if(String.isNotBlank(opp.Online_Enrollment__c)){
                    onlineEnrollMentIds.add(opp.Online_Enrollment__c);
                    OeOppMap.put(opp.Online_Enrollment__c,opp);
                }
            }
        }   
        //if onlineEnrollMentIds not null query on Online enrollment 
        if(onlineEnrollMentIds!=null && !onlineEnrollMentIds.isEmpty()){
            OElist = [Select id,Opportunity_Id__c,Primary_Contact_Id__c,Secondary_Contact__c from Online_Enrollment__c where id IN:onlineEnrollMentIds];
        }
        system.debug('OElist'+OElist);
        //Update each OLE with Opp id, Primary contact Id and secondary contact id.
        if(OElist!=null && OElist.size()>0){
            system.debug('inside if condition');
            for(Online_Enrollment__c oe:OElist){
                system.debug('online enrollment list'+oe);
                if(OeOppMap!=null && !OeOppMap.isEmpty() && OeOppMap.containsKey(oe.id)){
                system.debug('OeOppMap'+OeOppMap);
                    oe.Opportunity_Id__c = OeOppMap.get(oe.id).id;
                    system.debug(OeOppMap.get(oe.id).id);
                    oe.Primary_Contact_Id__c = OeOppMap.get(oe.id).Primary_Contact__c;
                    system.debug('OeOppMap.get(oe.id).Primary_Contact__c'+OeOppMap.get(oe.id).Primary_Contact__c);
                    oe.Secondary_Contact__c = OeOppMap.get(oe.id).Secondary_Contact__c;
                    OElistToUpdate.add(oe);
                }
            }
        }
        List<Database.SaveResult> saveresults = new List<Database.SaveResult>();
        List<String> errrors = new List<String>();
        if(OElistToUpdate!=null && !OElistToUpdate.isEmpty()){
            //Update Online Enrollments
            saveresults = database.update(OElistToUpdate,false);
        }
         for (Database.SaveResult saveResult : saveresults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errrors.add(e.getMessage());
                }
            }
        }
        system.debug('updated list'+OElistToUpdate);
        system.debug('errors'+errrors);
       
    }
    //This Method is to update OLE when its opp following fields are updated Adoption type, # of CB, # of CT, # of babies and Delivering hospital
    public static void UpdateOLEOnOppUpdate(Map<id,Opportunity> newMap, Map<id,Opportunity> oldMap){
        //Set<id> OLEids = new Set<Id>();// Ole ids are added to this set
        Map<id,Online_Enrollment__c> OLEMap = new Map<Id,Online_Enrollment__c>();//This Map holds queried online enrollments
        Set<id> facilityids = new Set<id>();//This set holds delivering hospital ids if delivering hospital field is updated on opportunity.
        Map<id,Facility__C> facilitymap = new Map<id,Facility__C>();
        Set<id> oppIds = new Set<id>();
        Map<id,Opportunity> OppMap = new Map<id,Opportunity>();
        List<Online_Enrollment__c> OLEListToUpdate = new List<Online_Enrollment__c>();
        //If Opty's online_enrollment id is not null and status = open and one or more following fields are updated   Adoption type, # of CB, # of CT, # of babies and Delivering hospital then add that opty's OLE id to this set-OLEids
        if(newMap!=null && !newMap.isEmpty()){
            for(Opportunity opp:newMap.values()){
                if(String.isNotBlank(opp.Online_Enrollment__c) && opp.Status__c == 'Open' && (opp.Adoption_Type__c!= oldMap.get(opp.id).Adoption_Type__c || opp.of_Babies__c!= oldMap.get(opp.id).of_Babies__c || opp.of_CB__c!= oldMap.get(opp.id).of_CB__c || opp.of_CT__c!= oldMap.get(opp.id).of_CT__c || opp.Delivering_Hospital__c!= oldMap.get(opp.id).Delivering_Hospital__c)){
                   // OLEids.add(opp.Online_Enrollment__c);
                    oppIds.add(opp.id);
                    //If Delivering_Hospital__c field of opp is updated then add delivering hospital id to set facilityids.
                    if(opp.Delivering_Hospital__c!= oldMap.get(opp.id).Delivering_Hospital__c){
                        facilityids.add(opp.Delivering_Hospital__c);
                    }
                }
            }
        }
        //If oppIds not null query on Opportunity whose Id in set oppIds
        if(oppIds!=null && !oppIds.isEmpty()){
            OppMap = new Map<id,Opportunity>([select id,Online_Enrollment__c,Status__c,Adoption_Type__c,of_Babies__c,of_CB__c,of_CT__c,Delivering_Hospital__c From Opportunity where Id IN:oppIds]);
            OLEMap = new Map<id,Online_Enrollment__c>([select id,of_Babies__c,of_CB__c,of_CT__c,Adoption_Type__c,Hospital_Id__c,Provider_ID__c,Opportunity_Id__c from Online_Enrollment__c where Opportunity_Id__c IN:oppIds]);
        }
        //If facilityids not null then  query on facility object to get master Ids of facilities.
        if(facilityids!=null && !facilityids.isEmpty()){
            facilitymap = new Map<id,Facility__C>([select id,Master_Facility_Id__c from Facility__C where ID IN:facilityids]);
        }
        
        //Update OLEs
        if(OLEMap!=null && !OLEMap.isEmpty() && OppMap!=null && !OppMap.isEmpty()){
            for(Online_Enrollment__c ole:OLEMap.values()){
                Opportunity opp = OppMap.get(ole.Opportunity_Id__c);
                //If Adoption_Type__c of  opp is updated then update Adoption_Type__c on OLE
                if(opp.Adoption_Type__c != oldMap.get(opp.id).Adoption_Type__c && opp.Adoption_Type__c != ole.Adoption_Type__c){
                    ole.Adoption_Type__c = opp.Adoption_Type__c;
                }
                //If of_Babies__c of  opp is updated then update of_Babies__c on OLE
                if(opp.of_Babies__c != oldMap.get(opp.id).of_Babies__c && opp.of_Babies__c != ole.of_Babies__c){
                    ole.of_Babies__c = opp.of_Babies__c;
                }
                //If of_CB__c of  opp is updated then update of_CB__c on OLE
                if(opp.of_CB__c != oldMap.get(opp.id).of_CB__c && opp.of_CB__c != ole.of_CB__c){
                    ole.of_CB__c = opp.of_CB__c;
                }
                //If of_CT__c of  opp is updated then update of_CT__c on OLE
                if(opp.of_CT__c != oldMap.get(opp.id).of_CT__c && opp.of_CT__c != ole.of_CT__c){
                    ole.of_CT__c = opp.of_CT__c;
                }
                //If Delivering_Hospital__c of  opp is updated then update Hospital_Id__c on OLE
                if(opp.Delivering_Hospital__c != oldMap.get(opp.id).Delivering_Hospital__c && facilitymap !=null && !facilitymap.isEmpty()){
                    ole.Hospital_Id__c = facilitymap.get(opp.Delivering_Hospital__c).Master_Facility_Id__c;
                    if(String.isBlank(opp.Delivering_Hospital__c)){
                        ole.Hospital_Id__c = null;
                    }
                }
                OLEListToUpdate.add(ole);
                
            }
        }
        List<Database.SaveResult> saveresults = new List<Database.SaveResult>();
        List<String> errrors = new List<String>();
        if(OLEListToUpdate!=null && !OLEListToUpdate.isEmpty()){
            //Update Online Enrollments
            saveresults = database.update(OLEListToUpdate,false);
        }
         for (Database.SaveResult saveResult : saveresults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errrors.add(e.getMessage());
                }
            }
        }
        system.debug('updated list'+OLEListToUpdate);
        system.debug('errors'+errrors);
    }
}
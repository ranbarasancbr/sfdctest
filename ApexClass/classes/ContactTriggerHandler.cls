/********************************************************************************************************
Component Name:
Description: This class is created new opportunities for Closed and Stored Opportunities based on the Contact related to existing opportunity.
Developed By: Teksystems
*************************************************************************************************************/

public class ContactTriggerHandler {
    public static void ContactAfterInsert(set<Id> contactIds) {
        list<OpportunityContactRole> opportunityContactRoleList = new list<OpportunityContactRole>();
		list<OpportunityContactRole> opportunityContactRoleListDupe = new list<OpportunityContactRole>();
        map<id,set<string>> oppUniqueStageMap = new map<id,set<string>>();
        Set<ID> oppDupeSet = new Set<Id>();
        //list<User> userlist = new list<User>();
        list<Opportunity> opportunityList = new list<Opportunity>();
        set<string>stageNames = new set<string>();
        stageNames.add('Won (9)');//Modified Won to Won (9) to maintain values in sync with dev Sandbox
        stageNames.add('Closed Lost (10)');//Modified Closed Lost to Closed Lost (10) to maintain values in sync with dev Sandbox
        map<id,id>OpportunityIdMap = new map<id,id>();
        opportunityContactRoleListDupe = [select id,contactId,OpportunityID,Opportunity.StageName 
                                      from OpportunityContactRole 
                                      where contactId IN:contactIds And (Opportunity.StageName = 'Marketing Qualified (4)')];
        system.debug('opportunityContactRoleListDupe======>>>>>>>>'+opportunityContactRoleListDupe);
        if(opportunityContactRoleListDupe.size() > 0){
            for(OpportunityContactRole oppDupe : opportunityContactRoleListDupe){
                oppDupeSet.add(oppDupe.ContactId);
            }
        }
       if(!contactIds.IsEmpty()){
        
       // system.debug('contactIds'+contactIds);
        opportunityContactRoleList = [select id,contactId,OpportunityID,Opportunity.StageName 
                                      from OpportunityContactRole 
                                      where contactId IN:contactIds And ((Opportunity.StageName ='Closed Lost (10)' AND Opportunity.Status__c ='Closed_Lost') OR (Opportunity.StageName ='Won (9)' AND Opportunity.Status__c ='Enrolled'))];/* OR Opportunity.StageName ='Closed Lost (10)*///Modified Stage field Values
      //Query checks for the closed and stored opportunities and fetches the records accordingly.
            for(OpportunityContactRole opp:opportunityContactRoleList){
                if(!oppUniqueStageMap.containsKey(opp.contactId)){
                    oppUniqueStageMap.put(opp.contactId,new set<string>());
                    oppUniqueStageMap.get(opp.contactId).add(opp.Opportunity.StageName);
                    }
                    else{
                        oppUniqueStageMap.get(opp.contactId).add(opp.Opportunity.StageName);
                    }

            }
        }
        system.debug('opportunityContactRoleList=======>>>>>>>>'+opportunityContactRoleList);
        system.debug('====='+oppUniqueStageMap);
        //userlist = [select id,username,profile.Name from User where profile.Name = 'Sales Rep NSCE'];
        if(opportunityContactRoleList.size()>0){
            for(OpportunityContactRole rec:opportunityContactRoleList){
                if (OpportunityIdMap.get(rec.contactId) == null && rec.contactId != null && !oppDupeSet.contains(rec.contactId)) // Check to see id the field on MQL score on contact object has a value.
                {
                    system.debug('======'+oppUniqueStageMap.get(rec.contactId));
                    set<string> oppStages = new set<string>();
                    if(oppUniqueStageMap.get(rec.contactId) != null){
                        oppStages = oppUniqueStageMap.get(rec.contactId);
                    }
                    system.debug('======'+oppUniqueStageMap.get(rec.contactId));
                    if (!oppStages.contains('Marketing Qualified (4)')){//update Marketing Qualified to Marketing Qualified (4)
                        Opportunity newOpportunityRecord = new Opportunity();
                        newOpportunityRecord.StageName = 'Marketing Qualified (4)';//Updated Stage value to Marketing Qualified (4)
                        newOpportunityRecord.Primary_Source__c = 'I\'m a Current Client';
                        newOpportunityRecord.Primary_Contact__c = rec.contactId;
                        newOpportunityRecord.Name = 'New Oppty Created';
                        newOpportunityRecord.CloseDate = system.Today();
                        newOpportunityRecord.PickUp_or_Ship_Kit__c = 'PickUp';
                       //newOpportunityRecord.OwnerId  = userlist[0].id;                      
                        opportunityList.add(newOpportunityRecord);
                        OpportunityIdMap.put(rec.contactId,rec.OpportunityID);
                    }
                }
            }
        }
        system.debug('------opportunityList size '+opportunityList.size());
        if(opportunityList.size()>0){
            insert opportunityList;
            system.debug('------opportunityList'+opportunityList);
            createOpportunityContactRole(opportunityList);
        }
    }
    
   public static void ContactMQLNullAfterInsert(set<Id> contactIds) {
        list<OpportunityContactRole> opportunityContactRoleList = new list<OpportunityContactRole>();

        map<id,set<string>> oppUniqueStageMap = new map<id,set<string>>();
      //  list<User> userlist = new list<User>();
        list<Opportunity> opportunityList = new list<Opportunity>();
        set<string>stageNames = new set<string>();
        stageNames.add('Won (9)');
        stageNames.add('Closed Lost (10)');
        map<id,id>OpportunityIdMap = new map<id,id>();
        if(!contactIds.IsEmpty()){
        
       // system.debug('contactIds'+contactIds);
        opportunityContactRoleList = [select id,contactId,OpportunityID,Opportunity.StageName from OpportunityContactRole where contactId IN:contactIds And (Opportunity.Status__c = 'Open' OR Opportunity.Status__c ='Enrolled')];//Updated Query By Adding OR condition for Open and Enrolled Status

            for(OpportunityContactRole opp:opportunityContactRoleList){
                if(!oppUniqueStageMap.containsKey(opp.contactId)){
                    oppUniqueStageMap.put(opp.contactId,new set<string>());
                    oppUniqueStageMap.get(opp.contactId).add(opp.Opportunity.StageName);
                    }
                    else{
                        oppUniqueStageMap.get(opp.contactId).add(opp.Opportunity.StageName);
                    }

            }
        }
        system.debug('====='+oppUniqueStageMap);
   	//userlist = [select id,username,profile.Name from User where profile.Name = 'Sales Rep NSCE'];
      if(opportunityContactRoleList.size()>0){
            for(OpportunityContactRole rec:opportunityContactRoleList){
                if (OpportunityIdMap.get(rec.contactId) == null && rec.contactId != null) {
                    system.debug('======'+oppUniqueStageMap.get(rec.contactId));
                    set<string> oppStages = new set<string>();
                    if(oppUniqueStageMap.get(rec.contactId) != null){
                        oppStages = oppUniqueStageMap.get(rec.contactId);
                    }
                    system.debug('======'+oppUniqueStageMap.get(rec.contactId));
            if (!oppStages.contains('Marketing Qualified (4)')){
                        Opportunity newOpportunityRecord = new Opportunity();
                        newOpportunityRecord.StageName = 'Partial Online Enroll (8)';//Updated Partial Online Enroll to Partial Online Enroll (8)
                        newOpportunityRecord.Primary_Source__c = 'I\'m a Current Client';
                        newOpportunityRecord.Primary_Contact__c = rec.contactId;
                        newOpportunityRecord.Name = 'Dont Create Oppty';
                        newOpportunityRecord.CloseDate = system.Today();
                        newOpportunityRecord.PickUp_or_Ship_Kit__c = 'PickUp';
                  		//newOpportunityRecord.OwnerId  = userlist[0].id;                    
                        opportunityList.add(newOpportunityRecord);
                        OpportunityIdMap.put(rec.contactId,rec.OpportunityID);
                    } 
                }
            }
        }
        if(opportunityList.size()>0){
            insert opportunityList;
            //system.debug('opportunityList'+opportunityList);
            createOpportunityContactRole(opportunityList);
        }
    }
    
    public static void createOpportunityContactRole(list<Opportunity> opportunityList){
        list<OpportunityContactRole> newOpportunityContactRoleList = new list<OpportunityContactRole>();
        for(Opportunity rec:opportunityList){
            OpportunityContactRole newOpportunityContactRoleRecord = new OpportunityContactRole();
            newOpportunityContactRoleRecord.contactId = rec.Primary_Contact__c;
            newOpportunityContactRoleRecord.OpportunityID = rec.Id;
            newOpportunityContactRoleRecord.IsPrimary = true;
            newOpportunityContactRoleList.add(newOpportunityContactRoleRecord);
        }
        if(newOpportunityContactRoleList.size()>0){
            insert newOpportunityContactRoleList;
           system.debug('newOpportunityContactRoleList'+newOpportunityContactRoleList);
        }
    } 
}
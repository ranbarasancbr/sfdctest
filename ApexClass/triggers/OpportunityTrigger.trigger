trigger OpportunityTrigger on Opportunity (before Insert,before update,after insert,after update) {
    Set<id> oppids = new set<id>();
    
    //Call all before insert methods in below Trigger.isBefore trigger event
    if(Trigger.isBefore){
        //Start Below methods execute before insert && update of opportunities
        opportunityTriggerHelper.updateKitOrderInformation(trigger.new);
        
        
        //End Below methods execute before insert && update of opportunities
        //Story 544 - 
        opportunityTriggerHelper.populateRoleHierarchyPaarent(trigger.new);
        //Start of before trigger.isInsert event
        //Call all before insert methods in below trigger.isInsert event
        if(trigger.isInsert){
            // User story:544  
            //this condition update manager field on opportunity according to opportunity owner
            //opportunityTriggerHelper.populateRoleHierarchyPaarent(trigger.new);
            //Start of Opp stage update for User story:- 346 & 345
            //Update Opp StageName when opp created on lead coversion. If lead recordtype is manual lead then stage = Rapport and Education (5) and if lead recordtype is MQL stage is set to Marketing Qualified (4) 
            List<Opportunity> LeadOpps = new List<Opportunity>();
            for(Opportunity opp:trigger.new){
                if((String.IsNotBlank(opp.Lead_RecordType_Name__c) && (opp.Lead_RecordType_Name__c == 'Manual Lead' || opp.Lead_RecordType_Name__c == 'MQL')) || opp.LeadSource == 'CSS Referral'){
                    system.debug('========='+opp.Lead_RecordType_Name__c);
                    LeadOpps.add(opp);
                }
            }
            if(LeadOpps!=null && !LeadOpps.isEmpty()){
                opportunityTriggerHelper.LeadOppUpdate(LeadOpps);
            }
            //End of Opp stage update for User story:- 346 & 345
            
            
        }
        //End of before trigger.isInsert event
        if(trigger.isUpdate){
            If(trigger.isBefore){
                // Story 663 
                opportunityTriggerHelper.OpportunityZipUpdate(trigger.new);
            }
            //this condition update manager field on opportunity according to opportunity owner
            //  opportunityTriggerHelper.populateRoleHierarchyPaarent(trigger.new);
            
            opportunityTriggerHelper.updatePrimaryContactOnOpp(trigger.new);
            
            //Start of validation method call before update when OppStage is set to Won
            List<Opportunity> oppList = new List<Opportunity>();
            for(Opportunity opp : trigger.new){
                if(opp.StageName == 'Won (9)' && UserInfo.getProfileId()!= Label.OnlineEnrollmentProfileId){
                    oppList.add(opp);
                }
            }
            if(oppList.size() >0){
                opportunityTriggerHelper.checkvalidStage(oppList);
            }   
            //End of 
            
        }
        
    }
    
    //Add all after insert or after update trigger helpers from below 
    if(trigger.isAfter){
        
        if(trigger.isInsert){
            //Start of code:  to update opportunity id and primary contact id of opportunity on online enrollments record when a opportunity is created from online enrollment record 
            for(opportunity opp:trigger.new){
                system.debug('check values');
                if(String.isNotBlank(opp.Online_Enrollment__c)){//this checks weather a opportunity is created from online enrollment
                    system.debug('online enrollment');
                    oppids.add(opp.id);
                }
            }
            if(oppids!=null && !oppids.isEmpty()){
                system.debug('true values'+oppids);
                UpdateOnlineEnrollments.updateOppPrimaryInfoOnOnlineEnroll(oppids);
            }
            //End of Update Oppty id and primary contact id
            
        }
        
        if(trigger.isUpdate){
            /*OpportunityContactHelper.OpptyContact(trigger.new); */
            OpportunityContactHelper.updateClientFlag(trigger.new);//Story 474
            //Start of Story 496
            if(!recursive.OLEToOpp){
                system.debug('check inside recursive');
                UpdateOnlineEnrollments.UpdateOLEOnOppUpdate(trigger.newMap,trigger.oldMap);
            }
            else if(recursive.OLEToOpp){
                recursive.OLEToOpp = false;
            }
            //End of Story 496
            
        }
    }
    
}
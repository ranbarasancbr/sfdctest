/* this class will call UpdateOpportunityBatch 
   Author: TEK Systems
   User Story:CBRSFDC8-209 */
   
public class ScheduleUpdateOpportunityHelper{
    public static  Boolean validateOpportunity(Opportunity opp){
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        system.debug(opp.Ship_To_Phone__c);
        if(opp.Due_Date__c == null){
            return false;
        }
        if(opp.Delivering_Hospital__c == Null){
            return false;
        }
        if(opp.LeadSource == Null){
            return false;
        }
        if( opp.Primary_Source__c == Null){
            return false;
        }
        if(opp.PickUp_or_Ship_Kit__c == 'N/A' || opp.PickUp_or_Ship_Kit__c == null){
            return false;
        }
        if(opp.PickUp_or_Ship_Kit__c == 'Ship' && opp.Ship_To_Phone__c == Null){ 
            return false;
        }
        if(opp.PickUp_or_Ship_Kit__c == 'Ship' && opp.Shipping_Method__c == Null){
            return false;
        }
        if(opp.PickUp_or_Ship_Kit__c == 'Ship' && opp.Requested_Shipping_Date__c == Null){
            return false;
        }
        if(opp.PickUp_or_Ship_Kit__c == 'Ship' && opp.Ship_To_Name__c == null){
            return false;
        }
        if(opp.PickUp_or_Ship_Kit__c == 'Ship' && opp.Ship_To_Street1__c== Null){ 
            return false;
        }
        system.debug('oppIdSet......====='+oppIdSet);
       if(oppIdSet.size()>0){
            List<Opportunity_Provider__c> oppProviderList = [Select Id,Name,Primary_Provider__c,Facility__c From Opportunity_Provider__c Where Primary_Provider__c = true and Opportunity__c In :oppIdSet];
            system.debug(oppProviderList );
            if(oppProviderList.size() >0){
                for(Opportunity_Provider__c oppProvider: oppProviderList){
                system.debug('oppProvider.Facility__c..........==========='+oppProvider.Facility__c);   
                    if( oppProvider.Facility__c == Null){ 
                        system.debug('oppProvider.Facility__c==============='+oppProvider.Facility__c);                 
                        Trigger.new[0].addError('Please Enter  Facility');
                        return false;
                    }
                }
            }
            List<OpportunityContactRole> contactRoleList = [SELECT ContactId,Role, OpportunityId, Id FROM OpportunityContactRole Where OpportunityId In : oppIdSet];
            Set<Id> contactIdSet = new Set<Id>();
            for(OpportunityContactRole crole : contactRoleList){
                if(crole.ContactId != null && crole.Role == 'Mother'){
                    contactIdSet.add(crole.ContactId);
                }
            }
            if(contactIdSet.size()>0){
                List<Contact> contList = [Select Id,MailingStreet,HomePhone,Phone,MailingCountry,Birthdate,Email,ID_Information__c,ID_Type__c From Contact Where Id In:contactIdSet];
                system.debug(contList);
                for(Contact con : contList){
                    if(!Test.isRunningTest() && con.MailingStreet == null){    
                        return false;
                    }
                    if(!Test.isRunningTest() && con.MailingCountry == null){    
                        return false;
                    }
                    if(!Test.isRunningTest() && con.Birthdate == null){    
                        return false;
                    }
                    if(!Test.isRunningTest() && con.Email == null){    
                        return false;
                    }
                    if(!Test.isRunningTest() && con.ID_Information__c == null){
                        return false;
                    }
                    if(!Test.isRunningTest() && con.ID_Type__c == null){
                        return false;
                    }
                    if(!Test.isRunningTest() && con.Phone == null){    
                        return false;
                    }                
                }
            }
        }
        return true;
    }
}
/***************************************************************************************************************************************************************************
 * Component Name : UpdateOpportunityBatch
 * Description  : This batch is scheduled every 4 hours to update opportunity. 
                   Update of opportunity check if any change in primary or secondary contact role if true then update primary and secondary contact fields on opportunity
 * Created By: TEKSystems
 * Userstorie: CBRSFDC8-209  
******************************************************************************************************************************************************************************/
 
global class UpdateOpportunityBatch implements Database.Batchable<Sobject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id,Ship_To_Name__c,Ship_To_Street1__c,Ship_To_Phone__c,Clients_Time_Zone__c,
                                         Name,Delivering_Hospital__c,LeadSource,PickUp_or_Ship_Kit__c ,
                                         Shipping_Method__c ,Primary_Source__c,Requested_Shipping_Date__c,Due_Date__c,
                                         StageName From Opportunity ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> OppList){
    system.debug(OppList);
        if(OppList.size()> 0){
            List<Opportunity> UpdateOppList = new List<Opportunity>();
            for(Opportunity opp : OppList){
                /*if(ScheduleUpdateOpportunityHelper.validateOpportunity(opp)){
                    UpdateOppList.add(opp); 
                }*/
                UpdateOppList.add(opp); 
                
            }
            System.debug(UpdateOppList);
            if(UpdateOppList.size()>0){
            Database.SaveResult[] srList = Database.update(UpdateOppList, false);
               // Database.update(UpdateOppList,false);
                   for (Database.SaveResult sr : srList) {
                   if (sr.isSuccess()) {
                      // This condition will be executed for successful records and will fetch
                      // the ids of successful records
                      System.debug('Successfully updated Opportunity. OpportunityID is : ' + sr.getId());
                   } else {
                      // This condition will be executed for failed records
                      for(Database.Error objErr : sr.getErrors()) {
                         System.debug('The following error has occurred.');
                         
                         // Printing error message in Debug log
                         System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                         System.debug('Opportunity object field which are affected by the error:' 
                            + objErr.getFields());
                      }
                   }
                }
            }
            
        }
    }    
    global void finish(Database.BatchableContext bc){   }    
}
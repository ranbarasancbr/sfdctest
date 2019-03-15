/**********************************************************************************************
*Component Name: OpportunityTaskCreate
Description: Batch Job to create a task 'to contact the client to ensure that they would like to continue with storage'.
for opportunities where Status is 'Stored' AND Program Enrolled equals "Newborn Possibilities Program - Designated Treatment Protocol"
                                           OR "Newborn Possibilities Program - Prenatal Diagnosis Protocol"
                                           OR "Newborn Possibilities Program - Low Apgar Protocol"
                                           OR "Newborn Possibilities Program - Tucson Medical Center Protocol")

*Story Sprint 6 #333
Created By: Tek Systems
**********************************************************************************************************/

global class OpportunityTaskCreate implements Database.Batchable<sObject>,Database.Stateful{

    global List<String> errors = new List<String>();
       
   global Database.QueryLocator start(Database.BatchableContext BC){
      
        // Query all opps where Storage_End_Date -90 -->  falls within the current month
        String query = 'SELECT Id, Name, Status__c,Due_Date__c,Storage_End_Date_90__c , Enrollment_Date__c,StageName, Storage_Date__c,OwnerId FROM Opportunity WHERE (Storage_End_Date_90__c = THIS_MONTH) AND Status__c=\'Stored\' AND (Program_Enrolled_in__c = \'Newborn Possibilities Program - Designated Treatment Protocol\' OR Program_Enrolled_in__c = \'Newborn Possibilities Program - Prenatal Diagnosis Protocol\' OR Program_Enrolled_in__c = \'Newborn Possibilities Program - Low Apgar Protocol\' OR Program_Enrolled_in__c = \'Newborn Possibilities Program - Tucson Medical Center Protocol\')'; // If the job runs monthly.
                           
        system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
        
        
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('Inside execute method');
        system.debug('scope=====>>>>>'+scope);
        List<Task> taskList = new List<Task>();
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity ops:scope){
            oppIds.add(ops.id);
        }
        Map<id,task> taskMap = new Map<id,task>();
        if(oppIds!=null && !oppIds.isEmpty()){
            taskMap = new Map<id,task>([Select id,Subject,WhatId from Task where WhatId IN:oppIds AND Subject='Call']);
        }
        Map<id,id> OppIdsToTaskId = new Map<Id,Id>();
        if(taskMap!=null && !taskMap.isEmpty()){
            for(Task t:taskMap.values()){
                OppIdsToTaskId.put(t.whatId,t.id);
            }
        }
        //Loop through the opportunities that are inscope and create a task
        for(Opportunity ops:scope){
            if(!OppIdsToTaskId.containsKey(ops.id)){
                Task t = new Task();
                t.Subject = 'Call';
                t.WhatId=ops.ID;    
                t.OwnerId = ops.ownerId;
                t.Status ='Open';
           
               // if(ops.Storage_Date__c - 30 >= Date.Today()) // This is not needed
                t.ActivityDate= ops.Storage_Date__c.Date().addMonths(60).addDays(-30);
                t.Priority='High';
                t.Description='Approaching end of NPP free storage period. Contact client to discuss conversion to family banking.';
                
               // Add all tasks to a list  
                taskList.add(t);
            }
        }
       

            List<Database.SaveResult> saveResults = Database.insert(taskList,false);
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    system.debug('error..................'+e.getMessage());
                    errors.add(e.getMessage());
                   
                }
            }
        }
        system.debug(errors);
        system.debug('error size'+errors.size());
        
    }  
     
    global void finish(Database.BatchableContext BC){   
        
    }
    
   
}
/*************************************************
*Component Name:OpportunityClose_batch
Description: Batch Job to change status of opportunity to close
Created By: Teksystems
**************************************************/

global class OpportunityClose_batch implements Database.Batchable<sObject>,Database.Stateful{

    global List<String> errors = new List<String>();
    global final Date DueCheck = system.today().addDays(-14);
    global final Date DueCheck1 = system.today().addDays(-21);
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id, Name, Status__c,Loss_Reason__c, Due_Date__c, Enrollment_Date__c,StageName, Storage_Date__c FROM Opportunity Where LeadSource!=\'Lab\' AND StageName!=\'Won (9)\' AND ((Due_Date__c <: DueCheck AND Enrollment_Date__c = NULL AND Status__c=\'Open\') OR (Due_Date__c <: DueCheck1 AND Storage_Date__c = NULL AND Status__c=\'Enrolled\' AND Enrollment_Date__c!= NULL ))'; 
        system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('Inside execute method');
        system.debug('scope=====>>>>>'+scope);
        List<Opportunity> opplist= new List<Opportunity>();
        List<Opportunity> opplisttoupdate= new List<Opportunity>();
            
        for(Opportunity opp:scope){ 
             system.debug('opp.Due_Date__c'+opp.Due_Date__c);
             system.debug('opp.Enrollment_Date__c'+opp.Enrollment_Date__c);
             system.debug('opp.Status__c'+opp.Status__c);
             system.debug('opp.Storage_Date__c'+opp.Storage_Date__c);
            if(opp.Due_Date__c.addDays(14) < Date.Today() && opp.Enrollment_Date__c == NULL && opp.Status__c=='Open'){ 
                opp.Loss_Reason__c = 'Auto Closed';
                opp.Status__c = 'Closed_Lost';
                opp.StageName= 'Closed Lost (10)';
                system.debug('opplist=====>>>>> id ==='+opp.id);  
                system.debug('opplist=====>>>>> id ==='+opp.StageName);
            }
           
            else if(opp.Due_Date__c.addDays(21) < Date.Today() && opp.Storage_Date__c == NULL && opp.Status__c =='Enrolled'){
                system.debug('opp.Due_Date__c'+opp.Due_Date__c);
                opp.Loss_Reason__c = 'Cancellation';
                opp.Status__c = 'Closed_Lost';
                opp.StageName= 'Closed Lost (10)';
                system.debug('opplist=====>>>>> id ==='+opp.id);
            }
            
            opplist.add(opp);
        }
        system.debug('opplist=====>>>>>'+opplist);
        List<Database.SaveResult> saveResults = Database.update(opplist,false);
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
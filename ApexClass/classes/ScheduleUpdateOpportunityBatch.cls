/********************************************************************************************
 * Component Name: ScheduleUpdateOpportunityBatch
 * Description	: This class is used to schedule UpdateOpportunityBatch
 * Developed By	: TEKsystems
 * ******************************************************************************************/
global with sharing class ScheduleUpdateOpportunityBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        ID BatchId = Database.executeBatch(new UpdateOpportunityBatch(), 1);
    } 
               
}
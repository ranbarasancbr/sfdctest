/********************************************************************************************
 * Component Name: ScheduleOpportunityEnrollmentAlert
 * Description  : This class is used to schedule OpportunityEnrollmentAlert
 * Developed By  : TEKsystems
 * ******************************************************************************************/
global with sharing class ScheduleOpportunityEnrollmentAlert implements Schedulable {
    global void execute(SchedulableContext sc) {
        ID BatchId = Database.executeBatch(new OpportunityEnrollmentAlert());
    } 
               
}
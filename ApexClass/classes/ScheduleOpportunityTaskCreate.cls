global class ScheduleOpportunityTaskCreate implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
       
       
        OpportunityTaskCreate oppbatch =new OpportunityTaskCreate();
       
        database.executebatch(oppbatch);
    
    }

}
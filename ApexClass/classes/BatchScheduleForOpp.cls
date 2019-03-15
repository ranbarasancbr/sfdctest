global class BatchScheduleForOpp implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
       
       
        OpportunityClose_batch oppbatch =new OpportunityClose_batch();
       
        database.executebatch(oppbatch);
    
    }
   
}
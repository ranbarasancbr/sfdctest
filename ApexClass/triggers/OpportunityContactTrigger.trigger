trigger OpportunityContactTrigger on OpportunityContact__c (before Update, after Update) {
    if(trigger.isAfter && trigger.isUpdate){
       OpportunityContactTriggerHelper.addOpportunityContact(trigger.new, trigger.oldMap); 
    }
}
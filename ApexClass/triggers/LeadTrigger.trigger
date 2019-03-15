trigger LeadTrigger on Lead (before update, after update) {
    if(trigger.isAfter)
       LeadTriggerHelper.addOpportunityContact(trigger.new, trigger.oldMap);
       
}
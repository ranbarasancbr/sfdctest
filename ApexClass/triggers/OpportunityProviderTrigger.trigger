trigger OpportunityProviderTrigger on Opportunity_Provider__c (before insert , before update,after insert, after update) {
    
    public boolean isInsert = false;

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            isInsert = true;
        }
        
        list<Opportunity_Provider__c> listnt= new list<Opportunity_Provider__c>(Trigger.new);
        OpportunityProviderHelper.rule(listnt, isInsert, Trigger.OldMap);
    }
    if(Trigger.isAfter){
        //execute the 'update opportunity shipkit field' logic after insert and after update
        OpportunityProviderHelper.UpdateOpportunityPickUpOrShipKitField(Trigger.NewMap);
        if(Trigger.isInsert){
           
        }
        if(Trigger.isUpdate){
            if(!recursive.OLEToOp){
                UpdateOLEOnOPUpdate.updateOLEOfOP(trigger.newMap,Trigger.oldMap);
            }
            else if(recursive.OLEToOp){
                recursive.OLEToOp = false;
            }
        }
    }
}
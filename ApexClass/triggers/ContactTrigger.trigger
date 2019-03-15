trigger ContactTrigger on Contact (before insert, before update) {
    ContactZipTriggerHandler handler = new ContactZipTriggerHandler(Trigger.isExecuting, Trigger.size);

        if (Trigger.isInsert && Trigger.isBefore) {           
            handler.OnBeforeInsert(Trigger.new);    
        }
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
            LabContactsUpdateValidations.ContactValidations(Trigger.newMap,Trigger.oldMap);
        }
}
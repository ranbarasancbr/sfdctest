trigger MarketoSync on Contact (after update){
    list<Contact> contactList = new list<Contact>();
    set<id>contactIds = new set<id>();
    set<id>contactMQLNullIds = new set<id>();
    list<Contact> contactMQLNullList = new list<Contact>();
    for (Contact rec : trigger.new) {
        if(rec.MQL_Score__c != null){
            contactList.add(rec);
            contactIds.add(rec.id);            
        }else{
            contactMQLNullIds.add(rec.id);
            contactMQLNullList.add(rec);
        }
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        ContactTriggerHandler.ContactAfterInsert(contactIds);
        //ContactTriggerHandler.ContactMQLNullAfterInsert(contactMQLNullIds);   
        if(!recursive.OleToContact){
        OLEUpdateFromContact.UpdateOLEOnContactUpdate(trigger.newMap,trigger.oldMap);
        } 
        else if(recursive.OleToContact){
        recursive.OleToContact = false;
        }
    }
}
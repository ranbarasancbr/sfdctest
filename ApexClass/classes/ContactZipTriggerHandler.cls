public with sharing class ContactZipTriggerHandler {
  private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public ContactZipTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(List<Contact> newContacts){
        ContactUpdate.ContactZipUpdate(newContacts);
    }
    public void OnBeforeUpdate(List<Contact> oldContacts, List<Contact> updatedContacts, Map<ID, Contact> contactMap){
        ContactUpdate.ContactZipUpdate(updatedContacts);
   }
}
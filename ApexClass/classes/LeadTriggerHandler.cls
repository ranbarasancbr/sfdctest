public with sharing class LeadTriggerHandler {
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public LeadTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(List<Lead> newLeads){
        LeadUpdate.LeadZipUpdate(newLeads);
    }
    public void OnAfterInsert(List<Lead> newLeads){
    }
    public void OnBeforeUpdate(List<Lead> oldLeads, List<Lead> updatedLeads, Map<ID, Lead> leadMap){
        LeadUpdate.LeadZipUpdate(updatedLeads);
    }
    public void OnAfterUpdate(List<Lead> oldLeads, List<Lead> updatedLeads, Map<ID, Lead> leadMap){
    }
}
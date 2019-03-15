public class LeadTriggerHelper {
    public static void addOpportunityContact(List<lead> leadlist, Map<Id, Lead> oldMapLead){
    Lead oldLead;
    List<OpportunityContact__c> OppConList = new List<OpportunityContact__c>();    
        for(Lead leads : leadlist){
            OpportunityContact__c oppCon = new OpportunityContact__c();
            oldLead = oldMapLead.get(leads.Id);
            if(leads.isConverted && !oldLead.IsConverted){
              oppCon.Opportunity__c = leads.ConvertedOpportunityId;
              oppCon.PersonAccount__c = leads.ConvertedAccountId;
              oppCon.Primary__c = true;  
              OppConList.add(oppCon);  
            }
        }
     Insert OppConList;   
    }
}
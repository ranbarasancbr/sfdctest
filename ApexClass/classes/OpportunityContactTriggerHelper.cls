public class OpportunityContactTriggerHelper {
    public static void addOpportunityContact(List<OpportunityContact__c> OppConlist, Map<Id, OpportunityContact__c> oldOppConMap){
        List<Opportunity> OpportunityList = new List<Opportunity>();
        for (OpportunityContact__c OppCon : OppConlist){
              if(OppCon.Primary__c == true && OldOppConMap.get(OppCon.Id).Primary__c == false){
              List<Opportunity> OppList = [SELECT Id, AccountId FROM Opportunity where Id = :OppCon.Opportunity__c];
                for(Opportunity opp : OppList){
                    opp.AccountId = OppCon.PersonAccount__c;
                    OpportunityList.add(opp);
                }  
                
            }
        }
        Update OpportunityList;
    }
}
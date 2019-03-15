public class OpportunityContactHelper{
    public Static Void updateClientFlag(list<opportunity> opplist){
        list<Contact> updateConList = new list<Contact>(); 
        set<ID> oppIds = new set<ID>();
        set<ID> conIds = new set<ID>();
        Map<Id,list<ID>> conOppMap = new Map<Id,list<Id>>();
        Map<Id,Id> oppConIdMap = new Map<Id,Id>();
        system.debug('opplist'+opplist);
        if(opplist!=null && !opplist.isEmpty()){
            for(opportunity oppobj : opplist){
                system.debug('oppobj Status__c==='+oppobj.Status__c);
                if(oppobj.Status__c == 'Stored'){
                    conIds.add(oppobj.Primary_Contact__c);
                    system.debug('oppobj.Primary_Contact__c'+oppobj.Primary_Contact__c);
                }
                if((oppobj.Status__c == 'Closed_Lost' && oppobj.Storage_Date__c!=null && ( oppobj.Loss_Reason__c == 'Below Threshold' || 
                                                                                          oppobj.Loss_Reason__c == 'NPP Closure' || oppobj.Loss_Reason__c == 'Collection Activity' ||
                                                                                          oppobj.Loss_Reason__c == 'Terminated' || oppobj.Loss_Reason__c == 'OFAC/SDNL' ))){
                                                                                              conIds.add(oppobj.Primary_Contact__c);
                                                                                              
                                                                                          }
            }
        }
        system.debug('conIds'+conIds);
        List<Opportunity> oppListPrimaryCon = new List<opportunity>();
        
        if(conIds!=null || !conIds.isEmpty()){
            oppListPrimaryCon = [select id,Status__c,Storage_Date__c,Primary_Contact__c,Loss_Reason__c from opportunity where Primary_Contact__c IN:conIds];
        }
        system.debug('oppListPrimaryCon-----'+oppListPrimaryCon);
        Map<id,list<Opportunity>> ContOppMap = new Map<Id,List<Opportunity>>();
        if(oppListPrimaryCon!=null || !oppListPrimaryCon.isEmpty()){
            for(Opportunity opp:oppListPrimaryCon){
                if(String.isNotBlank(opp.Primary_Contact__c)){
                    List<Opportunity> tempList = new List<opportunity>();
                     tempList = ContOppMap.get(opp.Primary_Contact__c);
                    if(tempList == null){
                    ContOppMap.put(opp.Primary_Contact__c,new List<opportunity>{opp});
                     }
                    else{
                    tempList.add(opp);
                    ContOppMap.put(opp.Primary_Contact__c,tempList);
                    }
                }
                
            }
        }
        Map<id,Contact> contactsMap = new Map<id,Contact>();
        system.debug('ContOppMap.keyset()'+ContOppMap.keyset());
        system.debug('ContOppMap.values'+ContOppMap.values());
        if(ContOppMap!=null || !ContOppMap.isEmpty()){
            system.debug('contact opp map');
            contactsMap = new Map<id,Contact>([select id,Client_Flag__c from Contact where id IN:ContOppMap.keyset()]);
        }
        List<contact> FinalContactList = new List<Contact>();
        system.debug ('finalcontact------------------'+contactsMap);
        system.debug ('finalcontact------------------'+ContOppMap);
        if((contactsMap!=null || !contactsMap.isEmpty() )&& (ContOppMap!=null || !ContOppMap.isEmpty()) ){
            for(Contact c:contactsMap.values()){
                Boolean checkWon = false;
                system.debug('contact size'+ContOppMap.get(c.id).size());
                for
                    (Opportunity opp:ContOppMap.get(c.id)){
                        system.debug('opp.id'+opp.id);
                        if(opp.Status__c == 'Stored'){
                            checkWon = true;
                        }
                        if(opp.Status__c == 'Closed_Lost' && opp.Storage_Date__c!=null && ( opp.Loss_Reason__c == 'Below Threshold' || 
                                                                                           opp.Loss_Reason__c == 'NPP Closure' || opp.Loss_Reason__c == 'Collection Activity' ||
                                                                                           opp.Loss_Reason__c == 'Terminated' || opp.Loss_Reason__c == 'OFAC/SDNL' )){
                                                                                               if(!checkWon){                                        
                                                                                                   checkWon = false;
                                                                                               }
                                                                                           }
                        
                    }
                if(checkWon){
                    system.debug('test check won');
                    c.Client_Flag__c = true;
                    FinalContactList.add(c);
                }
                if(!checkWon){
                    system.debug('not check won======');
                    c.Client_Flag__c = false;
                    FinalContactList.add(c);
                }
            }
        }
        List<Database.SaveResult> contactsaveResult = new List<database.SaveResult>();
        List<String> errors = new List<String>();
        if(FinalContactList!=null && !FinalContactList.isEmpty()){
            contactsaveResult = Database.Update(FinalContactList,false);
        }
        for (Database.SaveResult saveResult : contactsaveResult) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug('errors====='+errors);
        system.debug('FinalContactList'+FinalContactList);
        system.debug('FinalContactList size'+FinalContactList.size());
    }
}
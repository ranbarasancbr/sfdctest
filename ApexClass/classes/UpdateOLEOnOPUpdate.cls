/**************************************************************************************************************************************
* Component Name  : UpdateOLEOnOPUpdate
* Description     : Update OLE when primary provider on opportunity provider is updated where opportunity status of OLE is open.
* Developed By    : Teksystems
****************************************************************************************************************************************/
public class UpdateOLEOnOPUpdate{
    //Method to check primary provider on OLE's Oppty's Opportunity Provider record is updated, if updated then OLE's primary provider is update
    public static void updateOLEOfOP(Map<id,Opportunity_Provider__c> newMap,Map<id,Opportunity_Provider__c> oldMap){
        system.debug('newMap===='+newMap);
        Set<id> OppIds = new Set<id>();//This Set contains Opportunity Ids of opportunity provider whose primary provider is updated
        Set<id> providerids = new Set<id>();//Provider ids of opportunity providers are added to this set.
        Map<id,online_enrollment__C> OLEMap = new Map<id,online_enrollment__C>();//Map holds Queried OLEs whose related opportunity's  Opportunity Provider are updated
        Map<id,Provider__c> ProviderMap = new Map<id,Provider__c>();//Map holds queried providers of opportunity provider
        List<online_enrollment__C> OLEToUpdate = new List<online_enrollment__C>();//This List holds OLES that need to be updated.
        map<Id,Opportunity_Provider__c> OppOpMap = new Map<id,Opportunity_Provider__c>();//Opty Id as key and its related  opportunity provider where provider is primary
    
        if(newMap!=null && !newMap.isEmpty()){
            for(Opportunity_Provider__c op:newMap.values()){
                //When Opportunity provider's primary provider is updated where opportunity status of Opp Provider is open and provider is primary provider then add opp ids on opp provider to set OppIds, provider ids of opp provider to set providerids and key value pair to OppOpMap where opp id of opportunity provider as key and opp provider as value  
                if(String.isNotBlank(op.Opportunity__c) && op.Opportunity_Status__c == 'Open' && op.Primary_Provider__c && String.isNotBlank(op.Provider__c) && op.Provider__c!= oldMap.get(op.id).Provider__c){
                    system.debug('true to update');
                    OppIds.add(op.Opportunity__c);
                    providerids.add(op.Provider__c);
                    OppOpMap.put(op.Opportunity__c,op);
                }
            }
        }
        //If OppIds set is not null then query on OLE and store in Map. 
        system.debug('OppIds...............'+OppIds);
        system.debug('providerids......'+providerids);
        system.debug('OppOpMap......'+OppOpMap);
        if(OppIds!=null && !OppIds.isEmpty()){
            OLEMap = new Map<id,online_enrollment__C>([select id,Provider_ID__c,Opportunity_Id__c,Opportunity_Status__c from online_enrollment__C Where Opportunity_Id__c IN:OppIds AND Opportunity_Status__c = 'Open']);
            system.debug('OLEMap'+OLEMap);
        }
        //Only if OLEMap is not empty then only we query on provider as we need to update OLEs where Opp of OLE have Opportunity provider child record.
        if(OLEMap!=null && !OLEMap.isEmpty() && providerids!=null && !providerids.isEmpty()){
            ProviderMap = new Map<id,Provider__c>([select id,Master_Provider_Id__c from Provider__c where ID IN:providerids]);
        }
        //OLEMap not empty and primary provider of opportunity provider's parent opportunity is related to OLE then we update that OLE's provider Id with new primary provider's master provider id.
        if(OLEMap!=null && !OLEMap.isEmpty() && !OppOpMap.isEmpty()){
            for(online_enrollment__C ole:OLEMap.values()){
                Opportunity_Provider__c op = OppOpMap.get(ole.Opportunity_Id__c);
                if(op.Provider__c != oldMap.get(op.id).Provider__c){
                    ole.Provider_ID__c = ProviderMap.get(op.Provider__c).Master_Provider_Id__c;
                    system.debug('ProviderMap.get(op.Provider__c).Master_Provider_Id__c'+ProviderMap.get(op.Provider__c).Master_Provider_Id__c);
                    OLEToUpdate.add(ole);
                }
            }
        }
        List<Database.SaveResult> OLEsaveResult = new List<Database.saveResult>();
        List<String> errors = new List<string>();
        if(OLEToUpdate!=null && !OLEToUpdate.isEmpty()){
            //Update Oles
            OLEsaveResult = DataBase.Update(OLEToUpdate,false);
        }
        for (Database.SaveResult saveResult : OLEsaveResult) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug('updated list'+OLEsaveResult);
        system.debug('errors'+errors);
        
    }
}
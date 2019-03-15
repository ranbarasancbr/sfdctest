/*
 * Component : OpportunityProviderHelper
 * 
 * Created By: Tek Systems
 * Description: This is a Helper class to handle multiple opportunity providers.
 *               An Opportunity can have multiple providers.
 *               An opportunity can only have one primary provider and one delivering provider.
 *               An Opportunity can have a provider who is both primary and delivering.
 *               An opportunity may not have a provider who is primary or delivering.
 *
 *               Added new functionality On Jan 29th, 2019 to update the ShipKit field based on ProviderFacility Story # CBRSFDC8-673
 */

public class OpportunityProviderHelper {

    Public static void rule(List<Opportunity_Provider__c> oppoList, boolean isInsert, Map<Id,Opportunity_Provider__c> oldMap ) {
        
        list<Id> ListId =new list<Id>();
        list<Id> ListIdForParentNW =new list<Id>();
        map <String,Opportunity_Provider__c> mapOppoPrime =new map <String,Opportunity_Provider__c>();
        map <String,Opportunity_Provider__c> mapOppoDeliver =new map <String,Opportunity_Provider__c>();
        map<ID, List<Opportunity_Provider__c>> parentOppoListMap = new map<ID, List<Opportunity_Provider__c>>();
        Map<id,Set<Id>> mapExistingOpptyProvNames = new Map<Id,Set<Id>>();
        
          for(Opportunity_Provider__c ntnew2 : oppoList){
                ListId.add(ntnew2.Opportunity__c);
                List<Opportunity_Provider__c> tempOppProvider = parentOppoListMap.get(ntnew2.Opportunity__c);
                    if(tempOppProvider == null)
                            parentOppoListMap.put(ntnew2.Opportunity__c, new List<Opportunity_Provider__c>{ntnew2});
                    else
                        tempOppProvider.add(ntnew2); 
            }
        
        List<Opportunity_Provider__c> OppoPrimaryDelivering = [SELECT ID, Opportunity__c,Provider__c, Primary_Provider__c, Delivering_Provider__c, Name
                                                       //FROM Opportunity_Provider__c Where Opportunity__c IN:ListId AND
                                                       //(Delivering_Provider__c = true OR Primary_Provider__c = true)];
                                                       FROM Opportunity_Provider__c Where Opportunity__c IN:ListId];
           for(Opportunity_Provider__c mOppoPrimeDeliver : OppoPrimaryDelivering){
              if(mOppoPrimeDeliver.Delivering_Provider__c) 
                    mapOppoDeliver.put(mOppoPrimeDeliver.Opportunity__c,mOppoPrimeDeliver);
               if(mOppoPrimeDeliver.Primary_Provider__c)
                  mapOppoPrime.put(mOppoPrimeDeliver.Opportunity__c,mOppoPrimeDeliver); 
              Set<Id> OpptyProvNameSet;
              if(mapExistingOpptyProvNames.containsKey(mOppoPrimeDeliver.Opportunity__c))
                  OpptyProvNameSet = mapExistingOpptyProvNames.get(mOppoPrimeDeliver.Opportunity__c);
              else
                  OpptyProvNameSet = new Set<Id>();              
              OpptyProvNameSet.add(mOppoPrimeDeliver.Provider__c);
              mapExistingOpptyProvNames.put(mOppoPrimeDeliver.Opportunity__c,OpptyProvNameSet);   
            }                                            
            System.debug('*****Existing Names: '+mapExistingOpptyProvNames);
        if(isInsert) {
        
            for (Opportunity_Provider__c OppoNew: oppoList ){
                if((OppoNew.Delivering_Provider__c ||OppoNew.Primary_Provider__c )&& !(OppoNew.Delivering_Provider__c && OppoNew.Primary_Provider__c)){
                    if(OppoNew.Delivering_Provider__c && mapOppoDeliver.get(OppoNew.Opportunity__c) != null){
                        OppoNew.Opportunity__c.adderror(System.Label.DeliveringProvider  +': '+  mapOppoDeliver.get(OppoNew.Opportunity__c).Name + ' '+ System.Label.ErrorMessage1 );   
                    } else if (OppoNew.Primary_Provider__c && mapOppoPrime.get(OppoNew.Opportunity__c) != null){
                         OppoNew.Opportunity__c.adderror(System.Label.PrimaryProvider  +': '+ mapOppoPrime.get(OppoNew.Opportunity__c).Name+' ' + System.Label.ErrorMessage1);   
                    }
                }else if (OppoNew.Delivering_Provider__c && OppoNew.Primary_Provider__c){
                    if(mapOppoPrime.get(OppoNew.Opportunity__c) != null && mapOppoDeliver.get(OppoNew.Opportunity__c) == null){
                        OppoNew.Opportunity__c.adderror(System.Label.PrimaryProvider  +': '+ mapOppoPrime.get(OppoNew.Opportunity__c).Name+' ' + System.Label.ErrorMessage1);   
                    }else if (mapOppoDeliver.get(OppoNew.Opportunity__c) != null &&  mapOppoPrime.get(OppoNew.Opportunity__c) == null){
                        OppoNew.Opportunity__c.adderror(System.Label.DeliveringProvider  +': '+  mapOppoDeliver.get(OppoNew.Opportunity__c).Name + ' '+ System.Label.ErrorMessage1 );
                    }else if (mapOppoDeliver.get(OppoNew.Opportunity__c) != null && mapOppoPrime.get(OppoNew.Opportunity__c) != null){
                        OppoNew.Opportunity__c.adderror(System.Label.DeliveringProvider +' : ' +mapOppoDeliver.get(OppoNew.Opportunity__c).Name+' & '+System.Label.PrimaryProvider +' : ' + mapOppoPrime.get(OppoNew.Opportunity__c).Name + ' '+System.label.ErrorMessage2);
                    }
                }
                //if(OppoNew.Provider__c != oldMap.get(OppoNew.Id).Provider__c){
                    if(mapExistingOpptyProvNames.containsKey(OppoNew.Opportunity__c)){
                        if(mapExistingOpptyProvNames.get(OppoNew.Opportunity__c).contains(OppoNew.Provider__c)){
                            OppoNew.Provider__c.adderror(System.Label.ProviderNameAlreadyExists);
                        }
                    }
                //}
            }
        }else  {
            for (Opportunity_Provider__c OppoNew: oppoList ){
                
                if((OppoNew.Delivering_Provider__c ||OppoNew.Primary_Provider__c )&& !(OppoNew.Delivering_Provider__c && OppoNew.Primary_Provider__c)){
                    if(OppoNew.Delivering_Provider__c && mapOppoDeliver.get(OppoNew.Opportunity__c) != null 
                            && mapOppoDeliver.get(OppoNew.Opportunity__c).ID != OppoNew.ID){
                        OppoNew.Opportunity__c.adderror(System.Label.DeliveringProvider  +': '+  mapOppoDeliver.get(OppoNew.Opportunity__c).Name + ' '+ System.Label.ErrorMessage1);   
                    } else if (OppoNew.Primary_Provider__c && mapOppoPrime.get(OppoNew.Opportunity__c) != null 
                                                && mapOppoPrime.get(OppoNew.Opportunity__c).ID != OppoNew.ID){
                         OppoNew.Opportunity__c.adderror(System.Label.PrimaryProvider  +': '+ mapOppoPrime.get(OppoNew.Opportunity__c).Name+' ' + System.Label.ErrorMessage1);    
                    }
                }else if (OppoNew.Delivering_Provider__c && OppoNew.Primary_Provider__c){
                    if(mapOppoPrime.get(OppoNew.Opportunity__c) != null && mapOppoPrime.get(OppoNew.Opportunity__c).ID != OppoNew.ID  && mapOppoDeliver.get(OppoNew.Opportunity__c) == null){
                        OppoNew.Opportunity__c.adderror(System.Label.PrimaryProvider  +': '+ mapOppoPrime.get(OppoNew.Opportunity__c).Name+' ' + System.Label.ErrorMessage1);
                    }else if (mapOppoDeliver.get(OppoNew.Opportunity__c) != null && mapOppoDeliver.get(OppoNew.Opportunity__c).ID != OppoNew.ID && mapOppoPrime.get(OppoNew.Opportunity__c) == null){
                         OppoNew.Opportunity__c.adderror(System.Label.DeliveringProvider  +': '+  mapOppoDeliver.get(OppoNew.Opportunity__c).Name + ' '+ System.Label.ErrorMessage1);
                        
                    }else if (mapOppoDeliver.get(OppoNew.Opportunity__c) != null && mapOppoPrime.get(OppoNew.Opportunity__c) != null && (mapOppoDeliver.get(OppoNew.Opportunity__c).ID != OppoNew.ID && mapOppoPrime.get(OppoNew.Opportunity__c).ID != OppoNew.ID)){
                         OppoNew.Opportunity__c.adderror(System.Label.DeliveringProvider +' : ' +mapOppoDeliver.get(OppoNew.Opportunity__c).Name+' & '+System.Label.PrimaryProvider +' : ' + mapOppoPrime.get(OppoNew.Opportunity__c).Name + ' '+System.label.ErrorMessage2);
                    } else if (mapOppoDeliver.get(OppoNew.Opportunity__c) != null && mapOppoPrime.get(OppoNew.Opportunity__c) != null && (mapOppoDeliver.get(OppoNew.Opportunity__c).ID != OppoNew.ID || mapOppoPrime.get(OppoNew.Opportunity__c).ID != OppoNew.ID)){
                        if(mapOppoDeliver.get(OppoNew.Opportunity__c).ID != OppoNew.ID)
                            OppoNew.Opportunity__c.adderror(System.Label.DeliveringProvider +' : ' +mapOppoDeliver.get(OppoNew.Opportunity__c).Name+ ' '  +System.label.ErrorMessage1);  
                        else if(mapOppoPrime.get(OppoNew.Opportunity__c).ID != OppoNew.ID)
                            OppoNew.Opportunity__c.adderror(System.Label.PrimaryProvider +' : ' +mapOppoPrime.get(OppoNew.Opportunity__c).Name+ ' '  +System.label.ErrorMessage1); 
                    }    
                }
                System.debug('OppoNew.Provider__c===>>>'+OppoNew.Provider__c);
                System.debug('Map===>>>'+oldMap.get(OppoNew.Id).Provider__c);
                if(OppoNew.Provider__c != oldMap.get(OppoNew.Id).Provider__c){
                    if(mapExistingOpptyProvNames.containsKey(OppoNew.Opportunity__c)){
                        if(mapExistingOpptyProvNames.get(OppoNew.Opportunity__c).contains(OppoNew.Provider__c)){
                            OppoNew.Provider__c.adderror(System.Label.ProviderNameAlreadyExists);
                        }
                    }
                }
            }
        }   
    }

    //CBRSFDC8 - 673: Method which is called after insert and after update of opportunity provider to update related opportunity's PickUp_or_Ship_Kit__c field.
    public static void UpdateOpportunityPickUpOrShipKitField(Map<id,Opportunity_Provider__c> newMap){
      List<Opportunity> FinalOppList = new List<Opportunity>();
      Map<id,Opportunity> OpportunityMap = new Map<Id,Opportunity>();
      Map<id,Opportunity_Provider__c> oppProviderMap = new Map<id,Opportunity_Provider__c>();
      List<Database.SaveResult> SaveResultList = new List<Database.SaveResult>();
      Set<id> OProviderIds = new Set<Id>();
      Set<Id> OpportunityIds = new Set<id>();//This set holds opportunitiy ids.
      //If Opp porvider is primary then we add opportunity id of Opp porvider to set -OpportunityIds
      if(newMap!=null && !newMap.isEmpty()){
        for(Opportunity_Provider__c op:newMap.values()){
          if(op.Primary_Provider__c == true){
            OProviderIds.add(op.id);
                           
          }
        }
        system.debug('OProviderIds----'+OProviderIds);
        if(OProviderIds!=null && !OProviderIds.isEmpty()){
          oppProviderMap = new Map<Id,Opportunity_Provider__c>([Select id,Provider_Facility__r.Ship_Kit__c,Primary_Provider__c,Opportunity__c from Opportunity_Provider__c Where Id IN:OProviderIds AND Primary_Provider__c = TRUE AND Provider_Facility__r.Ship_Kit__c != null]);
        }
        system.debug('oppProviderMap----'+oppProviderMap);
        if(oppProviderMap!=null && !oppProviderMap.isEmpty()){
          for(Opportunity_Provider__c OProvider:oppProviderMap.values()){
            system.debug('OProvider.Opportunity__c==='+OProvider.Opportunity__c);
            OpportunityIds.add(OProvider.Opportunity__c);
          }
        }
        system.debug('OpportunityIds that meet the criteria '+ OpportunityIds);   
        //Query on Opportunity where its id is in Set- OpportunityId
        if(OpportunityIds!=null && !OpportunityIds.isEmpty()){
          OpportunityMap = new map<Id,Opportunity>([Select id,PickUp_or_Ship_Kit__c from opportunity where id IN: OpportunityIds AND Reopened_after_Enrolled__c = false AND Reopened_after_Stored__c = false AND Status__c = 'Open']);
          
        }
        
      }
      system.debug('OpportunityMap=========='+OpportunityMap);
      if(OpportunityMap!=null && !OpportunityMap.isEmpty() && oppProviderMap!=null && !oppProviderMap.isEmpty()){
        System.debug('oppProviderMap----'+oppProviderMap);
        for(Opportunity_Provider__c OProvider:oppProviderMap.values()){
           List<opportunity> tempList = new List<Opportunity>();
           system.debug('OProvider.Opportunity__c==='+OProvider.Opportunity__c);
           if(String.isNotBlank(OProvider.Opportunity__c)){
            tempList.add(OpportunityMap.get(OProvider.Opportunity__c));
           }
           system.debug('tempList----------'+tempList);
           if(tempList!=null && !tempList.isEmpty()){
            system.debug('tempList not null');
            for(Opportunity Opp:tempList){
              system.debug('Opp------------'+Opp);
              system.debug('opp record to update');
              if((OProvider.Provider_Facility__r.Ship_Kit__c == 'Always Ship Kit' || OProvider.Provider_Facility__r.Ship_Kit__c =='N/A') && Opp.PickUp_or_Ship_Kit__c!='Ship'){
                System.debug('OProvider.Provider_Facility__r.Ship_Kit__c---'+OProvider.Provider_Facility__r.Ship_Kit__c);
                Opp.PickUp_or_Ship_Kit__c = 'Ship';
              }
              if(OProvider.Provider_Facility__r.Ship_Kit__c == 'Never Ship Kit'){
                System.debug('OProvider.Provider_Facility__r.Ship_Kit__c---222'+OProvider.Provider_Facility__r.Ship_Kit__c);
                Opp.PickUp_or_Ship_Kit__c = 'PickUp';
              }
              FinalOppList.add(Opp);
            }
           }
           
        }
      }
      System.debug('FinalOppList------'+FinalOppList);
      if(FinalOppList!=null && !FinalOppList.isEmpty()){
        SaveResultList = Database.update(FinalOppList,false);
      }
      System.debug('SaveResultList========'+SaveResultList);
    }
}
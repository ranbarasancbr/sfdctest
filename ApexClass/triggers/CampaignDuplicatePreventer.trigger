/***********************************************************************************************************************
*Component Name: CampaignDuplicatePreventer
*Description: Prevent creation of a duplicate Campaign Records.
*Developed By: Tek Systems
************************************************************************************************************************/


trigger CampaignDuplicatePreventer on Campaign (before insert, before update) {

    //map declaration to hold records which we will add, this will become a unique map, no duplicate values
    
    Map<String, Campaign> campaignMap = new Map<String, Campaign>();

    for (Campaign camp: System.Trigger.new) {

        /* Make sure we don't treat a campaign name
           isn't changing during an update as a duplicate. */
        if ((camp.name!= null) && (System.Trigger.isInsert || (camp.name!= System.Trigger.oldMap.get(camp.Id).name))) {

            // Make sure another new campaign isn't also a duplicate
            if (campaignMap.containsKey(camp.Name)) {
                camp.Name.addError('Another new campaign has the same name.');
            } else {
                campaignMap.put(camp.name, camp);
            }
        }
    }
    
    /* Using a single database query, find all the campaigns in the database */
     /*  that have the same name as ANY of the campaigns being inserted or updated. */
       
    for (Campaign camp : [SELECT Name FROM Campaign WHERE Name IN :campaignMap.KeySet()]){
         Campaign newCamp = campaignMap.get(camp.Name);
         newCamp.Name.addError('A Campaign with the same name already exists.');
    }
}
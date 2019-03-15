/***********************************************************************************************************************
*Component Name: CampaignDuplicatePreventerTest
*Description: Test Class to check if duplicate campaign Records would be created.
*Developed By: Tek Systems
************************************************************************************************************************/


@isTest
public class CampaignDuplicatePreventerHelperTest{

    @isTest public static void insertCamp(){
        Campaign camp1 = new Campaign(Name = 'CampaignAlpha');
        insert camp1;
        
        Campaign camp2 = new Campaign(Name = 'CampaignAlpha'); 
        try{
            insert camp2;
        } catch(Exception e) {
            System.assert(e.getMessage().contains('A Campaign with the same name already exists.'));
        }
         
    }  
    
    @isTest public static void UpdateCamp(){
        Campaign camp3 = new Campaign(Name = 'CampaignBeta');
        insert camp3;
        
        camp3.Name = 'CampaignGama';
        try {
             update camp3;
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Another campaign has the same name.'));
        }  
    }  
}
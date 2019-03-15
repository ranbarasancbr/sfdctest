/****************************************************************************************************************************************
 * Component Name: VerifyPrimaryContact
 * Description	: Controller of VerifyPrimaryContact visualforce page.
				  This vf page is used for button in opportunity detail page which updates opportunity. 
				   Updating primary contact and secondary contact logic is in OpportunityTriggerHelper.updatePrimaryContactOnOpp()
 * Developed By	: TEKsystems
 * **********************************************************************************************************************************/
public with sharing class VerifyPrimaryContact {
public string oId {get;set;}
    // constructor
    public VerifyPrimaryContact(){
        oId = apexpages.currentpage().getparameters().get('id');
    }
    public pagereference updatePrimaryContact(){        
        // getting case Record Details
        Opportunity oppRec = [Select id,Primary_Contact__c from Opportunity where id=:oId];
       
        //update oppRec;
        Database.update(oppRec,false);
        PageReference pg = new PageReference('/'+oId);  
        pg.setRedirect(true);
        return pg;           
    }
}
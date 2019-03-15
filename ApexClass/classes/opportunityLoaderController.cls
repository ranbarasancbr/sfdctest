/*    
    Name :  opportunityLoaderController
    Author: Kapil Gundi
    Date :  June 28 2018
*/

global class opportunityLoaderController{
    private ApexPages.StandardController ctrl;
    public Id oppId;
    public opportunityLoaderController(ApexPages.StandardController controller) {
       
        
    }
    
    WebService static void setContactRole( String rid){
      
       Opportunity opp = [Select Id From Opportunity Where Id=:rid];
       update opp;
       system.debug('Upded opp>>'+opp);
    }
}
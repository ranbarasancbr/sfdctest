public class ReferalOpportunityController{
    public string oppId;
    public List<referalClass> wrapperList {get;set;}
    public ReferalOpportunityController(ApexPages.StandardController controller) {
        oppId = '';
        Id conId = controller.getRecord().id;
        wrapperList  = new List<referalClass>();
        List<OpportunityContactRole> ocrList = [Select Id,OpportunityId,ContactId From OpportunityContactRole Where (opportunity.Status__c='Stored' OR opportunity.Status__c='Enrolled' or opportunity.Status__c='Pending') AND ContactId=:conId Limit 1]; 
        if(ocrList.size()>0){
            oppId = ocrList[0].OpportunityId;
            getReferalData();
        }
    }
    
    public void getReferalData(){
        //wrapperList  = new List<referalClass>();
        if(oppId != ''){
            List<Opportunity> parentOppList = [Select Id,Storage_Date__c,Status__c,Enrollment_Date__c,Name,(Select Id,Contact.FirstName,Contact.LastName From OpportunityContactRoles Where IsPrimary=true) From Opportunity Where Referred_By_Opportunity__c=:oppId];
            for(Opportunity opp : parentOppList){
                referalClass wc = new referalClass();
                for(OpportunityContactRole ocr : opp.OpportunityContactRoles){
                    wc.oppName = opp.Name;
                    wc.conFname = ocr.Contact.FirstName;
                    wc.conLname = ocr.Contact.LastName;
                }  
                wc.oppEnrollDate = opp.Enrollment_Date__c;
                wc.oppStorageDate = opp.Storage_Date__c;
                wc.oppStatus = opp.Status__c;      
                wrapperList.add(wc);
            }
        }
    }
    
    public class referalClass{
        public string oppName {get;set;}
        public DateTime oppEnrollDate {get;set;}
        public DateTime oppStorageDate {get;set;}
        public String oppStatus {get;set;}
        public String conFname {get;set;}
        public String conLname {get;set;}
        
    }
}
public class CWPUserInformationController{
    public Boolean loginButton {get;set;}
    public Boolean activeLoginButton {get;set;}
    public Boolean inactiveLoginButton {get;set;}
    public contact con {get;set;}
    public String conId {get;set;}
    public CWPUserInformationController(ApexPages.StandardController controller){
        con = new Contact();
        conId = ApexPages.currentPage().getParameters().get('id');
        con = [Select Id,Name,User_Name__c,Activation_Date__c,Last_Login_Date__c,Temporary_Password__c,Temporary_Password_Expiration__c,
               Active__c,SCSS_Contact_Id__c From Contact Where Id=:ConId];
        loginButton = false;
        inactiveLoginButton = false;
        checkLoginButton();
    }
    public void checkLoginButton(){
        List<OpportunityContactRole> opConRole = [Select Id,OpportunityId,Opportunity.StageName,Opportunity.Status__c,Opportunity.AccountId From OpportunityContactRole Where ContactId=:conId and IsPrimary=true];
        if(opConRole.size()>0){
            Set<String> loginStatus = new Set<String>{'Enrolled','Stored'};
            Set<String> inActiveStatus = new Set<String>{'Enrolled','Open'};
            Set<String> activeLoginStatus = new Set<String>{'Enrolled','Stored'};
            for(OpportunityContactRole ocr : opConRole){
                if(loginStatus.contains(ocr.Opportunity.Status__c) && ocr.Opportunity.StageName == 'Won (9)'){
                    loginButton = true;
                }
                if(activeLoginStatus.contains(ocr.Opportunity.Status__c)){
                    activeLoginButton = true;
                }
                //if(inActiveStatus.contains(ocr.Opportunity.Status__c) &&  ocr.Opportunity.StageName == 'Closed Lost (10)'){
                if(inActiveStatus.contains(ocr.Opportunity.Status__c) &&  ocr.Opportunity.StageName != 'Closed Lost (10)'){    
                    inactiveLoginButton = true;
                }
            }
        }
        /*if(loginButton == false){
            inactiveLoginButton = false;
        }*/
        if(inactiveLoginButton && con.Active__c){
           inactiveLoginButton = true; 
        }else{
            inactiveLoginButton = false;
        }
    }
    public void inactiveLoginBtn(){
        con.Active__c = false;
        update con;
    }
    public List<contact> getCWPUserInformation(){
        String conId = ApexPages.currentPage().getParameters().get('id');
        return [Select Name,User_Name__c,Activation_Date__c,Active__c,Last_Login_Date__c,Temporary_Password__c,Temporary_Password_Expiration__c From Contact Where id =: conId ];
    }
}
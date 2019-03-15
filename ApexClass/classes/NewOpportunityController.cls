/*
    Name : NewOpportunityController
    Author : Pari
    Date : March 1 2019
    Description : This Controller create new opportunity from Account
    User Story : CBRSFDC8-755
*/

global class NewOpportunityController{
    public Id accId {get;set;}
    public String primarySource {get;set;}
    public Boolean isError;
    public Opportunity oppObject {get;set;}
    public List<SelectOption> CBOptions {get; set;}
    public List<SelectOption> CTOptions {get; set;}
    public String fromPage;
    public NewOpportunityController(ApexPages.StandardController controller) {
    	
        accId = ApexPages.currentPage().getParameters().get('accId');
        fromPage = ApexPages.currentPage().getParameters().get('from');
        primarySource = ApexPages.currentPage().getParameters().get('primarySource');
        
        oppObject = new Opportunity();
        oppObject.of_CB__c = '1';
        oppObject.of_CT__c = '0';
        oppObject.StageName = 'Rapport and Education (5)';
        oppObject.of_Babies__c = 'Single';
        if(UserInfo.getProfileId() == Label.CSS_Profile_Id){
            oppObject.LeadSource = 'CSS Referral';
        }
        oppObject.AccountId = accId;
        CBOptions = new List < SelectOption > (); 

            CBOptions.add(new SelectOption('0','0'));
            CBOptions.add(new SelectOption('1','1'));
            CBOptions.add(new SelectOption('2','2'));
            CBOptions.add(new SelectOption('3','3'));
            CBOptions.add(new SelectOption('4','4'));
            CBOptions.add(new SelectOption('5','5'));
        
        CTOptions = new List < SelectOption > (); 

            CTOptions.add(new SelectOption('0','0'));
            CTOptions.add(new SelectOption('1','1'));
            CTOptions.add(new SelectOption('2','2'));
            CTOptions.add(new SelectOption('3','3'));
            CTOptions.add(new SelectOption('4','4'));
            CTOptions.add(new SelectOption('5','5'));

    }
    public PageReference  saveOpportunity(){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Test Error'));
            Account acc = [Select Id,Name From Account Where Id=:accId];
            system.debug('test page 1 debug');
            Boolean noError = false;
            oppObject.Name = 'Test';
            oppObject.CloseDate= System.today();
            if(String.isNotBlank(primarySource)){
              oppObject.Primary_Source__c = 'I\'m a Current Client'; 
            }
           // if(!Test.isRunningTest()){
                try{
                    system.debug('to insert....');
                    insert oppObject;
                    system.debug('oppObject---------'+oppObject);
                }catch(Exception ex){
                    system.debug('Error in catch'+ex.getMessage());
                    noError = true;
                  //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                   
                }
           // }
            if(noError == false){
               /* system.debug('if no error return false');
                OpportunityContact__c ocr = new OpportunityContact__c();
                ocr.PersonAccount__c = accId;
                ocr.Opportunity__c = oppObject.Id;
                try{
                    insert ocr;
                }
                catch(Exception ex){

                }*/
                system.debug(fromPage);
                if(fromPage == 'classic'){
                    PageReference pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + accId);
                    return pageRef;
                }else{
                    PageReference pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()+ '/lightning/o/Account/list?filterName=Recent&0.source=alohaHeader');

                    return pageRef;
                }
            }

           return null; 
    }
    //Check  opportunity status In(open or enrolled)
    @AuraEnabled
    webservice static String checkOpportunityOnContact(Id accId){
        List<OpportunityContact__c> ocrList = new List<OpportunityContact__c>();
        Set<String> oppStatus = new Set<String>{'Open','Enrolled','Stored'};
        //Query on OpportunityContactRole Objectwith Person Account id
        ocrList = [Select Id,Opportunity__c,PersonAccount__c, Opportunity__r.Status__c From OpportunityContact__c Where PersonAccount__c =:accId AND Opportunity__r.Status__c IN:oppStatus];
        system.debug('ocrList size'+ocrList);
       /* if(ocrList.size() == 0){
            system.debug('return true');
            return true;
        }else{
            system.debug('return false');
            return false;
        } */
        //If opportunity contact roles are present then we add status of opportunity related to that OCR to OCROppStatus.
        Set<String> OCROppStatus = new Set<String>();
        if(ocrList !=null && !ocrList.isEmpty()){
            system.debug('ocrList---'+ocrList);
            for(OpportunityContact__c ocr:ocrList){
                OCROppStatus.add(ocr.Opportunity__r.Status__c);
            }
        }
        //if there are no opportunitycontactRoles then opportunity can be created for current contact
        else{
            return 'CreateOpp';
        }

        if(OCROppStatus!=null && !OCROppStatus.isEmpty()){
            if(OCROppStatus.containsAll(oppStatus) || (OCROppStatus.contains('Stored') && (OCROppStatus.contains('Open') || OCROppStatus.contains('Enrolled')))){
                system.debug('OCROppStatus---11'+OCROppStatus);
                return 'CanNotCreateOpp';//When Opp status with stored and open or enrolled
            }
            else if(OCROppStatus.contains('Stored') && (!OCROppStatus.contains('Open') || !OCROppStatus.contains('Enrolled'))){
                system.debug('OCROppStatus---22'+OCROppStatus);
                return 'CurrentClientOpp';//When Opp status is only stored
            }
            else if(OCROppStatus.contains('Stored') && !OCROppStatus.contains('Open') && !OCROppStatus.contains('Enrolled')){
                system.debug('OCROppStatus---33'+OCROppStatus);
                return 'CurrentClientOpp';//When opp status is Only Stored
            }
            else if((OCROppStatus.contains('Open') || OCROppStatus.contains('Enrolled'))){
                system.debug('OCROppStatus---44'+OCROppStatus);
                return 'OpenOrEnrollOpp';//When opp status is open or enrolled
            }
            else{
                system.debug('OCROppStatus=======Other values'+OCROppStatus);
                return 'CreateOpp';
            }
        }
        else{
            return 'CreateOpp';
        }
    }
    
   /* @AuraEnabled
    public static String isOpportunityOnContact(Id conId){
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        Set<String> oppStatus = new Set<String>{'Open','Enrolled'};
        ocrList = [Select Id,OpportunityId,ContactId From OpportunityContactRole Where ContactId=:conId and Opportunity.Status__c In:oppStatus ];
        system.debug('ocrList size'+ocrList);
        if(ocrList.size() == 0){
            system.debug('return true');
            return 'yes';
        }else{
            system.debug('return false');
            return 'no';
        }
    }*/
}
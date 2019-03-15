/**************************************************************************************************************************************
*Component Name : opportunityMergeController
*Developed By   : TEKsystems
*Description    : This class is controller for Opportunitymergetab.selected winning and losing Opportunities are merged.
                   If selected winning opportunity or losing opportunity doesnt meet the criteria to be a winning or losing opp the we populate errors on UI to select valid opportunities. If merge is standard opportunities are merged and if custom merge type select fields that need to be merged.
*User Story     :  491


**********************************************************************************************************************************/
public class opportunityMergeController {
    
    public Opportunity winningOppty {get;set;}//Winning Opportunity Selected 
    public Opportunity LosingOpty{get;set;}//Losing Opportuity Selected
    public Opportunity winningOpptyOnUI{get;set;}//Winning Opportunity to display details on VF page 
    public Opportunity LosingOptyOnUI{get;set;}//Losing Opportuity to display details on VF page  
    public  Map<id,Opportunity> OppMap;//Map holds queried winning and lossing
    public SelectOption[] selectedFields { get; set; }//Holds selected fileds for custom merge
    public SelectOption[] allFields { get; set; }//All fields available to select
    public String selectedvalue{get;set;}//This hold mergetype selected by user to merge opportunities
    public Boolean customMerge{get;set;}//To show multi select section for custom merge
    public Boolean notWinOpp;//This boolean is set to true when selected winning opp is not a valid winning opp and also  is used to display error when user clicks merge button
    public Boolean notLossOpp;//This boolean is set to true when selected Losing opp is not a valid losing opp and also is used to display error when user clicks merge button
    public List<WrapperClass> wrapperList;//Each Wrapperclass record holds winning Opportunity,Losing Opportunity,mergetype,and selected records.
    public Id MergingUserId;
    public String wOppid{get; set;}
    public String baseURL{get; set;}
    public String LOppId{get;set;}
    public Set<String> InvalidOppErrors;//This list is used to display errors on click of merge or if selected opp is not a winning or losing opp
    public Map<String,OpportunityMergeError__mdt> ErrorsMetaData;//This Map holds all errors
    public opportunityMergeController() {
        List<OpportunityMergeError__mdt> ErrorsList = [SELECT MasterLabel, DeveloperName,ErrorMessage__c from OpportunityMergeError__mdt];
        ErrorsMetaData = new Map<String,OpportunityMergeError__mdt>();
        for(OpportunityMergeError__mdt error:ErrorsList){
            ErrorsMetaData.put(error.MasterLabel,error);
        }
        MergingUserId = UserInfo.getUserId();
        system.debug('User Id'+MergingUserId);
        notWinOpp = false;
        notLossOpp = false;
        InvalidOppErrors = new Set<String>();
        winningOppty = new Opportunity();
        LosingOpty = new Opportunity();
        winningOpptyOnUI = new Opportunity();
        LosingOptyOnUI = new Opportunity();
        selectedFields = new List<SelectOption>();
        selectedValue = 'Standard';
        customMerge = false;
        allFields = new List<SelectOption>(); 
        wOppid = null;
        LOppId = null;
        String domainURL = URL.getOrgDomainUrl().toString();
        baseURL = domainURL.substringBefore('.')+'.lightning.force.com';
        system.debug('baseURL===='+baseURL);
    }
    
    //On click of merge button this method is called.
    public PageReference MergeOpportunities() { 
        List<String> ErrorsList = new List<String>();//This list holds opportunity merge failure errors
        set<String> ApiNames = new set<String>();//If merget type is custom then selected values i.e selected fields API names are added to this Set
        wrapperList = new List<WrapperClass>();//values are added to wrapperclass variables
        //After merge button is clicked we check weather selected opportunities are satisfied winning criteria and lossing criteria if not satisfied we display errors
        system.debug('notWinOpp-----------'+notWinOpp);
        system.debug('notLossOpp-----'+notLossOpp);
       /* if(notWinOpp == true || notLossOpp == true){
            //Display error if Winning Opp is not valid and losing opp is valid
            if(notWinOpp = true && notLossOpp == false){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MergeError1));
            }
            //Display Label.MergeError2 error if Winning opp is valid and losing Opp is not valid 
            if(notWinOpp == false && notLossOpp == true){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MergeError2));
            }
            //Display Label.MergeError3 error if Winning and Losing opps are not valid
            if(notWinOpp == true && notLossOpp == true){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MergeError3));
            }
        }*/

        //If valid winning  and lossing Opportunitys are selected below else if is executed
       /* else if(notWinOpp == false && notLossOpp == false){
            //If winningOpptyOnUI or LosingOptyOnUI display errors on UI to select a winning opp and losing opp
            if(winningOpptyOnUI==null || LosingOptyOnUI == null){
                if(winningOpptyOnUI==null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MergeError4));
                }
                if(LosingOptyOnUI == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MergeError5));
                }
            }
            //Follwoing else if condition is executed if winning opp and losing opp are same
            else if(String.isNotBlank(winningOpptyOnUI.id) && String.isNotBlank(LosingOptyOnUI.id) && winningOpptyOnUI.id == LosingOptyOnUI.id){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Winning and Losing Opportunity cannot be same Opportunity'));
            }
            //If Mergetype is custom check fields should be selected for merging opportunities
            else if(selectedValue == 'Custom' && String.isNotBlank(winningOpptyOnUI.id) && String.isNotBlank(LosingOptyOnUI.id)){
                //If fields are not selected display error
                system.debug('selectedFields'+selectedFields);
                if(selectedFields==null ||selectedFields.isEmpty()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MergeError6));
                }
                //For custom merge fields are selected below else condition is executed
                else{
                    //Adding selected field's API names to list 
                    for(SelectOption s:selectedFields){
                        ApiNames.add(s.getValue());
                    }
                    //Below variables are created as inputs for wrapperClass which is passed as input for merge method to merge opportunities
                    Opportunity  winOpp = winningOpptyOnUI;
                    Opportunity lossOpp = LosingOptyOnUI;
                    String mergeType = 'Custom';
                    Set<String> selectedFields = ApiNames;
                    id MergedUserId = MergingUserId;
                    wrapperList.add(new WrapperClass(winOpp,lossOpp,mergeType,selectedFields,MergedUserId,system.today()));
                    system.debug(wrapperList);
                     ErrorsList = opportunityValidateAndMerge.validateAndMergeOpp(wrapperList);//This Method have logic to update winning opportunity and reparent child records of losing opportunity
                } 
            }
            //If merge type is standard below logic executes
            else if(selectedValue == 'Standard' && String.isNotBlank(winningOpptyOnUI.id) && String.isNotBlank(LosingOptyOnUI.id)){
                //Below variables are created as inputs for wrapperClass which is passed as input for merge method to merge opportunities
                Opportunity  winOpp = winningOpptyOnUI;
                Opportunity lossOpp = LosingOptyOnUI;
                String mergeType = 'Standard';
                set<String> selectedFields = null;
                id MergedUserId = MergingUserId;
                wrapperList.add(new WrapperClass(winOpp,lossOpp,mergeType,selectedFields,MergedUserId,system.today()));
                system.debug(wrapperList);
               ErrorsList =  opportunityValidateAndMerge.validateAndMergeOpp(wrapperList);//This Method have logic to update winning opportunity and reparent child records of losing opportunity
            }
        }   */  
        if(winningOpptyOnUI.id==null || LosingOptyOnUI.id == null){
                system.debug('error11');
                if(winningOpptyOnUI.id==null){
                    system.debug('error12121');
                    InvalidOppErrors.add('SelectWinOppToMerge');
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('SelectWinOppToMerge').ErrorMessage__c));
                }
                if(LosingOptyOnUI.id == null){
                    system.debug('error0000');
                    InvalidOppErrors.add('SelectLossOppToMerge');
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('SelectLossOppToMerge').ErrorMessage__c));
                }
            } 
             //Follwoing else if condition is executed if winning opp and losing opp are same
            else if(String.isNotBlank(winningOpptyOnUI.id) && String.isNotBlank(LosingOptyOnUI.id) && winningOpptyOnUI.id == LosingOptyOnUI.id){
                InvalidOppErrors.add('WinLossOppCannotBeSame');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('WinLossOppCannotBeSame').ErrorMessage__c));
            }
        if(InvalidOppErrors!=null && !InvalidOppErrors.isEmpty()){
            List<String> tempList = new List<String>();
            tempList.addAll(InvalidOppErrors);
            for(String s:tempList){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get(s).ErrorMessage__c));
            }
        }
        else{
            system.debug('else if no opps selected');
            system.debug('winningOpptyOnUI========'+winningOpptyOnUI.id);
            system.debug('LosingOptyOnUI=========='+LosingOptyOnUI.id);
            //If Mergetype is custom check fields should be selected for merging opportunities
             if(selectedValue == 'Custom' && String.isNotBlank(winningOpptyOnUI.id) && String.isNotBlank(LosingOptyOnUI.id)){
                //If fields are not selected display error
                system.debug('selectedFields'+selectedFields);
                if(selectedFields==null ||selectedFields.isEmpty()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('CustomMergeFieldsError').ErrorMessage__c));
                }
                //For custom merge fields are selected below else condition is executed
                else{
                    //Adding selected field's API names to list 
                    for(SelectOption s:selectedFields){
                        ApiNames.add(s.getValue());
                    }
                    //Below variables are created as inputs for wrapperClass which is passed as input for merge method to merge opportunities
                    Opportunity  winOpp = winningOpptyOnUI;
                    Opportunity lossOpp = LosingOptyOnUI;
                    String mergeType = 'Custom';
                    Set<String> selectedFields = ApiNames;
                    id MergedUserId = MergingUserId;
                    wrapperList.add(new WrapperClass(winOpp,lossOpp,mergeType,selectedFields,MergedUserId,system.today()));
                    system.debug(wrapperList);
                     ErrorsList = opportunityValidateAndMerge.validateAndMergeOpp(wrapperList);//This Method have logic to update winning opportunity and reparent child records of losing opportunity
                } 
            }
            //If merge type is standard below logic executes
            else if(selectedValue == 'Standard' && String.isNotBlank(winningOpptyOnUI.id) && String.isNotBlank(LosingOptyOnUI.id)){
                //Below variables are created as inputs for wrapperClass which is passed as input for merge method to merge opportunities
                Opportunity  winOpp = winningOpptyOnUI;
                Opportunity lossOpp = LosingOptyOnUI;
                String mergeType = 'Standard';
                set<String> selectedFields = null;
                id MergedUserId = MergingUserId;
                wrapperList.add(new WrapperClass(winOpp,lossOpp,mergeType,selectedFields,MergedUserId,system.today()));
                system.debug(wrapperList);
               ErrorsList =  opportunityValidateAndMerge.validateAndMergeOpp(wrapperList);//This Method have logic to update winning opportunity and reparent child records of losing opportunity
            }
        } 
        if(ErrorsList!=null || !ErrorsList.isEmpty()){
           for(String s:ErrorsList){
            //Opportunity merged Message says that opportunity is sucessfully merged.
                if(!s.equals('Opportunity Merged')){
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,s));
                  }
                  //If any errors during opportunity then those errors are displayed on UI 
                  else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,s));
                  }
               
            }
        }
        
        return null;       
    }    
    
    //get opportunity field values for selected opportunities
    public PageReference getOpportunity1(){
        Date todaysDate = system.today();
        Set<String> losingStatus = new Set<String>{'Open','Enrolled'};//This set is used to check if selected losing opp's status is in this set
        Set<id> oppids = new Set<id>();//selected winning opp's or losing opp's ids are added to this set and this set is used to query on opportunity object to get opps whose id in set.
        OppMap = new Map<id,opportunity>();//Queried opps are added to this Map

        system.debug('winningOppty.OpportunityMerge__c'+winningOppty.OpportunityMerge__c);
        system.debug('LosingOpty.OpportunityMerge__c'+LosingOpty.OpportunityMerge__c);
        //add selected winning opp id to Set 
        if(String.isNotBlank(winningOppty.OpportunityMerge__c)){
            oppids.add(winningOppty.OpportunityMerge__c);
        }
        //add selected losing opp id to Set 
        if(String.isNotBlank(LosingOpty.OpportunityMerge__c)){
            oppids.add(LosingOpty.OpportunityMerge__c);
        }
        //If above set is not empty query on opportunity Object
        if(oppids!=null && !oppids.isEmpty()){
            OppMap = new map<id,opportunity>([select id,name,Storage_Date__c,Gift_Registry_End_Date__c,Gift_Registry_Start_Date__c,Pending_Date__c,StageName,Status__c,OpportunityMerge__c,Primary_Contact_First_Name__c,Primary_Contact_Last_Name__c,due_date__c,CreatedDate,of_Babies__c,of_CB__c,of_CT__c,Adoption_Type__c,Primary_Source__c,Referred_By_Opportunity__c,Section_2_Received_Birth_Mother__c,Section_3_Incomplete_Birth_Mother__c,Section_3_Received_Birth_Mother__c,Section_3_Needs_Review_Birth_Mother__c,Section_1_Received__c,Section_2_Received__c,Section_3_Received__c,Section_3_Incomplete__c,Section_3_Needs_Review__c,Section_4_Received__c,Section_5_Received__c,Delivering_Hospital__c,Payment_Plan__c,Payment_Method__c,CB_Storage_Fee_Option__c,CT_Storage_Fee_Option__c,Corporate_Discount__c,Promo_Code__c,Manual_Discount__c,Discount_Comments__c,PickUp_or_Ship_Kit__c,Ship_To_Name__c,Ship_To_Street1__c,Ship_To_Phone__c,Total_Expedited_Shipping_Cost__c,Shipping_Method__c,Requested_Shipping_Method__c,Requested_Shipping_Date__c,Saturday_Delivery__c,Signature_Required__c,PriceBook2Id,Opportunity_Merged_By__c,Opportunity_Merged_Date__c,Losing_Opportunity__c,Primary_Contact__c,Secondary_Contact__c,Online_Enrollment__c,Section_5_Received_Birth_Mother__c,OwnerId,Loss_Reason__c,Ship_To_Street2__c,Ship_To_City__c,Ship_To_State__c,Ship_To_Zip_Code__c,Ship_To_Country__c from opportunity where id IN : oppids]); 
        }
        //If winningOppty is not null then check validations to confirm it is a winnning opportunity
        if(String.isNotBlank(winningOppty.OpportunityMerge__c)){
            winningOpptyOnUI = OppMap.get(winningOppty.OpportunityMerge__c);
            //Check winningOppty is winning opportunity's status is not closed
            if(winningOpptyOnUI.Status__c == 'Closed_Lost'){
                InvalidOppErrors.add('ClosedWinOppError');
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.OpptyMergeError1));
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('ClosedWinOppError').ErrorMessage__c));
                notWinOpp = true;
            }
            //Check selected opp's due date is not null and days between created date of winning opp and today is should be less than or equal to 300 days then throw an error. If this if condition is passed then add true value to notWinOpp boolean. 
            if(winningOpptyOnUI.Due_Date__c == null){
                Integer val = todaysdate.daysBetween(winningOpptyOnUI.CreatedDate.date());
                if(val < 0){
                    val = math.abs(val);
                }
                if( val >= 300){
                    InvalidOppErrors.add('DueDateNullError');
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.WOpptyMergeError2));
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('DueDateNullError').ErrorMessage__c));
                    notWinOpp = true;
                }
            }
            
            //If selected opp's due date is not null than days between today and due date should be less than or equal to 90 days
            //system.debug('days...'+todaysdate.daysBetween(winningOpptyOnUI.Due_Date__c));
            if(winningOpptyOnUI.Due_Date__c != null){
                Integer daysNum = todaysdate.daysBetween(winningOpptyOnUI.Due_Date__c);
                if(daysNum < 0){
                    daysNum = math.abs(daysNum);
                }
                if(daysNum >= 90){
                    system.debug('debug 1 due date');
                    InvalidOppErrors.add('DueDateNotNullError');
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.WOpptyMergeError3));
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('DueDateNotNullError').ErrorMessage__c));
                    notWinOpp = true;
                }
            }
            
            //if selected opp's status is not null and and days between today and opp's created date is less than 300 or days between today and duedate is less than 90 then selected opportunity is a winning opportunity 
            if( winningOpptyOnUI.Status__c != 'Closed_Lost' && (( winningOpptyOnUI.Due_Date__c!=null && math.abs(todaysdate.daysBetween(winningOpptyOnUI.Due_Date__c)) < 90) || math.abs(todaysdate.daysBetween(winningOpptyOnUI.CreatedDate.date())) < 300)){
                system.debug('math.abs(todaysdate.daysBetween(winningOpptyOnUI.CreatedDate.date()))---'+math.abs(todaysdate.daysBetween(winningOpptyOnUI.CreatedDate.date())));
                if(notWinOpp == false){
                    notWinOpp = false;
                }
                system.debug('debug 2 is duedate');
            } 
            else{
                if(notWinOpp == false){
                    system.debug('not winnning opp');
                    InvalidOppErrors.add('NoWinOpp');
                    // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MergeError1));
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('NoWinOpp').ErrorMessage__c));
                    notWinOpp = true;
                }
             }
        }
      
        if(String.isNotBlank(LosingOpty.OpportunityMerge__c)){
            LosingOptyOnUI = OppMap.get(LosingOpty.OpportunityMerge__c);
            //Losing Opp cannot be closed opp
            if(LosingOptyOnUI.Status__c == 'Closed_Lost'){

                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.LOpptyMergeError1));
                InvalidOppErrors.add('ClosedLossOppError');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('ClosedLossOppError').ErrorMessage__c));
                notLossOpp = true;
            }
            //If Storage Date is not null OR Pending Date is not null following error is displayed Error message :"The losing Opportunity has already been stored.  It cannot be merged automatically." 
            if(LosingOptyOnUI.Storage_Date__c != null || LosingOptyOnUI.Pending_Date__c!=null){
               // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.LOpptyMergeError2));
               InvalidOppErrors.add('StorageOrPendingDateNull');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('StorageOrPendingDateNull').ErrorMessage__c));
                notLossOpp = true;
            }
            //Losing Opportunity's status can not be closed_lost or pending or stored
            if(LosingOptyOnUI.Status__c != 'Closed_Lost' && !losingStatus.contains(LosingOptyOnUI.Status__c)){
                InvalidOppErrors.add('NotLossOppStatus');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ErrorsMetaData.get('NotLossOppStatus').ErrorMessage__c));
            }
            //If losing opp's status in losingStatus and its storage date is null or pending date is null then losing opp is a valid losing opp
            if(losingStatus.contains(LosingOptyOnUI.Status__c) && (LosingOptyOnUI.Storage_Date__c == null || LosingOptyOnUI.Pending_Date__c==null)){
                if(notLossOpp == false){
                    notLossOpp = false;
                }
            }

            
        }
         return null;
    } 
    //This method is called when mergetype radio button is selected. Default merge type is standard.
    public pageReference radioButtonMethod(){
        system.debug('inside radio button');
        List<Schema.FieldSetMember> oppfields = SObjectType.opportunity.FieldSets.OpportunityFields.getFields(); 
        if(selectedValue == 'Standard'){
            system.debug('Standard....');
            customMerge = false;
            system.debug('Standard customMerge==='+customMerge);
        }
        //If merge type is custom then customMerge = true. To reder custom fields selection section
        else if(selectedValue == 'Custom'){
            system.debug('Custom...........');
            customMerge = true;
            system.debug('Custom customMerge==='+customMerge);
            
            for(Schema.FieldSetMember s:oppfields){
                allFields.add(new SelectOption(s.getFieldPath(),s.getLabel()));
            }
        }
        return null;
        
    }
    
    //This Wrapper holds winning opportunity, losing Opportunity, merge type selected by user and if merge type is custom list of fields that need to be merged.
    public class WrapperClass{
        public Opportunity winOpp{get;set;}//Winning Opportunity
        public Opportunity lossOpp{get;set;}//Losing Opportunity
        public String mergeType{get;set;}//Merge Type
        public Set<String> selectedFields{get;set;}//If mergeType is custom this value is provided with list fields that should be merged
        public id MergedUserId{get;set;}//
        public Date OppMergedDate{get;set;}
        public WrapperClass(Opportunity wOpp, Opportunity lOpp, String mergeT, Set<String> mFields, id userId,Date MergingDate){
            this.winOpp = wOpp;
            this.lossOpp = lOpp;
            this.mergeType = mergeT;
            this.selectedFields = mFields;
            this.MergedUserId = userId;
            this.OppMergedDate = MergingDate;
        }
        
    }
    
    public PageReference reloadPage(){
        pageReference pg = new pageReference(ApexPages.currentPage().getURL());
        pg.setRedirect(TRUE);
        return pg;
    }
}
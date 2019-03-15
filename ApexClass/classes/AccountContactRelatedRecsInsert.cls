/*********************************************************************************************************
*Component Name: AccountContactRelatedRecsInsert
*Description   : controller to create account, contact, opportunity, opportunity contact roles,Opportunity provider(if Provider ID and Provider Facility ID 
                values are provided on OE) and Contact payment profile(if any of following fields have values Credit Card ProfileID /Cardholder Name /Credit Card Type /CC Expiration Month/Expiration Year/Last 4 Digits) when a online enrollment record is created.
*Developed By  : Tek Systems
*/
/*********************************************************************************************************
*FOR BACKUP
*
*/

public class AccountContactRelatedRecsInsert{

    //Method calls helper method which creates all related records of enrollment object
    public static void AccountsAndRelatedRecordsInsert(Set<id> onlineEnrolls){
        
        if(onlineEnrolls!=null && !onlineEnrolls.isEmpty()){
            AllSobjectRecords(onlineEnrolls);
        }
    }
   
    //Method to create Accounts and related records
    public static void AllSobjectRecords(Set<Id> OElist){
        list<String> errors = new List<String>();//If any accouts are failed to create failed account's errors are stamped in this list
        List<Account> accountfinalList = new List<account>();//Final Accounts list that are to be Inserted
        system.debug('OElist'+OElist);
        //Map to use field values to create different object records
        map<id,Online_Enrollment__c> onlineEmap = new map<id,Online_Enrollment__c>();//Mep to store all online enrollments that are created
        if(OElist!=null && !OElist.isEmpty()){
            system.debug('truevalu');
            //All fields of online enrollment are queried in onlineEnrollmentCreateupdateHelper.getOnlineEnrollMap(OElist)
            onlineEmap = onlineEnrollmentCreateupdateHelper.getOnlineEnrollMap(OElist);
        }
        //Start of account creation logic
        
        Set<String> OEFacilityId = new Set<String>();//master facility id of each online enrollment is stored in this set to query on facility object to get sfdc id of facility
        Set<String> OEProviderIds = new Set<String>();//master provider id of each online enrollment is stored in this set to query on provider object to get sfdc id of provider
        Set<String> OEProviderFacilityIds = new Set<String>();//master facility provider id of each online enrollment is stored in this set to query on facility provider object to get sfdc id of facility provider
        
       //If a OLE is for repeat client we dont create account and contact. For a repeat client OLE Priamry Contact SCSS ID OR Secondary Contact SCSS Id will be provided(Primary contact SCSS Id is mandatory for a repeat client). using primary contact SCSS ID we query on contact object's field SCSS Id should be equal to primary contact SCSS Id.
       Map<id,Online_Enrollment__c> repeatClientOLEs = new Map<id,Online_Enrollment__c>();
       Map<id,Online_Enrollment__c> NewSecConRepeatClient = new Map<id,Online_Enrollment__c>();
       Set<String> RepeatClientContactId = new Set<String>();
       Set<String> PrimaryConSCSSId = new Set<String>();
       Map<String,Id> SCSSIdOLEIdMap = new Map<String,Id>();
       Map<String,Id> SCSSSecondaryIdOLEIdMap = new Map<String,Id>();
       Map<id,Contact> RepeatClientContactMap = new Map<id,contact>();//Map holds Repeat client contacts 
        if(!onlineEmap.isEmpty() && onlineEmap!=null){
            for(Online_Enrollment__c o:onlineEmap.Values()){
                if(o.Repeat_Client__c && String.isNotBlank(o.Primary_Contact_SCSS_Id__c)){
                    system.debug('repeat client true');
                    repeatClientOLEs.put(o.id,o);
                    RepeatClientContactId.add(o.Primary_Contact_SCSS_Id__c);
                    SCSSIdOLEIdMap.put(o.Primary_Contact_SCSS_Id__c,o.id);
                    PrimaryConSCSSId.add(o.Primary_Contact_SCSS_Id__c);
                    if(String.isNotBlank(o.Secondary_Contact_SCSS_Id__c)){
                        //SCSSSecondaryIdOLEIdMap.put(o.Secondary_Contact_SCSS_Id__c,o.id);
                        RepeatClientContactId.add(o.Secondary_Contact_SCSS_Id__c);
                        SCSSIdOLEIdMap.put(o.Secondary_Contact_SCSS_Id__c,o.id);
                        system.debug('repat client................');
                    }
                    else if(String.isBlank(o.Secondary_Contact_SCSS_Id__c) && (String.isNotBlank(o.Secondary_First_Name__c) || String.isNotBlank(o.Secondary_Last_Name__c) || String.isNotBlank(o.Secondary_Role__c))){
                        NewSecConRepeatClient.put(o.id,o);
                    }
                }
            }
        }

        //For Each Online  EnrollMent we create an account
        if(!onlineEmap.isEmpty() && onlineEmap!=null){
            system.debug('inside oe empty');
            for(Online_Enrollment__c o:onlineEmap.Values()){
                system.debug('account creation');
                system.debug('repeatClientOLEs====='+repeatClientOLEs);
                //if(repeatClientOLEs==null && repeatClientOLEs.isEmpty() && !repeatClientOLEs.containsKey(o.id)){
                if(String.isBlank(o.Primary_Contact_SCSS_Id__c) && !o.Repeat_Client__c){
                    system.debug('not repeat client');
                    Account a=new Account();
                    a.Name = 'CBR';
                    a.Online_Enrollment__c = o.id;//online enrollment id is populated on account to identify and relate account,contact and opportunity
                    accountfinalList.add(a);
                }
                if(String.isNotBlank(o.Hospital_Id__c)){
                    system.debug('true hospital id');
                    OEFacilityId.add(o.Hospital_Id__c);
                }
                if(String.isNotBlank(o.Provider_ID__c)){
                    system.debug('true provider id');
                    OEProviderIds.add(o.Provider_ID__c);
                }
                if(String.isNotBlank(o.Provider_Facility_ID__c)){
                    system.debug('true provider facility id');
                    OEProviderFacilityIds.add(o.Provider_Facility_ID__c);
                }
                
                
            }//End of for Loop
        }
        //inserting accounts
       
        system.debug('query limits------------1 before accounts insert'+limits.getQueries());
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        if(accountfinalList!=null && accountfinalList.size()>0){
             saveResults = Database.insert(accountfinalList,false);
        }
        system.debug('query limits------------2 after accounts insert'+limits.getQueries());
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug(errors);
        system.debug('Aaccounts'+accountfinalList);
        system.debug('AccountList Size'+accountfinalList.size());
        //End of Account creation logic
        
        //Start of Contact Creation Logic
         //Querying on Contact to get contact details of repeat client
         Map<String,Id> SCSSIdAccIdMap = new Map<String,Id>();//This Map holds SCSS Id of primary contact and its Account Id.

        if(repeatClientOLEs!=null && !repeatClientOLEs.isEmpty()){
            RepeatClientContactMap = new Map<id,contact>([select id,SCSS_Contact_Id__c,AccountId,Online_Enrollment__c,ID_Information__c from contact where SCSS_Contact_Id__c IN:RepeatClientContactId]);
        }
        if(RepeatClientContactMap!=null && !RepeatClientContactMap.isEmpty()){
            for(Contact c:RepeatClientContactMap.values()){
                if(PrimaryConSCSSId.contains(c.SCSS_Contact_Id__c)){
                    SCSSIdAccIdMap.put(c.SCSS_Contact_Id__c,c.AccountId);
                }
            }
        }
        system.debug('query limits------------3 before contact insert'+limits.getQueries());
        //For each online enrollment we creat primary and secondary contacts(secondary contact is created only if secondary fields have values)
        list<Contact> finalContactslist = new List<Contact>();//Final list of contacts that are to be created 
        if(accountfinalList!=null && accountfinalList.size()>0 && onlineEmap!=null && !onlineEmap.isEmpty()){
            for(Account a:accountfinalList){
                Online_Enrollment__c o = onlineEmap.get(a.Online_Enrollment__c);
                //if(repeatClientOLEs==null && repeatClientOLEs.isEmpty() && !repeatClientOLEs.containsKey(o.id)){
                if(String.isBlank(o.Primary_Contact_SCSS_Id__c)){
                    system.debug('contact creation');
                    Contact c=new Contact();
                    c.Accountid = a.id;
                    if(String.isNotBlank(o.id)){c.Online_Enrollment__c = o.id;}//online enrollment id is populated on contact to identify and relate account,contact and opportunity
                    if(String.isNotBlank(o.Primary_First_Name__c)){c.FirstName = o.Primary_First_Name__c;}
                    if(String.isNotBlank(o.Primary_Last_Name__c)){c.LastName = o.Primary_Last_Name__c;}
                    if(o.Birth_Date_of_Primary__c!=null){c.Birthdate = o.Birth_Date_of_Primary__c; }
                    if(String.isNotBlank(o.Primary_Address__c) || String.isNotBlank(o.Primary_Address_2__c)){
                        if(String.isNotBlank(o.Primary_Address__c) && String.IsBlank(o.Primary_Address_2__c)){
                            c.MailingStreet = o.Primary_Address__c;
                        }
                        else{
                            c.MailingStreet = o.Primary_Address__c + ' '+ o.Primary_Address_2__c;
                        }
                    }
                    if(String.isNotBlank(o.Primary_City__c)){c.MailingCity = o.Primary_City__c;}
                    if(String.isNotBlank(o.Primary_State__c)){c.MailingState =o.Primary_State__c;}
                    if(String.isNotBlank(o.Primary_Country__c)){c.MailingCountry =o.Primary_Country__c;}
                    c.mailingcountrycode = 'US';//This field value is manually populated as it is not updated when contact is created from online enrollment
                    if(String.isNotBlank(o.Primary_Zipcode__c)){c.MailingPostalCode = o.Primary_Zipcode__c;}
                    if(String.isNotBlank(o.PrimaryID__c)){c.ID_Information__c = o.PrimaryID__c;}
                    if(String.isNotBlank(o.Primary_ID_Type__c)){c.ID_Type__c = o.Primary_ID_Type__c; }
                    if(String.isNotBlank(o.Primary_Email__c)){ c.Email = o.Primary_Email__c;}
                    //if(String.isNotBlank(o.Primary_Role__c)){c.Role_Online_Enrollment__c = o.Primary_Role__c;}//This is for opportunitycontactrole reference
                    if(o.Primary_Home_Phone__c!=null){c.Phone=o.Primary_Home_Phone__c;}
                    
                    finalContactslist.add(c);
                }//Repeat client if Condition End 
                //Secondary contact is created only when below fields have values
                if( String.isBlank(o.Secondary_Contact_SCSS_Id__c) && (String.isNotBlank(o.Secondary_Last_Name__c) || String.isNotBlank(o.Secondary_First_Name__c) || String.isNotBlank(o.Secondary_Role__c))){
                    Contact c1 = new Contact();
                    if(String.isNotBlank(o.Secondary_First_Name__c)){c1.FirstName = o.Secondary_First_Name__c;}
                    if(String.isNotBlank(o.Secondary_Last_Name__c)){c1.LastName = o.Secondary_Last_Name__c;}
                    c1.accountId = a.id;
                    if(String.isNotBlank(o.id)){c1.Online_Enrollment__c = o.id;}//online enrollment id is populated on contact to identify and relate account,contact and opportunity
                    //if(String.isNotBlank(o.Secondary_Role__c)){c1.Role_Online_Enrollment__c = o.Secondary_Role__c;}
                    finalContactslist.add(c1);
                }
                
            } 
        }
        //If NewSecConRepeatClient not null then we create a new secondary contact for repeat client
        if(NewSecConRepeatClient!=null && !NewSecConRepeatClient.isEmpty()){
            for(Online_Enrollment__c ole:NewSecConRepeatClient.values()){
                Contact c = new Contact();
                c.FirstName = ole.Secondary_First_Name__c;
                c.LastName = ole.Secondary_Last_Name__c;
                c.AccountId = SCSSIdAccIdMap.get(ole.Primary_Contact_SCSS_Id__c);
                c.Online_Enrollment__c = ole.id;
                finalContactslist.add(c);
            }
        }
        
        Set<id> successContacts = new Set<id>(); //This set contains contact ids which are successfully inserted
        List<Database.SaveResult> saveResultsCont = new List<Database.SaveResult>();
        List<String> contErrors = new List<String>();
        if(finalContactslist!=null && finalContactslist.size()>0)
        {
            saveResultsCont = Database.insert(finalContactslist,false);
            system.debug(saveResultsCont);
        }
         for (Database.SaveResult saveResult : saveResultsCont) {
             system.debug('cntact id...........'+saveResult.getId());
             successContacts.add(saveResult.getId());
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    contErrors.add(e.getMessage());
                    
                }
            }
        }
        system.debug('query limits------------4 after contact  insert'+limits.getQueries());
        system.debug('contact errors'+contErrors);
        system.debug('Contacts.........'+finalContactslist);
        system.debug('Contact size'+finalContactslist.size());
        //End of Contact Creation logic
        //Start of accounts deletion if contact is not created
        //If contact records are not created for online enrollment then account related to that online enrollment is also deleted
        //Get all account ids from all inserted contacts to compare this account ids with accountfinalList .
        Set<id> AccIdsOnContacts = new Set<id>();//This set contains all account ids which are on contacts created.
        if(successContacts!=null && !successContacts.isEmpty()){
            for(Contact c:[Select Id,Accountid,Opportunity_Status__c from Contact Where id IN:successContacts AND Opportunity_Status__c!='Open']){//get successfully inserted contacts and add its accountId to set AccIdsOnContacts
                AccIdsOnContacts.add(c.AccountId);
            }
        }
        
        List<Account> AccToDeleteList = new List<Account>();//If each account doesnt contain contact/'s then we delete the account(If a contact is not created for online enrollment we delete accounts for those online enrollment)
        //For a account if contact is not created then adding that account without contact to AccToDeleteList List and deleteing the list
        if(accountfinalList!=null && !accountfinalList.isEmpty()){
            for(Account a:accountfinalList){
                if(!AccIdsOnContacts.contains(a.id)){
                    AccToDeleteList.add(a);
                }
            }
        }
        system.debug('AccToDeleteList'+AccToDeleteList);
        if(AccToDeleteList!=null && !AccToDeleteList.isEmpty()){
            List<Database.DeleteResult> saveResultsAccDelete = Database.delete(AccToDeleteList,false);
        }
        //End of accounts deletion if contact is not created
        
        //Start Of Opportunity Creation logic
        
      
        List<Account> RepeatClientAccList = new List<Account>();//List of accounts on repeat client contacts
        Set<id> RepeatClientAccIds = new Set<id>();//Account ids to query on account and add these list of accounts to accountfinalList List to create opportunities.
        map<id,id> ConAccIdMap = new Map<Id,Id>();
        system.debug('RepeatClientContactId===='+RepeatClientContactId);
       
        system.debug('RepeatClientContactMap----'+RepeatClientContactMap);
        List<Contact> RepeatClientConUpdateList = new List<Contact>();
        if(RepeatClientContactMap!=null && !RepeatClientContactMap.isEmpty()){
            for(contact c:RepeatClientContactMap.values()){
                if(SCSSIdOLEIdMap!=null && !SCSSIdOLEIdMap.isEmpty()){
                    c.Online_Enrollment__c = SCSSIdOLEIdMap.get(c.SCSS_Contact_Id__c);
                    RepeatClientConUpdateList.add(c);
                    
                    RepeatClientAccIds.add(c.AccountId);
                    
                }
            }
        }
        system.debug('RepeatClientAccIds == '+RepeatClientAccIds);
        List<Database.saveResult> ContactUpdateSR = new List<DataBase.SaveResult>();
        //Update Repeat client contact's Online enrollment id.
        if(RepeatClientConUpdateList!=null && !RepeatClientConUpdateList.isEmpty()){
            ContactUpdateSR = DataBase.Update(RepeatClientConUpdateList,false);
        }
        system.debug('ContactUpdateSR-----'+ContactUpdateSR);
        if(RepeatClientConUpdateList!=null && !RepeatClientConUpdateList.isEmpty()){
            for(Contact c:RepeatClientConUpdateList){
                ConAccIdMap.put(c.AccountId,c.Online_Enrollment__c);
                finalContactslist.add(c);
            }
        }
        system.debug('finalContactslist'+finalContactslist);
        if(RepeatClientAccIds!=null && !RepeatClientAccIds.isEmpty()){
            RepeatClientAccList = [select id,Name,Online_Enrollment__c from account where Id IN:RepeatClientAccIds];
        }
        system.debug('RepeatClientAccList====='+RepeatClientAccList);
        List<Account> AccOLEUpdateList = new List<Account>();
        if(RepeatClientAccList!=null && !RepeatClientAccList.isEmpty()){
            for(Account a:RepeatClientAccList){
              
               a.Online_Enrollment__c = ConAccIdMap.get(a.id);
               AccOLEUpdateList.add(a);
            }
        }
        List<Database.saveResult> AccUpdateSR = new List<DataBase.SaveResult>();
        if(AccOLEUpdateList!=null && !AccOLEUpdateList.isEmpty()){
            AccUpdateSR = Database.Update(AccOLEUpdateList,false);
        }
        system.debug('accountfinalList'+accountfinalList);
        if(AccOLEUpdateList!=null && !AccOLEUpdateList.isEmpty()){
            for(Account a:AccOLEUpdateList){
                accountfinalList.add(a);
            }
        }
        system.debug('finalContactslist====='+finalContactslist);
        //Below map i.e OEContactsMap contains online enrollment as key and list of contacts(primary and secondary contacts of online enrollment). this map is used to create opportunityContactRoles.
        Map<id,list<Contact>> OEContactsMap = new Map<Id,List<Contact>>();//Map of Online EnrollMents and Contacts List
        if(finalContactslist!=null && finalContactslist.size()>0){
            for(Contact c:finalContactslist){
                List<Contact> TempContacts = new List<Contact>();
                TempContacts = OEContactsMap.get(c.Online_Enrollment__c);
                if(TempContacts == null){
                    OEContactsMap.put(c.Online_Enrollment__c,new List<Contact>{c});
                }
                else{
                    TempContacts.add(c);
                    OEContactsMap.put(c.Online_Enrollment__c,TempContacts);
                }
            }
        }
        
         //Map holds facility master id of online enrollment as key and facility id as value to update opportunity
         //onlineEnrollmentCreateupdateHelper.getFacilityrecords() this method returns facility map with master facility id as key and values as SFDC id of facility record.(Master facility id on faiclity objcect is same as hospital Id on OE)
         
        Map<String,String> FacilityIdMap = new Map<String,String>();
        if(OEFacilityId!=null && !OEFacilityId.isEmpty()){
            FacilityIdMap = onlineEnrollmentCreateupdateHelper.getFacilityrecords(OEFacilityId);
        }
        //End get facility records to map on opportunities
        
        system.debug('query limits------------5 before Opportunities insert'+limits.getQueries());
        //Creating opportunities for each account
        
        list<opportunity> oppFinalList = new List<opportunity>();
        if(accountfinalList!=null && !accountfinalList.isEmpty() && onlineEmap!=null && !onlineEmap.isEmpty()){
            system.debug('acc in for opp'+accountfinalList);
            for(Account a:accountfinalList){
                system.debug('accounts for opp in for loop');
                Online_Enrollment__c o = onlineEmap.get(a.Online_Enrollment__c);
                opportunity opp = new opportunity();
                opp.Name = 'Online Enrollment'+system.now();
                opp.Accountid = a.id;
                if(String.isNotBlank(o.Referrer_Name__c)){opp.Referral_Name__c = o.Referrer_Name__c;}
                opp.LeadSource = 'Online Enrollment';
                if(String.isNotBlank(o.of_Babies__c)){
                    opp.of_Babies__c = o.of_Babies__c;}
                else{
                    opp.of_Babies__c = 'Single';
                }
                if(String.isNotBlank(o.of_CB__c)){opp.of_CB__c = o.of_CB__c;}
                else{opp.of_CB__c = '1';}
                if(String.isNotBlank(o.of_CT__c)){opp.of_CT__c = o.of_CT__c;}
                else{opp.of_CT__c='0';}
                if(o.Ship_Kit_Flag__c){
                     opp.PickUp_or_Ship_Kit__c ='Ship';
                }
                else{ opp.PickUp_or_Ship_Kit__c ='PickUp';}
               
                if(String.isNotBlank(o.id)){opp.Online_Enrollment__c = o.id;}
                if(OEContactsMap!=null && !OEContactsMap.isEmpty()){
                    for(Contact c:OEContactsMap.get(a.Online_Enrollment__c)){
                        if(String.isNotBlank(c.ID_Information__c)){
                            opp.Primary_Contact__c = c.id;
                        }
                        else if(string.isBlank(c.ID_Information__c)){
                            opp.Secondary_Contact__c = c.id;
                        }
                    }
                }
                if(o.Due_Date__c!=null){opp.Due_Date__c = o.Due_Date__c;}
                if(String.isNotBlank(o.Adoption_Type__c)){opp.Adoption_Type__c = o.Adoption_Type__c;}
                if(String.isNotBlank(o.How_Did_You_Hear__c)){opp.Primary_Source__c = o.How_Did_You_Hear__c;}
                opp.CloseDate = system.today();
                if(String.isNotBlank(o.Promo_Code__c)){opp.Promo_Code__c = o.Promo_Code__c;}
                 if(String.isNotBlank(o.Payment_Plan__c)){opp.Payment_Plan__c = o.Payment_Plan__c ;}
                opp.StageName = 'Partial Online Enroll (8)';
                if(o.Completed_Flag__c){
                    opp.Completed_Flag__c = o.Completed_Flag__c;
                    opp.Online_Enroll_Status__c = 'Complete';
                    opp.Section_1_Received__c = true;
                    opp.Section_4_Received__c = true;
                }
                else{
                    opp.Completed_Flag__c = o.Completed_Flag__c;
                    opp.Online_Enroll_Status__c = 'Incomplete';
                }
                if(FacilityIdMap!=null && !FacilityIdMap.isEmpty()){
                    if(String.isNotBlank(o.Hospital_Id__c)){opp.Delivering_Hospital__c = FacilityIdMap.get(o.Hospital_Id__c);}
                }
                //If Shipping values are provided on online enrollment record they are populated on opportunity or is shiping values are null on online enrollment then shipping values on opportunity are populated from its primary contacts 
                if(String.isNotBlank(o.Ship_To_Street_Address__c)){opp.Ship_To_Street1__c= o.Ship_To_Street_Address__c ;}
                if(String.isNotBlank(o.Ship_To_Addr_2__c)){opp.Ship_To_Street2__c= o.Ship_To_Addr_2__c ;}
                if(String.isNotBlank(o.Ship_To_City__c)){opp.Ship_To_City__c = o.Ship_To_City__c ;}
                if(String.isNotBlank(o.Ship_To_Country__c)){opp.Ship_To_Country__c = o.Ship_To_Country__c ;}
                if(String.isNotBlank(o.Ship_To_State__c)){opp.Ship_To_State__c = o.Ship_To_State__c ;}
                if(String.isNotBlank(o.Ship_To_Zip_Code__c)){opp.Ship_To_Zip_Code__c = o.Ship_To_Zip_Code__c ;}
                if(String.isNotBlank(o.Ship_to_first_name__c) || String.isNotBlank(o.Ship_to_Last_Name__c)){
                    if(String.isNotBlank(o.Ship_to_first_name__c) && String.isBlank(o.Ship_to_Last_Name__c)){
                        opp.Ship_To_Name__c = o.Ship_to_first_name__c;
                    }
                    else if(String.isBlank(o.Ship_to_first_name__c) && String.isNotBlank(o.Ship_to_Last_Name__c)){
                        opp.Ship_To_Name__c = o.Ship_to_Last_Name__c;
                    }
                    else{
                        opp.Ship_To_Name__c = o.Ship_to_first_name__c +' '+o.Ship_to_Last_Name__c;
                    }
                }
                opp.Shipping_Method__c = null;
                opp.Ship_To_Phone__c = null;
                opp.Requested_Shipping_Date__c = null;
                
                oppFinalList.add(opp);
            }
        }
        system.debug('oppFinalList'+oppFinalList+'oppFinalListsize'+oppFinalList.size());
        List<Database.SaveResult> OppSaveResults =new List<Database.SaveResult>();
        List<String> opperrors = new List<String>();
        if(oppFinalList!=null && oppFinalList.size()>0){
            system.debug('opps');
          /*  if(!recursive.ContactOCR){
                recursive.ContactOCR = true;
            }*/
             OppSaveResults = Database.insert(oppFinalList,false);
        }
        system.debug('save result opps'+OppSaveResults);
        for (Database.SaveResult saveResult : OppSaveResults) {
            
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    opperrors.add(e.getMessage());
                }
            }
        }
        system.debug('opportunity errors..'+opperrors);
        system.debug('opportunities........'+oppFinalList);
        system.debug('query limits------------6 after opportunities insert'+limits.getQueries());
        //End if Opportunity Creation Logic
        
        //Start Of OpportunityContactRole Logic 
        //For each opportunity created opportunity contact roles are also created. First we check opportunity creation using account. if opportunities are created then OEContactsMap
        List<OpportunityContactRole> OCRfinallist = new list<OpportunityContactRole>();
        Map<id,opportunity> accOppMap = new Map<id,Opportunity>();//Map With Account Id and opportunity
       
        if(oppFinalList!=null && oppFinalList.size()>0){
            for(opportunity o:oppFinalList){
                accOppMap.put(o.AccountId,o);
            }
             
        }
        system.debug('query limits------------7 before OCR insert'+limits.getQueries());
        if(accountfinalList!=null && accountfinalList.size()>0 && accOppMap!=null && !accOppMap.isEmpty() && OEContactsMap!=null && !OEContactsMap.isEmpty()){
            for(Account a:accountfinalList){
                if(accOppMap.containsKey(a.id)){
                    for(Contact c:OEContactsMap.get(a.Online_Enrollment__c)){
                        if(String.IsNotBlank(c.Online_Enrollment__c)){
                            Online_Enrollment__c ole = onlineEmap.get(c.Online_Enrollment__c);
                            OpportunityContactRole ocr = new OpportunityContactRole();
                            ocr.contactId = c.id;
                            ocr.OpportunityID = accOppMap.get(a.id).id;
                            if(String.isNotBlank(c.ID_Information__c)){
                                ocr.IsPrimary = true;
                                ocr.Role = ole.Primary_Role__c;
                            }else if(String.isBlank(c.ID_Information__c)){
                                if(String.isNotBlank(ole.Secondary_Role__c)){
                                    ocr.Role=ole.Secondary_Role__c;
                                }
                                else{
                                    ocr.Role = 'Unknown';
                                }
                            }
                            
                            OCRfinallist.add(ocr);
                        }
                    }
                }
            }
        }
        List<Database.SaveResult> OCRSaveResults = new List<Database.SaveResult>();
        List<String> OCRerrors = new list<String>();
        if(OCRfinallist!=null && OCRfinallist.size()>0){
             OCRSaveResults = Database.insert(OCRfinallist,false);
        }
        for (Database.SaveResult saveResult : OCRSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    OCRerrors.add(e.getMessage());
                }
            }
        }
        system.debug('OCR errors'+OCRerrors);
        system.debug('Opportunity ContactRoles final recods'+OCRfinallist);
        system.debug('OCRfinallist size'+OCRfinallist.size());
        //End of OpportunityContactRole Logic
        
        system.debug('query limits------------8 after OCR insert'+limits.getQueries());

        //Start of logic to create Contact payment profile
        //If contact is repeat client then query on contact payment profile to get payment profile records for repeat clients
        Map<id,Contact_Payment_Profile__c> repeatClientCPPList = new Map<id,Contact_Payment_Profile__c>();
        List<Contact_Payment_Profile__c> PayProfileFinalListToUpdate = new list<Contact_Payment_Profile__c>();
        if(RepeatClientContactMap!=null && !RepeatClientContactMap.isEmpty()){
            repeatClientCPPList = new Map<id,Contact_Payment_Profile__c>([select id,Contact__c,Credit_Card_Type__c,Expiration_Month__c,Expiration_Year__c,Last_4_Digits__c,Profile_Token__c,Contact__r.Online_Enrollment__c from Contact_Payment_Profile__c Where Contact__c IN:RepeatClientContactMap.keyset()]);
        }
        
        List<Contact_Payment_Profile__c> PayProfileFinalList = new list<Contact_Payment_Profile__c>();
        if(finalContactslist!=null && finalContactslist.size()>0 && onlineEmap!=null && !onlineEmap.isEmpty()){
            for(Contact c:finalContactslist){
                if(String.isNotBlank(c.ID_Information__c) && !RepeatClientContactMap.containsKey(c.id)){
                    Online_Enrollment__c o = onlineEmap.get(c.Online_Enrollment__c);
                    if(o.Credit_Card_Profile_ID__c!=null || String.isNotBlank(o.Cardholder_Name__c) || String.isNotBlank(o.Credit_Card_Type__c) ||String.isNotBlank(o.Expiration_Year__c) || String.isNotBlank(o.CC_Expiration_Month__c) ||o.Last_4_Digits__c!=null ){
                        Contact_Payment_Profile__c cpp =new Contact_Payment_Profile__c();
                        cpp.Contact__c = c.id;
                        if(o.Credit_Card_Profile_ID__c!=null){cpp.Profile_Token__c =o.Credit_Card_Profile_ID__c;}
                        if(String.isNotBlank(o.Cardholder_Name__c)){cpp.Card__c = o.Cardholder_Name__c;}
                        if(String.isNotBlank(o.Credit_Card_Type__c)){ cpp.Credit_Card_Type__c = o.Credit_Card_Type__c;}
                        if(String.isNotBlank(o.Expiration_Year__c)){cpp.Expiration_Year__c = o.Expiration_Year__c;}
                        if(String.isNotBlank(o.CC_Expiration_Month__c)){cpp.Expiration_Month__c = o.CC_Expiration_Month__c;}
                        if(o.Last_4_Digits__c!=null){cpp.Last_4_Digits__c = o.Last_4_Digits__c;}
                        PayProfileFinalList.add(cpp);
                    }
                }
                 
            }
            //Update contact payment profile records of repeat client when credit card details are not same
            if(RepeatClientContactMap!=null && !RepeatClientContactMap.isEmpty() && repeatClientCPPList!=null && !repeatClientCPPList.isEmpty()){
                for(Contact_Payment_Profile__c cpp:repeatClientCPPList.values()){
                    Online_Enrollment__c o = onlineEmap.get(cpp.Contact__r.Online_Enrollment__c);
                    if(RepeatClientContactMap.containsKey(cpp.Contact__c) && o.Credit_Card_Profile_ID__c!=cpp.Profile_Token__c){
                        if(o.Credit_Card_Profile_ID__c!=null){cpp.Profile_Token__c =o.Credit_Card_Profile_ID__c;}
                        if(String.isNotBlank(o.Cardholder_Name__c)){cpp.Card__c = o.Cardholder_Name__c;}
                        if(String.isNotBlank(o.Credit_Card_Type__c)){ cpp.Credit_Card_Type__c = o.Credit_Card_Type__c;}
                        if(String.isNotBlank(o.Expiration_Year__c)){cpp.Expiration_Year__c = o.Expiration_Year__c;}
                        if(String.isNotBlank(o.CC_Expiration_Month__c)){cpp.Expiration_Month__c = o.CC_Expiration_Month__c;}
                        if(o.Last_4_Digits__c!=null){cpp.Last_4_Digits__c = o.Last_4_Digits__c;}
                        PayProfileFinalListToUpdate.add(cpp);
                    }
                }
            }
        }
        //Create new contact payment profiles
        List<Database.SaveResult> PayProSaveResults=new List<Database.SaveResult>();
        List<String> PayProErrors = new List<String>();
        system.debug('query limits------------9 before CPP insert'+limits.getQueries());
        if(PayProfileFinalList!=null && PayProfileFinalList.size()>0){
             PayProSaveResults = Database.insert(PayProfileFinalList,false);
        }
        system.debug('query limits------------10 after CPP  insert'+limits.getQueries());
        for (Database.SaveResult saveResult : PayProSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    PayProErrors.add(e.getMessage());
                }
            }
        }

        system.debug('opp provider errors'+PayProErrors);
        system.debug('Contact payment profile final list'+PayProfileFinalList);
        
        //Update payment profiles 
        List<Database.SaveResult> PayProUpdateSaveResults=new List<Database.SaveResult>();
        List<String> PayProUpdateErrors = new List<String>();
        if(PayProfileFinalListToUpdate!=null && PayProfileFinalListToUpdate.size()>0){
             PayProUpdateSaveResults = Database.update(PayProfileFinalListToUpdate,false);
        }
        for (Database.SaveResult saveResult : PayProUpdateSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    PayProUpdateErrors.add(e.getMessage());
                }
            }
        }
        system.debug('query limits------------11 after CPP update'+limits.getQueries());
        system.debug('opp provider errors'+PayProUpdateErrors);
        system.debug('Contact payment profile update final list'+PayProfileFinalListToUpdate);
        
        
        //End of logic to crate contact payment profile
        
       //Start Provider Opportunity Creation Logic 
       List<Opportunity_Provider__c> FinalOppProviderList = new List<Opportunity_Provider__c>();
       Map<String,String> MasterIdProviderIdMap = new Map<String,String>();//Map to store master provider as key and sfdc provider id as value
       if(OEProviderIds!=null && !OEProviderIds.isEmpty()){
           MasterIdProviderIdMap = onlineEnrollmentCreateupdateHelper.getProviderrecords(OEProviderIds);
       }
      
       Map<String,Provider_Facility__c> MasterPFSfdcMap = new map<String,Provider_Facility__c>();//Master provider facility as key and sfdc provider faclity as value
       if(OEProviderFacilityIds!=null && !OEProviderFacilityIds.isEmpty()){
           MasterPFSfdcMap = onlineEnrollmentCreateupdateHelper.getproviderfacilityids(OEProviderFacilityIds);
       }
       system.debug('oppFinalList======='+oppFinalList);

       system.debug('MasterIdProviderIdMap===='+MasterIdProviderIdMap);
       system.debug('MasterPFSfdcMap========'+MasterPFSfdcMap);
       system.debug('onlineEmap========='+onlineEmap);
       system.debug('query limits------------12 before Opp Provider insert'+limits.getQueries());
       //Create opportunity provider when Valid facility and provider facility ids are provided on online enrollment
       if(oppFinalList!=null && !oppFinalList.isEmpty() && MasterIdProviderIdMap!=null && !MasterIdProviderIdMap.isEmpty() && MasterPFSfdcMap!=null && !MasterPFSfdcMap.isEmpty() && !onlineEmap.isEmpty()){
           for(opportunity opp:oppFinalList){
               Online_Enrollment__c o = onlineEmap.get(opp.Online_Enrollment__c);
               if(String.IsNotBlank(o.Provider_ID__c) && String.IsNotBlank(o.Provider_Facility_ID__c)){
                   Opportunity_Provider__c opppro = new Opportunity_Provider__c();
                   opppro.Opportunity__c = opp.id;
                   if(String.isNotBlank(o.Provider_Facility_ID__c) && MasterPFSfdcMap.containsKey(o.Provider_Facility_ID__c)){
                        opppro.Provider__c = MasterPFSfdcMap.get(o.Provider_Facility_ID__c).Provider__c;
                        opppro.Provider_Facility__c = MasterPFSfdcMap.get(o.Provider_Facility_ID__c).id;
                        opppro.Facility__c = MasterPFSfdcMap.get(o.Provider_Facility_ID__c).Facility__c;
                        opppro.Primary_Provider__c = true;
                   }
                  
                   FinalOppProviderList.add(opppro);
               }
           }
       }
       
        List<Database.SaveResult> oppProSaveResults = new List<Database.SaveResult>();
        List<String> OPRerrors = new list<String>();
        if(FinalOppProviderList!=null && FinalOppProviderList.size()>0){
             oppProSaveResults = Database.insert(FinalOppProviderList,false);
        }
        for (Database.SaveResult saveResult : oppProSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    OPRerrors.add(e.getMessage());
                }
            }
        }
        system.debug('OCR errors'+OPRerrors);
        system.debug('Opportunity ContactRoles final recods'+FinalOppProviderList);
        system.debug('FinalOppProviderList size'+FinalOppProviderList.size()); 
        system.debug('query limits------------13 after opp pro insert'+limits.getQueries());
       //End Provider Opportunity Creation Logic 
       
       //Start of Online Enrollment validations if completed check is true
       
       Map<id,Opportunity> OppWithOP = new Map<id,Opportunity>();//This map stores opportunity contains opportuntiy provider
       Map<id,Opportunity> CompletedOppMap = new Map<Id,Opportunity>();//This map stores opp if completed flag is true
       Map<id,Online_Enrollment__c> OLEMap = new Map<Id,Online_Enrollment__c>();
       //oppFinalList contains all opportunities. If any opportunity's completed checkbox is true and if Opportunity provider is cretaed for opportunity(we check 2 validations in below code. If completed flag is true and opportunity provider is created all remaing validations are valdated from helper method)then we check for all validations using helper method onlineEnrollmentCreateupdateHelper.checkOLEOppValidations() by passing map of opportunities if all validations pass we change opportunity stage to Won (9) and online enroll status to Auto Enroll
       
       //we check  Completed flag for each opportunity of list oppFinalList. If completed flag is true then add opp to Map CompletedOppMap
       if(oppFinalList!=null && !oppFinalList.isEmpty()){
            system.debug('opp to update');
            for(Opportunity opp:oppFinalList){
                if(opp.Completed_Flag__c){
                    system.debug('opp.Completed_Flag__c--------'+opp.Completed_Flag__c);
                    CompletedOppMap.put(opp.id,opp);
                }
            }
       }
       //If above map is not empty then we check if opp in map contains opportunity provider. If Opportuntiy provider is created a opportunity and completed flag is true then only we add opp to map OppWithOP.
       if(CompletedOppMap!=null && !CompletedOppMap.isEmpty() && FinalOppProviderList!=null && !FinalOppProviderList.isEmpty()){
            system.debug('sdgdsjfsdhfs');
            system.debug('CompletedOppMap'+CompletedOppMap);
            system.debug('FinalOppProviderList'+FinalOppProviderList);
            for(Opportunity_Provider__c op:FinalOppProviderList){
                if(CompletedOppMap.containsKey(op.Opportunity__c)){
                    system.debug('CompletedOppMap'+CompletedOppMap);
                    OppWithOP.put(op.Opportunity__c,CompletedOppMap.get(op.Opportunity__c));
                }
            }
        }
        
        //If OppWithOP is not empty then it is passed to method which checks all other validations on opp and upadte Opportunity stage = 'Won (9)' and Online enroll status = 'Auto Enroll'
        system.debug('OppWithOP'+OppWithOP);
        if(OppWithOP!=null && !OppWithOP.isEmpty()){
            for(Opportunity opp:OppWithOP.values()){
                if(onlineEmap!=null && !onlineEmap.isEmpty()){
                    OLEMap.put(opp.Online_Enrollment__c,onlineEmap.get(opp.Online_Enrollment__c));
                }
            }
            if(OLEMap!=null && !OLEMap.isEmpty()){
                onlineEnrollmentCreateupdateHelper.checkOLEOppValidations(OppWithOP,OLEMap);
            }
        }
        system.debug('query limits------------16 after opp update to won'+limits.getQueries());
       //End of Online Enrollment validations
       
       
       //Start of User Stories 469, 470, 471. During the creation of Online Enrollment record, there are  fields called ‘Campaign ID2’, ‘Source Code’ and ‘Promo Code’ if these fields have values then check for a campaign record if campaign record is found create a campaignInfluence record.
       
       List<CampaignInfluence> FinalCampaignInfList = new List<CampaignInfluence>();//List to insert campaignInfluence
       Set<String> campaignIDsSet = new Set<String>();//Set contains campaign id 2 field values this is used to query on campaign object
       Set<String> CampaignCodeSet = new Set<String>();//This set contains Source Code and Promo code values of online enrollment
       Map<id,Campaign> CampaignMap = new Map<id,Campaign>();//This Map holds campaigns which match with campaign id 2 or source code or promo code
       //Check values of fields Campaign_ID_2__c,Promo_Code__c and Source_Code__c. If this values are not null then add Campaign_ID_2__c value to campaignIDsSet and Promo_Code__c,Source_Code__c field values to CampaignCodeSet.
       Map<String,Opportunity> OEOppMap = new Map<String,Opportunity>();
       if(oppFinalList!=null && !oppFinalList.isEmpty()){
           for(Opportunity opp:oppFinalList){
               OEOppMap.put(opp.Online_Enrollment__c,opp);
           }
       }
       if(!onlineEmap.isEmpty() && onlineEmap!=null){
            system.debug('inside oe empty');
            for(Online_Enrollment__c o:onlineEmap.Values()){
                if(String.isNotBlank(o.Campaign_ID_2__c)){
                    campaignIDsSet.add(o.Campaign_ID_2__c);
                }
                if(String.isNotBlank(o.Promo_Code__c)){
                    CampaignCodeSet.add(o.Promo_Code__c);
                }
                if(String.isNotBlank(o.Source_Code__c)){
                    CampaignCodeSet.add(o.Source_Code__c);
                }
            }
       }
       system.debug('campaignIDsSet==========='+campaignIDsSet);
       system.debug('CampaignCodeSet======'+CampaignCodeSet);
       //If campaignIDsSet or  CampaignCodeSet are not empty then query on capaign object to get campaign records.
       if((campaignIDsSet!=null && !campaignIDsSet.isEmpty()) || (CampaignCodeSet!=null && !CampaignCodeSet.isEmpty())){
           
           CampaignMap = new Map<id,Campaign>([Select id,Campaign_Code__c,Name from Campaign where Name IN:campaignIDsSet OR Campaign_Code__c IN:CampaignCodeSet]);
       }
        //Split Campaigns into 2 maps Campaign Id 2 campaigns are added in campIdMap and campaigns queried source code/promo code are added in PromoSourceCode map
       Map<String,Campaign> campIdMap = new Map<String,Campaign>();
       Map<String,Campaign> PromoSourceCode = new Map<String,Campaign>();
       if(CampaignMap!=null && !CampaignMap.isEmpty()){
           for(Campaign c:CampaignMap.values()){
               if(campaignIDsSet.contains(c.Name)){
                   campIdMap.put(c.Name,c);
               }
               if(CampaignCodeSet.contains(c.Campaign_Code__c)){
                   PromoSourceCode.put(c.Campaign_Code__c,c);
               }
           }
       }
       system.debug('campIdMap'+campIdMap);
       system.debug('PromoSourceCode'+PromoSourceCode);
       system.debug('CampaignMap'+CampaignMap);
       //If CampaignMap is not null then create campaignInfluence records.
       if(CampaignMap!=null && !CampaignMap.isEmpty() && !onlineEmap.isEmpty() && onlineEmap!=null && OEOppMap!=null && !OEOppMap.isEmpty()){
           if(!onlineEmap.isEmpty() && onlineEmap!=null){
            system.debug('inside oe emptywdssf');
            
                for(Online_Enrollment__c o:onlineEmap.Values()){
                    system.debug('o.Source_Code__c'+o.Source_Code__c);
                    system.debug('Promo_Code__c'+o.Promo_Code__c);
                    //If OE'Campaign_ID_2__c is not null then create campaignInfluence
                    if(String.isNotBlank(o.Campaign_ID_2__c) && !campIdMap.isEmpty() && campIdMap.containsKey(o.Campaign_ID_2__c)){
                        system.debug('Cid==========='+o.Campaign_ID_2__c);
                        CampaignInfluence ci = new CampaignInfluence();
                        ci.CampaignId = campIdMap.get(o.Campaign_ID_2__c).Id;
                        ci.OpportunityId = OEOppMap.get(o.id).id;
                        ci.Modelid =Label.Campaign_Model_Id;
                        FinalCampaignInfList.add(ci);
                    }
                    //If promocode is not null and promo code related campaign is found then create campaignInfluence
                    if(PromoSourceCode!=null && !PromoSourceCode.isEmpty()){
                        if(String.isNotBlank(o.Promo_Code__c) && PromoSourceCode.containsKey(o.Promo_Code__c) && o.Promo_Code__c == PromoSourceCode.get(o.Promo_Code__c).Campaign_Code__c){
                            system.debug('o.Promo_Code__c==========='+o.Promo_Code__c);
                            CampaignInfluence ci1 = new CampaignInfluence();
                            ci1.CampaignId = PromoSourceCode.get(o.Promo_Code__c).Id;
                            ci1.OpportunityId = OEOppMap.get(o.id).id;
                            ci1.Modelid =Label.Campaign_Model_Id;
                            FinalCampaignInfList.add(ci1);
                        }
                        //If SourceCode is not null and Source code related campaign is found then create campaignInfluence
                        if(String.isNotBlank(o.Source_Code__c) && PromoSourceCode.containsKey(o.Source_Code__c) && o.Source_Code__c == PromoSourceCode.get(o.Source_Code__c).Campaign_Code__c){
                            system.debug('o.Source_Code__c=========='+o.Source_Code__c);
                            CampaignInfluence ci2 = new CampaignInfluence();
                            ci2.CampaignId = PromoSourceCode.get(o.Source_Code__c).Id;
                            ci2.OpportunityId = OEOppMap.get(o.id).id;
                            ci2.Modelid =Label.Campaign_Model_Id;
                            FinalCampaignInfList.add(ci2);
                        }
                    }
                }
            }
       }
        List<Database.SaveResult> CampaignInfSaveResult = new List<Database.SaveResult>();
        List<String> CIerrors = new list<String>();
        //insert FinalCampaignInfList if list is not empty
        system.debug('query limits------------14 before ci insert'+limits.getQueries());
        if(FinalCampaignInfList!=null && FinalCampaignInfList.size()>0){
             CampaignInfSaveResult = Database.insert(FinalCampaignInfList,false);
        }
        system.debug('query limits------------15 after CI insert'+limits.getQueries());
        for (Database.SaveResult saveResult : CampaignInfSaveResult) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    CIerrors.add(e.getMessage());
                }
            }
        }
        system.debug('CampaignInfluence errors'+CIerrors);
        system.debug('CampaignInfluence final recods'+FinalCampaignInfList);
        system.debug('FinalCampaignInfList size'+FinalCampaignInfList.size()); 
       //End of user stories 469, 470, 471
    }
    
}